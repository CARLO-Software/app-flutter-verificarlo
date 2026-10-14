import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app_flutter_verificarlo/core/constants/app_colors.dart';
import 'package:app_flutter_verificarlo/data/models/booking_model.dart';
import 'package:app_flutter_verificarlo/data/models/notification_model.dart';
import 'package:app_flutter_verificarlo/presentation/providers/dashboard_provider.dart';
import 'package:app_flutter_verificarlo/presentation/providers/notification_provider.dart';

const _carloColor = Color(0xFF7B1FA2);

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
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: state.items.length,
                    itemBuilder: (_, i) {
                      final item = state.items[i];
                      final showHeader = i == 0 || _groupLabel(state.items[i - 1]) != _groupLabel(item);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showHeader)
                            Padding(
                              padding: const EdgeInsets.only(top: 12, bottom: 8),
                              child: Text(
                                _groupLabel(item),
                                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary, fontSize: 13),
                              ),
                            ),
                          _NotificationCard(item: item),
                        ],
                      );
                    },
                  ),
                ),
    );
  }

  String _groupLabel(NotificationModel n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nDate = DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);
    final diff = today.difference(nDate).inDays;

    if (diff == 0) return 'Hoy';
    if (diff == 1) return 'Ayer';
    if (diff < 7) return 'Esta semana';
    return 'Anteriores';
  }
}

class _NotificationCard extends ConsumerWidget {
  final NotificationModel item;
  const _NotificationCard({required this.item});

  static const _typeConfig = <String, ({IconData icon, Color color, String label})>{
    'BOOKING_NEW': (icon: Icons.calendar_today, color: Color(0xFF1976D2), label: 'Nueva inspección'),
    'BOOKING_CANCELLED': (icon: Icons.cancel, color: AppColors.error, label: 'Cancelación'),
    'REPORT_APPROVED': (icon: Icons.check_circle, color: AppColors.success, label: 'Aprobado'),
    'BOOKING_RESCHEDULED': (icon: Icons.schedule, color: AppColors.warning, label: 'Reagendado'),
    'INSPECTION_REMINDER': (icon: Icons.alarm, color: AppColors.warning, label: 'Recordatorio'),
  };

  ({IconData icon, Color color, String label}) get _config =>
      _typeConfig[item.type] ?? (icon: Icons.notifications, color: AppColors.textSecondary, label: 'Notificación');

  BookingModel? _findBooking(WidgetRef ref) {
    final id = item.bookingId;
    if (id == null) return null;
    final pending = ref.read(pendingInspectionsProvider).valueOrNull ?? [];
    final completed = ref.read(completedInspectionsProvider).valueOrNull ?? [];
    for (final b in [...pending, ...completed]) {
      if (b.id == id) return b;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = _config;
    final booking = _findBooking(ref);
    final hasAction = booking != null;
    final isCarlo = booking?.isFromCarlo ?? false;
    final timeAgo = _timeAgo(item.createdAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        elevation: item.isRead ? 0 : 1,
        color: item.isRead ? Colors.grey.shade50 : Colors.white,
        child: InkWell(
          onTap: () {
            ref.read(notificationProvider.notifier).markRead(item.id);
            if (booking != null) {
              context.push('/inspection/${booking.id}', extra: booking);
            }
          },
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 4, color: config.color),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: icon + type label + time ago
                        Row(
                          children: [
                            Icon(config.icon, size: 18, color: config.color),
                            const SizedBox(width: 8),
                            Text(
                              config.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: config.color,
                              ),
                            ),
                            const Spacer(),
                            if (isCarlo) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: _carloColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: const Text('CARLO', style: TextStyle(color: _carloColor, fontSize: 9, fontWeight: FontWeight.w800)),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(timeAgo, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Title
                        Text(
                          item.title,
                          style: TextStyle(
                            fontWeight: item.isRead ? FontWeight.w500 : FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),

                        // Message
                        Text(
                          item.message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),

                        // Booking context (if we have it in memory)
                        if (booking != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.directions_car, size: 13, color: AppColors.textSecondary),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              booking.vehicleDisplay,
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (booking.vehiclePlate != null) ...[
                                            const SizedBox(width: 6),
                                            Text(
                                              booking.vehiclePlate!,
                                              style: const TextStyle(fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time, size: 13, color: AppColors.textSecondary),
                                          const SizedBox(width: 4),
                                          Text(booking.timeDisplay, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                          if (booking.district != null) ...[
                                            const Text(' · ', style: TextStyle(color: AppColors.textSecondary)),
                                            const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textSecondary),
                                            const SizedBox(width: 2),
                                            Expanded(
                                              child: Text(
                                                booking.district!,
                                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
                              ],
                            ),
                          ),
                        ],

                        // Action hint when no booking found but has ID
                        if (!hasAction && item.bookingId != null) ...[
                          const SizedBox(height: 6),
                          const Text(
                            'Inspección no disponible en caché',
                            style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Unread indicator
                if (!item.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'ahora';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'hace ${diff.inHours}h';
    if (diff.inDays < 7) return 'hace ${diff.inDays}d';
    return '${dt.day}/${dt.month}';
  }
}
