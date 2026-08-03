import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_flutter_verificarlo/data/models/booking_model.dart';
import 'package:app_flutter_verificarlo/data/repositories/inspection_repository.dart';

final inspectionRepositoryProvider = Provider((_) => InspectionRepository());

// ponytail: polling each 15s, switch to websocket if scale demands it
final pendingInspectionsProvider =
    AutoDisposeAsyncNotifierProvider<_PendingNotifier, List<BookingModel>>(
        _PendingNotifier.new);

class _PendingNotifier extends AutoDisposeAsyncNotifier<List<BookingModel>> {
  Timer? _timer;

  @override
  Future<List<BookingModel>> build() async {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _refresh());
    ref.onDispose(() => _timer?.cancel());
    return ref.read(inspectionRepositoryProvider).getPendingInspections();
  }

  Future<void> _refresh() async {
    state = const AsyncLoading<List<BookingModel>>().copyWithPrevious(state);
    state = await AsyncValue.guard(
        () => ref.read(inspectionRepositoryProvider).getPendingInspections());
  }
}

final completedInspectionsProvider =
    AutoDisposeAsyncNotifierProvider<_CompletedNotifier, List<BookingModel>>(
        _CompletedNotifier.new);

class _CompletedNotifier extends AutoDisposeAsyncNotifier<List<BookingModel>> {
  Timer? _timer;

  @override
  Future<List<BookingModel>> build() async {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _refresh());
    ref.onDispose(() => _timer?.cancel());
    return ref.read(inspectionRepositoryProvider).getCompletedInspections();
  }

  Future<void> _refresh() async {
    state = const AsyncLoading<List<BookingModel>>().copyWithPrevious(state);
    state = await AsyncValue.guard(
        () => ref.read(inspectionRepositoryProvider).getCompletedInspections());
  }
}
