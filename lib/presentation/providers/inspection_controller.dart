import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_flutter_verificarlo/data/repositories/report_repository.dart';

final reportRepositoryProvider = Provider((_) => ReportRepository());

class InspectionState {
  final Map<String, dynamic>? report;
  final bool isLoading;
  final String? error;
  final int currentTab;

  const InspectionState({
    this.report,
    this.isLoading = false,
    this.error,
    this.currentTab = 0,
  });

  InspectionState copyWith({
    Map<String, dynamic>? report,
    bool? isLoading,
    String? error,
    int? currentTab,
  }) =>
      InspectionState(
        report: report ?? this.report,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        currentTab: currentTab ?? this.currentTab,
      );
}

class InspectionNotifier extends StateNotifier<InspectionState> {
  final ReportRepository _repo;
  final int reportId;

  InspectionNotifier(this._repo, this.reportId) : super(const InspectionState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _repo.getReport(reportId);
      state = state.copyWith(report: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setTab(int index) => state = state.copyWith(currentTab: index);

  Future<void> registerPlate(int inspectionId, String plate) async {
    await _repo.registerPlate(inspectionId, plate);
    await load();
  }

  Future<void> completeReport(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repo.completeReport(reportId, data);
      await load();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final inspectionProvider =
    StateNotifierProvider.family<InspectionNotifier, InspectionState, int>(
  (ref, reportId) => InspectionNotifier(ref.read(reportRepositoryProvider), reportId),
);
