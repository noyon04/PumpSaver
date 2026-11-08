/// Fuel grades the user can search by. `code` is the Fuel Finder API value.
enum FuelType {
  e10('E10', 'Unleaded', 'E10'),
  e5('E5', 'Super unleaded', 'E5'),
  diesel('B7_Standard', 'Diesel', 'B7'),
  premiumDiesel('B7_Premium', 'Premium diesel', 'B7+');

  const FuelType(this.code, this.label, this.shortLabel);
  final String code;
  final String label;
  final String shortLabel;

  static FuelType fromCode(String? code) => values.firstWhere((f) => f.code == code, orElse: () => e10);

  /// Label for any API code, including grades not in this enum (B10, HVO).
  static String labelFor(String code) {
    for (final f in values) {
      if (f.code == code) return f.label;
    }
    return code.replaceAll('_', ' ');
  }
}
