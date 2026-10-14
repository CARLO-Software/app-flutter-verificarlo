import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_flutter_verificarlo/data/models/booking_model.dart';
import 'package:app_flutter_verificarlo/data/repositories/schedule_repository.dart';

final scheduleRepositoryProvider = Provider((_) => ScheduleRepository());

class ScheduleState {
  final List<BookingModel> bookings;
  final DateTime selectedDate;
  final bool isLoading;
  final String? error;

  ScheduleState({
    this.bookings = const [],
    DateTime? selectedDate,
    this.isLoading = false,
    this.error,
  }) : selectedDate = selectedDate ?? DateTime.now();

  ScheduleState copyWith({
    List<BookingModel>? bookings,
    DateTime? selectedDate,
    bool? isLoading,
    String? error,
  }) =>
      ScheduleState(
        bookings: bookings ?? this.bookings,
        selectedDate: selectedDate ?? this.selectedDate,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class ScheduleNotifier extends StateNotifier<ScheduleState> {
  final ScheduleRepository _repo;

  ScheduleNotifier(this._repo) : super(ScheduleState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final date = '${state.selectedDate.year}-${state.selectedDate.month.toString().padLeft(2, '0')}-${state.selectedDate.day.toString().padLeft(2, '0')}';
      final all = await _repo.getSchedule(date: date);
      final selected = DateTime(state.selectedDate.year, state.selectedDate.month, state.selectedDate.day);
      final filtered = all.where((b) {
        final d = DateTime(b.startTime.year, b.startTime.month, b.startTime.day);
        return d == selected;
      }).toList();
      state = state.copyWith(bookings: filtered, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
    load();
  }
}

final scheduleProvider =
    StateNotifierProvider<ScheduleNotifier, ScheduleState>((ref) {
  return ScheduleNotifier(ref.read(scheduleRepositoryProvider));
});
