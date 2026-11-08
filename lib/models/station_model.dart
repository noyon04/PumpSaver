/// A forecourt from the Fuel Finder API (PFS info merged with its fuel_prices).
class StationModel {
  StationModel({
    required this.nodeId,
    this.tradingName,
    this.brandName,
    this.isMotorway = false,
    this.isSupermarket = false,
    this.isClosed = false,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.postcode,
    required this.latitude,
    required this.longitude,
    this.amenities = const [],
    this.openingTimes = const {},
    this.fuelPrices = const [],
  });

  final String nodeId;
  final String? tradingName;
  final String? brandName;
  final bool isMotorway;
  final bool isSupermarket;
  final bool isClosed;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? postcode;
  final double latitude;
  final double longitude;
  final List<String> amenities;

  /// Keyed by lower-case day name: monday ... sunday.
  final Map<String, OpeningHoursModel> openingTimes;
  final List<FuelPriceModel> fuelPrices;

  /// Trading name tells same-brand stations apart ("Tesco Camden" vs "Tesco Brixton").
  String get displayName => tradingName ?? brandName ?? 'Unknown station';

  String get address => [addressLine1, addressLine2, city, postcode].where((s) => s != null && s.isNotEmpty).join(', ');

  FuelPriceModel? priceFor(String fuelCode) {
    for (final p in fuelPrices) {
      if (p.fuelType == fuelCode) return p;
    }
    return null;
  }

  factory StationModel.fromJson(Map<String, dynamic> json) {
    final location = (json['location'] as Map<String, dynamic>?) ?? const {};
    final usualDays = ((json['opening_times'] as Map<String, dynamic>?)?['usual_days'] as Map<String, dynamic>?) ?? const {};

    return StationModel(
      nodeId: json['node_id'] as String,
      tradingName: json['trading_name'] as String?,
      brandName: json['brand_name'] as String?,
      isMotorway: json['is_motorway_service_station'] == true,
      isSupermarket: json['is_supermarket_service_station'] == true,
      isClosed: json['temporary_closure'] == true || json['permanent_closure'] == true,
      addressLine1: location['address_line_1'] as String?,
      addressLine2: location['address_line_2'] as String?,
      city: location['city'] as String?,
      postcode: location['postcode'] as String?,
      latitude: (location['latitude'] as num).toDouble(),
      longitude: (location['longitude'] as num).toDouble(),
      amenities: List<String>.from(json['amenities'] ?? const []),
      openingTimes: usualDays.map((day, v) => MapEntry(day, OpeningHoursModel.fromJson(v as Map<String, dynamic>))),
      fuelPrices: ((json['fuel_prices'] as List?) ?? const []).map((x) => FuelPriceModel.fromJson(x as Map<String, dynamic>)).toList(),
    );
  }
}

class FuelPriceModel {
  FuelPriceModel({required this.fuelType, required this.price, this.lastUpdated});

  final String fuelType;

  /// Pence per litre, e.g. 139.9
  final double price;
  final DateTime? lastUpdated;

  factory FuelPriceModel.fromJson(Map<String, dynamic> json) => FuelPriceModel(
        fuelType: json['fuel_type'] as String,
        price: (json['price'] as num).toDouble(),
        lastUpdated: DateTime.tryParse(json['price_last_updated'] as String? ?? ''),
      );
}

class OpeningHoursModel {
  OpeningHoursModel({this.open, this.close, this.is24Hours = false});

  final String? open;
  final String? close;
  final bool is24Hours;

  String get label => is24Hours ? 'Open 24 hours' : '${open ?? '?'} – ${close ?? '?'}';

  factory OpeningHoursModel.fromJson(Map<String, dynamic> json) => OpeningHoursModel(
        open: json['open'] as String?,
        close: json['close'] as String?,
        is24Hours: json['is_24_hours'] == true,
      );
}
