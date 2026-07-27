import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:app_flutter_verificarlo/core/constants/app_colors.dart';
import 'package:app_flutter_verificarlo/data/models/notification_model.dart';
import 'package:app_flutter_verificarlo/presentation/providers/notification_provider.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          if (state.unreadCount > 0)
            TextButton(
              onPressed: () => ref.read(notificationProvider.notifier).markAllRead(),
              child: const Text('Leer todas', style: TextStyle(color: AppColors.primary)),
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.items.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 64, color: AppColors.textSecondary),
                      SizedBox(height: 16),
                      Text('Sin notificaciones', style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => ref.read(notificationProvider.notifier).load(),
                  child: ListView.builder(
                    itemCount: state.items.length,
                    itemBuilder: (_, i) {
                      // Insert group headers
                      final item = state.items[i];
                      final showHeader = i == 0 || _groupLabel(state.items[i - 1]) != _groupLabel(item);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showHeader)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Text(
                                _groupLabel(item),
                                style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary, fontSize: 13),
                              ),
                            ),
                          Dismissible(
                            key: ValueKey(item.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: AppColors.error,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) => ref.read(notificationProvider.notifier).delete(item.id),
                            child: ListTile(
                              leading: Icon(
                                _iconForType(item.type),
                                color: item.isRead ? AppColors.textSecondary : AppColors.primary,
                              ),
                              title: Text(
                                item.title,
                                style: TextStyle(
                                  fontWeight: item.isRead ? FontWeight.normal : FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(item.message, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                              trailing: Text(
                                DateFormat.Hm().format(item.createdAt),
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                              onTap: () {
                                ref.read(notificationProvider.notifier).markRead(item.id);
                                if (item.reportId != null) {
                                  context.push('/inspection/${item.reportId}');
                                }
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
    );
  }

  String _groupLabel(NotificationModel n) {
    final now = DateTime.now();
    final diff = now.difference(n.createdAt);
    if (diff.inMinutes < 60) return 'Próxima hora';
    if (diff.inHours < 24 && now.day == n.createdAt.day) return 'Hoy';
    if (diff.inDays < 7) return 'Esta semana';
    return 'Anteriores';
  }

  IconData _iconForType(String type) => switch (type) {
        'BOOKING_NEW' => Icons.calendar_today,
        'BOOKING_CANCELLED' => Icons.cancel,
        'REPORT_APPROVED' => Icons.check_circle,
        _ => Icons.notifications,
      };
}
