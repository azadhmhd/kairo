import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:kairo_shared_models/shared_models.dart';

/// A request to a model did not produce a line, with a reason worth showing.
class KairoAiException implements Exception {
  const KairoAiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Asks a model for a line, over the OpenAI chat-completions format, which
/// Ollama, LM Studio, llama.cpp and the hosted services all accept.
class KairoAiClient {
  const KairoAiClient({this.timeout = const Duration(seconds: 45)});

  final Duration timeout;

  static const int oneLineTokens = 120;

  static const int oneLineCharacters = 160;

  /// Asks [settings]'s model to answer [prompt], and returns the text it gave.
  ///
  /// The defaults are sized for a single line. A summary passes larger ones.
  Future<String> complete({
    required AiSettings settings,
    required String system,
    required String prompt,
    int maxTokens = oneLineTokens,
    int maxCharacters = oneLineCharacters,
  }) async {
    final Uri? endpoint = _endpointFor(settings.baseUrl);
    if (endpoint == null) {
      throw const KairoAiException(
        'That address is not one Kairo can reach. It should look like '
        'http://localhost:11434/v1',
      );
    }

    final HttpClient client = HttpClient()..connectionTimeout = timeout;
    try {
      final HttpClientRequest request = await client.postUrl(endpoint);
      request.headers.contentType = ContentType.json;
      if (settings.apiKey.isNotEmpty) {
        request.headers.set(
          HttpHeaders.authorizationHeader,
          'Bearer ${settings.apiKey}',
        );
      }
      request.write(
        jsonEncode(<String, Object?>{
          'model': settings.model,
          'stream': false,
          'max_tokens': maxTokens,
          'temperature': 0.8,
          'messages': <Map<String, String>>[
            <String, String>{'role': 'system', 'content': system},
            <String, String>{'role': 'user', 'content': prompt},
          ],
        }),
      );

      final HttpClientResponse response =
          await request.close().timeout(timeout);
      final String body = await response.transform(utf8.decoder).join();

      if (response.statusCode != HttpStatus.ok) {
        throw KairoAiException(_explain(response.statusCode, settings));
      }
      return _textFrom(body, maxCharacters);
    } on SocketException {
      throw KairoAiException(
        'Nothing answered at ${settings.baseUrl}. Is the model running?',
      );
    } on TimeoutException {
      throw const KairoAiException('The model did not answer in time.');
    } on HandshakeException {
      throw const KairoAiException('The secure connection was refused.');
    } finally {
      client.close();
    }
  }

  /// Where to POST, tolerating a trailing slash and a URL that already names
  /// the endpoint.
  static Uri? _endpointFor(String baseUrl) {
    final String trimmed = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    final Uri? uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return null;
    }
    return uri.path.endsWith('/chat/completions')
        ? uri
        : uri.replace(path: '${uri.path}/chat/completions');
  }

  static String _explain(int status, AiSettings settings) {
    switch (status) {
      case HttpStatus.unauthorized:
      case HttpStatus.forbidden:
        return settings.apiKey.isEmpty
            ? 'That service wants an API key.'
            : 'That service refused the API key.';
      case HttpStatus.notFound:
        return 'Nothing is served at that address. Check the base URL ends '
            'with /v1.';
      case HttpStatus.tooManyRequests:
        return 'That service is rate limiting Kairo. Try again later.';
      default:
        return 'The model answered with an error ($status).';
    }
  }

  static String _textFrom(String body, int maxCharacters) {
    final Object? decoded = jsonDecode(body);
    final Object? choices =
        decoded is Map<String, Object?> ? decoded['choices'] : null;
    final Object? first =
        choices is List<Object?> && choices.isNotEmpty ? choices.first : null;
    final Object? message =
        first is Map<String, Object?> ? first['message'] : null;
    final Object? content =
        message is Map<String, Object?> ? message['content'] : null;

    if (content is! String) {
      throw const KairoAiException(
        'The reply was not in a format Kairo understands.',
      );
    }

    final String line = _tidy(content, maxCharacters);
    if (line.isEmpty) {
      throw const KairoAiException('The model replied with nothing.');
    }
    return line;
  }

  static String _tidy(String content, int maxCharacters) {
    String line = content.trim().replaceAll(RegExp(r'\s+'), ' ');

    // Repeatedly: stripping quotes can expose a full stop that was outside
    // them, which the next pass then has to consider.
    while (line.length > 1 &&
        (line.startsWith('"') && line.endsWith('"') ||
            line.startsWith("'") && line.endsWith("'"))) {
      line = line.substring(1, line.length - 1).trim();
    }

    if (line.length <= maxCharacters) {
      return line;
    }

    // Cut at a word, unless the first word alone already runs past the limit.
    final int lastSpace = line.lastIndexOf(' ', maxCharacters);
    return '${line.substring(0, lastSpace < 40 ? maxCharacters : lastSpace)}…';
  }
}
