/// Fuel grades the user can search by. `code` is the Fuel Finder API value.
/// The live API sends upper-case codes (B7_STANDARD) although its docs show B7_Standard,
/// so codes are always compared upper-cased.
enum FuelType {
  e10('E10', 'Unleaded', 'E10'),
  e5('E5', 'Super unleaded', 'E5'),
  diesel('B7_STANDARD', 'Diesel', 'B7'),
  premiumDiesel('B7_PREMIUM', 'Premium diesel', 'B7+');

  const FuelType(this.code, this.label, this.shortLabel);
  final String code;
  final String label;
  final String shortLabel;

  static FuelType fromCode(String? code) => values.firstWhere((f) => f.code == code?.toUpperCase(), orElse: () => e10);

  /// Label for any API code, including grades not in this enum (B10, HVO).
  static String labelFor(String code) {
    for (final f in values) {
      if (f.code == code.toUpperCase()) return f.label;
    }
    return code.replaceAll('_', ' ');
  }
}
