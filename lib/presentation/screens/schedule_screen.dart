import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:app_flutter_verificarlo/core/constants/app_colors.dart';
import 'package:app_flutter_verificarlo/presentation/providers/schedule_provider.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scheduleProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Agenda')),
      body: Column(
        children: [
          // Week day selector
          _WeekSelector(
            selected: state.selectedDate,
            onChanged: (d) => ref.read(scheduleProvider.notifier).selectDate(d),
          ),
          const Divider(height: 1),

          // Bookings list
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
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.bookings.length,
                          itemBuilder: (_, i) {
                            final b = state.bookings[i];
                            return Card(
                              child: ListTile(
                                leading: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(b.timeDisplay, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  ],
                                ),
                                title: Text(b.vehicleDisplay, style: const TextStyle(fontWeight: FontWeight.w500)),
                                subtitle: Text(b.clientName),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  context.push('/inspection/${b.id}', extra: b);
                                },
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
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
    // Show 7 days centered on selected
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
