import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_flutter_verificarlo/data/models/checklist_models.dart';
import 'package:app_flutter_verificarlo/core/storage/local_storage.dart';
import 'package:app_flutter_verificarlo/core/services/sync_service.dart';

class ChecklistState {
  final Map<String, ItemResult> results;
  final bool isSaving;

  const ChecklistState({this.results = const {}, this.isSaving = false});

  ChecklistState copyWith({Map<String, ItemResult>? results, bool? isSaving}) =>
      ChecklistState(
        results: results ?? this.results,
        isSaving: isSaving ?? this.isSaving,
      );

  int countByStatus(List<InspectionItem> items, ItemStatus status) =>
      items.where((i) => results[i.id]?.status == status).length;

  int countCompleted(List<InspectionItem> items) =>
      items.where((i) => results[i.id]?.status != null).length;
}

class ChecklistNotifier extends StateNotifier<ChecklistState> {
  final int reportId;
  final Ref ref;
  Timer? _debounce;

  ChecklistNotifier(this.ref, this.reportId) : super(const ChecklistState()) {
    _loadLocal();
  }

  void _loadLocal() {
    final saved = LocalStorage.getChecklist(reportId);
    if (saved == null) return;
    final results = <String, ItemResult>{};
    for (final entry in saved.entries) {
      results[entry.key] = ItemResult.fromJson(entry.value as Map<String, dynamic>);
    }
    state = state.copyWith(results: results);
  }

  void setStatus(String itemId, ItemStatus? status) {
    final results = Map<String, ItemResult>.from(state.results);
    final existing = results[itemId] ?? ItemResult(itemId: itemId);
    existing.status = status;
    results[itemId] = existing;
    state = state.copyWith(results: results);
    _scheduleSave();
  }

  void setComment(String itemId, String comment) {
    final results = Map<String, ItemResult>.from(state.results);
    final existing = results[itemId] ?? ItemResult(itemId: itemId);
    existing.comment = comment;
    results[itemId] = existing;
    state = state.copyWith(results: results);
    _scheduleSave();
  }

  void toggleChip(String itemId, String chip) {
    final results = Map<String, ItemResult>.from(state.results);
    final existing = results[itemId] ?? ItemResult(itemId: itemId);
    if (existing.selectedChips.contains(chip)) {
      existing.selectedChips.remove(chip);
    } else {
      existing.selectedChips.add(chip);
    }
    results[itemId] = existing;
    state = state.copyWith(results: results);
    _scheduleSave();
  }

  void addPhoto(String itemId, String url) {
    final results = Map<String, ItemResult>.from(state.results);
    final existing = results[itemId] ?? ItemResult(itemId: itemId);
    if (existing.photoUrls.length >= 5) return; // max 5 per item
    existing.photoUrls.add(url);
    results[itemId] = existing;
    state = state.copyWith(results: results);
    _scheduleSave();
  }

  void removePhoto(String itemId, String url) {
    final results = Map<String, ItemResult>.from(state.results);
    final existing = results[itemId];
    if (existing == null) return;
    existing.photoUrls.remove(url);
    results[itemId] = existing;
    state = state.copyWith(results: results);
    _scheduleSave();
  }

  void setAllOk(List<InspectionItem> items) {
    final results = Map<String, ItemResult>.from(state.results);
    for (final item in items) {
      final existing = results[item.id] ?? ItemResult(itemId: item.id);
      if (existing.status == null) {
        existing.status = ItemStatus.ok;
        results[item.id] = existing;
      }
    }
    state = state.copyWith(results: results);
    _scheduleSave();
  }

  void _scheduleSave() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _save);
  }

  Future<void> _save() async {
    final data = state.results.map((k, v) => MapEntry(k, v.toJson()));
    await LocalStorage.saveChecklist(reportId, data);
    // ponytail: sync to server happens at finalize, not per-keystroke — reportId isn't known until POST /api/reports
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final checklistProvider =
    StateNotifierProvider.family<ChecklistNotifier, ChecklistState, int>(
  (ref, reportId) => ChecklistNotifier(ref, reportId),
);
