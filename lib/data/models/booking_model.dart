// ponytail: fuerza UTC cuando el backend omite la Z
DateTime _parseUtc(String s) =>
    DateTime.parse(s.endsWith('Z') ? s : '${s}Z').toLocal();

class BookingModel {
  final int id;
  final String status;
  final String date;
  final String timeSlot;
  final DateTime startTime;

  // Vehicle
  final String vehicleBrand;
  final String vehicleModel;
  final int vehicleYear;
  final String? vehiclePlate;

  // Client
  final String clientName;
  final String? clientPhone;
  final String? clientEmail;
  final String? address;
  final String? district;

  // Plan
  final String planTitle;
  final String planType;

  // Report (if exists)
  final int? reportId;
  final String? reportStatus;
  final String? completedAt;

  // Vehicle inspection
  final int? vehicleInspectionId;
  final String? mechanicalStatus;

  BookingModel({
    required this.id,
    required this.status,
    required this.date,
    required this.timeSlot,
    required this.startTime,
    required this.vehicleBrand,
    required this.vehicleModel,
    required this.vehicleYear,
    this.vehiclePlate,
    required this.clientName,
    this.clientPhone,
    this.clientEmail,
    this.address,
    this.district,
    required this.planTitle,
    required this.planType,
    this.reportId,
    this.reportStatus,
    this.completedAt,
    this.vehicleInspectionId,
    this.mechanicalStatus,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final vehicle = json['vehicle'] as Map<String, dynamic>?;
    final client = json['client'] as Map<String, dynamic>?;
    final plan = json['inspectionPlan'] as Map<String, dynamic>?;
    final report = json['report'] as Map<String, dynamic>?;
    final inspection = json['vehicleInspection'] as Map<String, dynamic>?;

    // Handle nested model > brand
    String brand = '';
    String model = '';
    if (vehicle != null) {
      final modelData = vehicle['model'] as Map<String, dynamic>?;
      if (modelData != null) {
        final brandData = modelData['brand'] as Map<String, dynamic>?;
        brand = brandData?['name'] as String? ?? '';
        model = modelData['name'] as String? ?? '';
      }
      // Flat format fallback
      brand = brand.isEmpty ? (vehicle['brand'] as String? ?? '') : brand;
      model = model.isEmpty ? (vehicle['modelName'] as String? ?? '') : model;
    }

    return BookingModel(
      id: json['id'] as int,
      status: json['status'] as String? ?? 'PAID',
      date: json['date'] as String? ?? '',
      timeSlot: json['timeSlot'] as String? ?? '',
      startTime: _parseUtc(json['startTime'] as String),
      vehicleBrand: brand,
      vehicleModel: model,
      vehicleYear: vehicle?['year'] as int? ?? 0,
      vehiclePlate: vehicle?['plate'] as String?,
      clientName: client?['name'] as String? ?? '',
      clientPhone: client?['phone'] as String?,
      clientEmail: client?['email'] as String?,
      address: client?['address'] as String?,
      district: client?['district'] as String?,
      planTitle: plan?['title'] as String? ?? '',
      planType: plan?['type'] as String? ?? '',
      reportId: report?['id'] as int?,
      reportStatus: report?['overallStatus'] as String?,
      completedAt: report?['completedAt'] as String?,
      vehicleInspectionId: inspection?['id'] as int?,
      mechanicalStatus: inspection?['mechanicalStatus'] as String?,
    );
  }

  bool get isFinalized => completedAt != null;

  String get vehicleDisplay => '$vehicleBrand $vehicleModel $vehicleYear';

  String get code {
    final year = startTime.year;
    return '#INS-$year-${id.toString().padLeft(4, '0')}';
  }

  String get timeDisplay {
    final hour = startTime.hour;
    final minute = startTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final h12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$h12:$minute $period';
  }

  bool get isUrgent {
    final now = DateTime.now();
    return startTime.difference(now).inMinutes < 60 &&
        startTime.isAfter(now);
  }
}
