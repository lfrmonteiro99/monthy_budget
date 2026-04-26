/// Calm spacing scale.
///
/// Use these instead of magic numbers in `SizedBox`, `EdgeInsets`, and gap
/// constants. The 4 → 32 ramp matches the Calm handoff (§3.6 spacing).
class CalmSpacing {
  CalmSpacing._();

  /// 4 dp — hairline gap, between an icon and a tight label.
  static const double xxs = 4;

  /// 8 dp — between adjacent micro elements (label / value, chip / chip).
  static const double xs = 8;

  /// 12 dp — default vertical padding for list rows; gap between fields.
  static const double s = 12;

  /// 16 dp — gap between a section header and its content.
  static const double m = 16;

  /// 20 dp — default `CalmCard` / `CalmScaffold` horizontal padding.
  static const double l = 20;

  /// 24 dp — gap between unrelated sections inside a screen.
  static const double xl = 24;

  /// 32 dp — gap above an empty-state, between hero and first section.
  static const double xxl = 32;
}
