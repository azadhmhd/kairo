import 'package:flutter/foundation.dart';

/// Where Kairo writes its coaching messages, when the user has asked for any.
@immutable
class AiSettings {
  const AiSettings({
    this.enabled = false,
    this.baseUrl = ollamaBaseUrl,
    this.model = '',
    this.apiKey = '',
    this.reportInterval = defaultReportInterval,
  });

  static const AiSettings defaults = AiSettings();
  static const String ollamaBaseUrl = 'http://localhost:11434/v1';
  static const String lmStudioBaseUrl = 'http://localhost:1234/v1';
  static const Duration defaultReportInterval = Duration(hours: 24);

  /// The intervals the settings screen offers. The short ones are there so a
  /// new user can see what a summary looks like without waiting a day.
  static const List<Duration> reportIntervalChoices = <Duration>[
    Duration(minutes: 1),
    Duration(minutes: 5),
    Duration(hours: 1),
    Duration(hours: 3),
    Duration(hours: 9),
    Duration(hours: 12),
    Duration(hours: 24),
  ];

  final bool enabled;
  final String baseUrl;
  final String model;
  final String apiKey;
  final Duration reportInterval;

  bool get isUsable =>
      enabled && baseUrl.trim().isNotEmpty && model.trim().isNotEmpty;

  bool get isLocal {
    final Uri? uri = Uri.tryParse(baseUrl.trim());
    return uri != null &&
        const <String>{'localhost', '127.0.0.1', '::1', '0.0.0.0'}
            .contains(uri.host);
  }

  AiSettings copyWith({
    bool? enabled,
    String? baseUrl,
    String? model,
    String? apiKey,
    Duration? reportInterval,
  }) {
    return AiSettings(
      enabled: enabled ?? this.enabled,
      baseUrl: baseUrl ?? this.baseUrl,
      model: model ?? this.model,
      apiKey: apiKey ?? this.apiKey,
      reportInterval: reportInterval ?? this.reportInterval,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AiSettings &&
      other.enabled == enabled &&
      other.baseUrl == baseUrl &&
      other.model == model &&
      other.apiKey == apiKey &&
      other.reportInterval == reportInterval;

  @override
  int get hashCode =>
      Object.hash(enabled, baseUrl, model, apiKey, reportInterval);

  /// The key is omitted: errors are reported with the settings that caused them.
  @override
  String toString() => 'AiSettings(${enabled ? 'on' : 'off'}, $baseUrl, '
      '${model.isEmpty ? 'no model' : model}, '
      '${apiKey.isEmpty ? 'no key' : 'key set'})';
}
