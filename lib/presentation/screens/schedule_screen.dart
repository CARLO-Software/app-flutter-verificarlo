import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:app_flutter_verificarlo/core/constants/app_colors.dart';
import 'package:app_flutter_verificarlo/data/models/booking_model.dart';
import 'package:app_flutter_verificarlo/presentation/providers/schedule_provider.dart';

const _carloColor = Color(0xFF7B1FA2);
const _verificarloColor = Color(0xFFFFD700);
const _urgentColor = Color(0xFFE53935);

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scheduleProvider);
    final pending = state.bookings.where((b) => !b.isFinalized).toList();
    final completed = state.bookings.where((b) => b.isFinalized).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Agenda')),
      body: Column(
        children: [
          _WeekSelector(
            selected: state.selectedDate,
            onChanged: (d) => ref.read(scheduleProvider.notifier).selectDate(d),
          ),
          const Divider(height: 1),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.bookings.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.event_available, size: 64, color: AppColors.textSecondary),
                            const SizedBox(height: 16),
                            Text(
                              'Sin inspecciones para ${DateFormat("d 'de' MMMM", 'es').format(state.selectedDate)}',
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => ref.read(scheduleProvider.notifier).load(),
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                          children: [
                            if (pending.isNotEmpty) ...[
                              _SectionHeader(
                                label: 'Pendientes',
                                count: pending.length,
                                color: AppColors.warning,
                              ),
                              for (final b in pending) _ScheduleCard(booking: b),
                            ],
                            if (completed.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              _SectionHeader(
                                label: 'Completadas',
                                count: completed.length,
                                color: AppColors.success,
                              ),
                              for (final b in completed) _ScheduleCard(booking: b),
                            ],
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SectionHeader({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
            child: Text('$count', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final BookingModel booking;
  const _ScheduleCard({required this.booking});

  Color get _accentColor {
    if (booking.isFinalized) return AppColors.success;
    if (booking.isUrgent) return _urgentColor;
    return booking.isFromCarlo ? _carloColor : _verificarloColor;
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor;
    final isCompleted = booking.isFinalized;
    final location = [booking.district, booking.address]
        .where((s) => s != null && s.isNotEmpty)
        .join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        elevation: isCompleted ? 0 : 1,
        color: isCompleted ? Colors.grey.shade50 : Colors.white,
        child: InkWell(
          onTap: () => context.push('/inspection/${booking.id}', extra: booking),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Accent bar
                Container(width: 5, color: accent),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1: time + badges
                        Row(
                          children: [
                            Text(
                              booking.timeDisplay,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
                              ),
                            ),
                            if (booking.isUrgent && !isCompleted) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _urgentColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('URGENTE', style: TextStyle(color: _urgentColor, fontSize: 9, fontWeight: FontWeight.w800)),
                              ),
                            ],
                            const Spacer(),
                            _SourceBadge(isFromCarlo: booking.isFromCarlo),
                            if (isCompleted) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.check_circle, size: 20, color: AppColors.success),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Row 2: vehicle + plate
                        Row(
                          children: [
                            Icon(Icons.directions_car, size: 15, color: isCompleted ? Colors.grey : AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                booking.vehicleDisplay,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (booking.vehiclePlate != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade400),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  booking.vehiclePlate!,
                                  style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 1.5),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Row 3: client
                        Row(
                          children: [
                            Icon(Icons.person_outline, size: 15, color: isCompleted ? Colors.grey : AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                booking.clientName,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              booking.planTitle,
                              style: TextStyle(fontSize: 11, color: accent, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),

                        // Row 4: location (if available)
                        if (location.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined, size: 15, color: isCompleted ? Colors.grey : AppColors.textSecondary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  location,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  final bool isFromCarlo;
  const _SourceBadge({required this.isFromCarlo});

  @override
  Widget build(BuildContext context) {
    final color = isFromCarlo ? _carloColor : _verificarloColor;
    final label = isFromCarlo ? 'CARLO' : 'VERIFICARLO';
    final textColor = isFromCarlo ? _carloColor : const Color(0xFF856404);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 9),
      ),
    );
  }
}

class _WeekSelector extends StatelessWidget {
  final DateTime selected;
  final ValueChanged<DateTime> onChanged;

  const _WeekSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final start = selected.subtract(Duration(days: selected.weekday - 1));
    final days = List.generate(7, (i) => start.add(Duration(days: i)));

    return Container(
      color: AppColors.secondary,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: days.map((d) {
          final isSelected = d.day == selected.day && d.month == selected.month;
          final isToday = d.day == DateTime.now().day && d.month == DateTime.now().month && d.year == DateTime.now().year;
          return GestureDetector(
            onTap: () => onChanged(d),
            child: Column(
              children: [
                Text(
                  DateFormat.E('es').format(d).toUpperCase(),
                  style: TextStyle(color: isSelected ? AppColors.primary : Colors.white60, fontSize: 11),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    border: isToday && !isSelected ? Border.all(color: AppColors.primary) : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${d.day}',
                    style: TextStyle(
                      color: isSelected ? AppColors.secondary : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
