import 'package:flutter/foundation.dart';

/// Something that happened, which other features may care about.
///
/// Events are facts in the past tense — `KairoWindowOpened`, not
/// `OpenKairoWindow`. A publisher never learns who listened.
///
/// Events must be immutable: a subscriber may hold one indefinitely.
@immutable
abstract class KairoEvent {
  /// Creates an event.
  const KairoEvent();
}
