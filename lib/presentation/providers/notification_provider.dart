import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_flutter_verificarlo/data/models/notification_model.dart';
import 'package:app_flutter_verificarlo/data/repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider((_) => NotificationRepository());

class NotificationState {
  final List<NotificationModel> items;
  final bool isLoading;
  final String? error;

  const NotificationState({this.items = const [], this.isLoading = false, this.error});

  int get unreadCount => items.where((n) => !n.isRead).length;

  NotificationState copyWith({List<NotificationModel>? items, bool? isLoading, String? error}) =>
      NotificationState(
        items: items ?? this.items,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationRepository _repo;
  Timer? _pollTimer;

  NotificationNotifier(this._repo) : super(const NotificationState()) {
    load();
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) => load());
  }

  Future<void> load() async {
    try {
      final items = await _repo.getAll();
      if (mounted) state = state.copyWith(items: items, isLoading: false, error: null);
    } catch (e) {
      if (mounted) state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> markRead(int id) async {
    await _repo.markRead(id);
    state = state.copyWith(
      items: state.items.map((n) {
        if (n.id == id) {
          return NotificationModel(
            id: n.id, type: n.type, title: n.title, message: n.message,
            isRead: true, createdAt: n.createdAt,
            bookingId: n.bookingId, reportId: n.reportId,
          );
        }
        return n;
      }).toList(),
    );
  }

  Future<void> markAllRead() async {
    await _repo.markAllRead();
    await load();
  }

  Future<void> delete(int id) async {
    await _repo.delete(id);
    state = state.copyWith(items: state.items.where((n) => n.id != id).toList());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier(ref.read(notificationRepositoryProvider));
});
