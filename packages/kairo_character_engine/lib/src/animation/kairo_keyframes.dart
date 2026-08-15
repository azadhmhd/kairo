import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

/// One value the character holds at one moment of a cycle.
@immutable
class KairoStop {
  /// Holds [value] at [at], a fraction of the cycle from 0 to 1.
  const KairoStop(this.at, this.value);

  /// Where in the cycle this stop sits, from 0 to 1.
  final double at;

  /// The value at that moment.
  final double value;
}

/// One value moving through a cycle: an angle, a shift, a scale or an opacity.
///
/// The character sheet writes every motion as a short list of moments and the
/// value at each — a stride is 22° one way at the start, 22° the other at the
/// halfway point, and back. This is that list, and [at] reads a value out of
/// it. Every animation in the rig is built from these.
@immutable
class KairoTrack {
  /// A track through the given [stops], which must be ordered and must span
  /// the whole cycle.
  const KairoTrack(
    this.stops, {
    this.curve = Curves.easeInOut,
    this.cycles = 1,
    this.delay = 0,
  }) : assert(cycles >= 1, 'a track runs at least once per cycle');

  /// A track that leaves [from], reaches [to] halfway, and returns.
  ///
  /// Almost every motion in the rig is this shape: a swing, a nod, a breath.
  KairoTrack.swing(
    double from,
    double to, {
    this.curve = Curves.easeInOut,
    this.cycles = 1,
    this.delay = 0,
  }) : stops = <KairoStop>[
         KairoStop(0, from),
         KairoStop(0.5, to),
         KairoStop(1, from),
       ];

  /// The moments this track passes through.
  final List<KairoStop> stops;

  /// How the value moves between one stop and the next.
  final Curve curve;

  /// How many times this track repeats inside one turn of its animation.
  ///
  /// Not every part of an animation shares a period: the character's arm waves
  /// twice for each tilt of its head. Rather than run a clock per part, the
  /// shorter motion states how many times it fits inside the longer one.
  final int cycles;

  /// How far into the cycle this track starts, from 0 to 1.
  ///
  /// Used to stagger pieces that are otherwise identical, such as the three
  /// dots of a thought or the eight pieces of confetti.
  final double delay;

  /// The value at [time], a position in the cycle from 0 to 1.
  ///
  /// [time] may be any number; it wraps, so a clock that only ever counts
  /// upwards can be handed straight to it.
  double at(double time) {
    final double position = ((time * cycles) - delay) % 1.0;
    for (int i = 0; i < stops.length - 1; i++) {
      final KairoStop from = stops[i];
      final KairoStop to = stops[i + 1];
      if (position > to.at) {
        continue;
      }
      final double span = to.at - from.at;
      if (span <= 0) {
        return to.value;
      }
      final double progress = curve.transform(
        ((position - from.at) / span).clamp(0.0, 1.0),
      );
      return from.value + (to.value - from.value) * progress;
    }
    return stops.last.value;
  }
}
