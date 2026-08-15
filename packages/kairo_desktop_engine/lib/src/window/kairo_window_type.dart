/// What a window is for.
///
/// A type describes purpose; a `KairoWindowId` identifies one instance of it.
/// Kairo has one dashboard but may have two reminder popups at once, so the two
/// cannot be the same value.
enum KairoWindowType {
  /// The dashboard. Opened at startup, and there is only ever one.
  main,

  /// The character's transparent stage. Reserved for Milestone 4.
  character,

  /// A reminder popup. Several may exist at once, one per due reminder.
  reminder,

  /// The settings window. Reserved for Milestone 9.
  settings,
}
