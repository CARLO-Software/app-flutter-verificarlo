import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_flutter_verificarlo/data/models/booking_model.dart';
import 'package:app_flutter_verificarlo/data/repositories/inspection_repository.dart';

final inspectionRepositoryProvider = Provider((_) => InspectionRepository());

final pendingInspectionsProvider =
    FutureProvider.autoDispose<List<BookingModel>>((ref) async {
  return ref.read(inspectionRepositoryProvider).getPendingInspections();
});

final completedInspectionsProvider =
    FutureProvider.autoDispose<List<BookingModel>>((ref) async {
  return ref.read(inspectionRepositoryProvider).getCompletedInspections();
});
