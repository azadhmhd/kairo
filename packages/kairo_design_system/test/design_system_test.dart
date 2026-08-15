import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kairo_design_system/design_system.dart';

void main() {
  test('semantic colours resolve to the approved palette', () {
    expect(KairoColors.primary, PrimitiveColors.green500);
    expect(KairoColors.secondary, PrimitiveColors.blue500);
    expect(KairoColors.background, PrimitiveColors.warmWhite);
    expect(KairoColors.surface, PrimitiveColors.white);
    expect(KairoColors.border, PrimitiveColors.neutral200);
  });

  test('theme is wired to the semantic colours', () {
    final ThemeData theme = KairoTheme.light;

    expect(theme.colorScheme.primary, KairoColors.primary);
    expect(theme.colorScheme.brightness, Brightness.light);
    expect(theme.scaffoldBackgroundColor, KairoColors.background);
    expect(theme.dividerTheme.color, KairoColors.border);
    expect(theme.textTheme.bodyMedium?.color, KairoColors.textPrimary);
  });

  test('spacing and radius scales increase monotonically', () {
    const List<double> spacing = <double>[
      KairoSpacing.xxs,
      KairoSpacing.xs,
      KairoSpacing.sm,
      KairoSpacing.md,
      KairoSpacing.lg,
      KairoSpacing.xl,
      KairoSpacing.xxl,
      KairoSpacing.xxxl,
      KairoSpacing.huge,
    ];
    const List<double> radius = <double>[
      KairoRadius.none,
      KairoRadius.xs,
      KairoRadius.sm,
      KairoRadius.md,
      KairoRadius.lg,
      KairoRadius.xl,
      KairoRadius.xxl,
      KairoRadius.pill,
    ];

    for (final List<double> scale in <List<double>>[spacing, radius]) {
      for (int i = 1; i < scale.length; i++) {
        expect(scale[i], greaterThan(scale[i - 1]));
      }
    }
  });

  test('shadows are soft: wide blur, low opacity', () {
    for (final List<BoxShadow> shadows in <List<BoxShadow>>[
      KairoShadows.soft,
      KairoShadows.card,
      KairoShadows.floating,
    ]) {
      expect(shadows, isNotEmpty);
      for (final BoxShadow shadow in shadows) {
        expect(shadow.color.a, lessThanOrEqualTo(PrimitiveOpacity.soft));
        expect(shadow.blurRadius, greaterThan(shadow.offset.dy));
      }
    }
  });
}
