/// The Kairo design system: colours, spacing, radii, shadows, type and theme.
library;

export 'src/colors/kairo_colors.dart';
export 'src/radius/kairo_radius.dart';
export 'src/shadows/kairo_shadows.dart';
export 'src/spacing/kairo_spacing.dart';
export 'src/theme/kairo_theme.dart';
export 'src/typography/kairo_typography.dart';
export 'src/widgets/kairo_card.dart';

// Primitives are exported for the values the semantic layer has no name for
// yet, such as animation durations. Prefer a semantic class when one exists.
export 'src/tokens/primitive_colors.dart';
export 'src/tokens/primitive_duration.dart';
export 'src/tokens/primitive_icon_size.dart';
export 'src/tokens/primitive_opacity.dart';
export 'src/tokens/primitive_radius.dart';
export 'src/tokens/primitive_spacing.dart';
