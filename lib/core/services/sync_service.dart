import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_flutter_verificarlo/core/storage/local_storage.dart';
import 'package:app_flutter_verificarlo/data/repositories/report_repository.dart';

enum SyncStatus { idle, syncing, error }

class SyncState {
  final SyncStatus status;
  final int pendingCount;

  const SyncState({this.status = SyncStatus.idle, this.pendingCount = 0});

  SyncState copyWith({SyncStatus? status, int? pendingCount}) => SyncState(
        status: status ?? this.status,
        pendingCount: pendingCount ?? this.pendingCount,
      );
}

class SyncNotifier extends StateNotifier<SyncState> {
  final ReportRepository _repo;

  SyncNotifier(this._repo) : super(const SyncState()) {
    _processPending();
  }

  Future<void> _processPending() async {
    final ops = LocalStorage.getPendingOps();
    if (ops.isEmpty) return;

    state = state.copyWith(status: SyncStatus.syncing, pendingCount: ops.length);

    try {
      for (final op in ops) {
        final reportId = op['reportId'] as int;
        final sections = op['sections'] as Map<String, dynamic>;
        await _repo.patchSections(reportId, sections);
      }
      await LocalStorage.clearQueue();
      state = const SyncState(status: SyncStatus.idle, pendingCount: 0);
    } catch (_) {
      state = state.copyWith(status: SyncStatus.error);
    }
  }

  Future<void> retry() => _processPending();

  Future<void> enqueueAndSync(int reportId, Map<String, dynamic> sections) async {
    try {
      state = state.copyWith(status: SyncStatus.syncing);
      await _repo.patchSections(reportId, sections);
      state = state.copyWith(status: SyncStatus.idle);
    } catch (_) {
      // Offline — queue it
      await LocalStorage.enqueue({'reportId': reportId, 'sections': sections});
      state = state.copyWith(
        status: SyncStatus.error,
        pendingCount: LocalStorage.getPendingOps().length,
      );
    }
  }
}

final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  return SyncNotifier(ReportRepository());
});
