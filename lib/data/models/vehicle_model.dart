class VehicleModel {
  final int id;
  final String brand;
  final String model;
  final int year;
  final String? plate;
  final int? mileage;

  VehicleModel({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    this.plate,
    this.mileage,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    // Handle nested brand/model from API
    final vehicle = json;
    String brand;
    String model;

    if (vehicle.containsKey('brand')) {
      brand = vehicle['brand'] as String;
      model = vehicle['model'] as String;
    } else if (vehicle.containsKey('vehicleBrand')) {
      brand = vehicle['vehicleBrand'] as String;
      model = vehicle['vehicleModel'] as String;
    } else {
      brand = '';
      model = '';
    }

    return VehicleModel(
      id: vehicle['id'] as int? ?? 0,
      brand: brand,
      model: model,
      year: vehicle['year'] as int? ?? vehicle['vehicleYear'] as int? ?? 0,
      plate: vehicle['plate'] as String? ?? vehicle['vehiclePlate'] as String?,
      mileage: vehicle['mileage'] as int?,
    );
  }

  String get displayName => '$brand $model $year';
}
