import 'package:flutter/material.dart';
import 'package:kairo_shared_models/shared_models.dart';

/// The icon that stands for [kind].
IconData iconForKind(ReminderKind kind) {
  switch (kind) {
    case ReminderKind.water:
      return Icons.local_drink_outlined;
    case ReminderKind.stand:
      return Icons.accessibility_new_outlined;
    case ReminderKind.eyes:
      return Icons.visibility_outlined;
    case ReminderKind.custom:
      return Icons.favorite_outline;
  }
}

/// How often a reminder repeats, in words.
String describeInterval(Duration interval) {
  if (interval.inMinutes < 60) {
    return 'every ${interval.inMinutes} min';
  }

  final int hours = interval.inHours;
  final int minutes = interval.inMinutes % 60;
  final String hourPart = hours == 1 ? 'every hour' : 'every $hours hours';
  return minutes == 0 ? hourPart : '$hourPart $minutes min';
}

/// How long until something happens, in words. Rounds down to whole minutes;
/// anything under one reads as "any moment now" rather than counting seconds.
String describeTimeUntil(DateTime moment, DateTime now) {
  final Duration remaining = moment.difference(now);
  if (remaining.inMinutes < 1) {
    return 'any moment now';
  }
  if (remaining.inMinutes < 60) {
    return 'in ${remaining.inMinutes} min';
  }

  final int hours = remaining.inHours;
  final int minutes = remaining.inMinutes % 60;
  return minutes == 0 ? 'in $hours h' : 'in $hours h $minutes min';
}
