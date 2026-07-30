import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:app_flutter_verificarlo/core/constants/app_colors.dart';
import 'package:app_flutter_verificarlo/core/services/fcm_service.dart';
import 'package:app_flutter_verificarlo/data/models/booking_model.dart';
import 'package:app_flutter_verificarlo/presentation/providers/auth_provider.dart';
import 'package:app_flutter_verificarlo/presentation/providers/dashboard_provider.dart';
import 'package:app_flutter_verificarlo/presentation/widgets/inspection_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    FcmService.instance.onInspectionReceived = _onNewInspection;
  }

  @override
  void dispose() {
    FcmService.instance.onInspectionReceived = null;
    super.dispose();
  }

  void _onNewInspection(Map<String, dynamic> data) {
    ref.invalidate(pendingInspectionsProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(data['title'] ?? 'Nueva inspección asignada'),
        backgroundColor: AppColors.primary,
        action: SnackBarAction(
          label: 'Ver',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final auth = ref.watch(authProvider);
    final pending = ref.watch(pendingInspectionsProvider);
    final completed = ref.watch(completedInspectionsProvider);

    final userName = auth.user?.name.split(' ').first ?? 'Inspector';
    final today = DateFormat("EEEE d 'de' MMMM", 'es').format(DateTime.now());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hola, $userName',
                  style: const TextStyle(fontSize: 18)),
              Text(today,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => ref.read(authProvider.notifier).logout(),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              color: AppColors.secondary,
              child: TabBar(
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.white60,
                tabs: [
                  Tab(
                    text: pending.when(
                      data: (list) => 'Pendientes (${list.length})',
                      loading: () => 'Pendientes',
                      error: (_, __) => 'Pendientes',
                    ),
                  ),
                  Tab(
                    text: completed.when(
                      data: (list) => 'Completadas (${list.length})',
                      loading: () => 'Completadas',
                      error: (_, __) => 'Completadas',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // Pending tab
            _InspectionList(
              asyncValue: pending,
              isCompleted: false,
              onRefresh: () => ref.refresh(pendingInspectionsProvider.future),
            ),
            // Completed tab
            _InspectionList(
              asyncValue: completed,
              isCompleted: true,
              onRefresh: () => ref.refresh(completedInspectionsProvider.future),
            ),
          ],
        ),
      ),
    );
  }
}

class _InspectionList extends StatelessWidget {
  final AsyncValue<List<BookingModel>> asyncValue;
  final bool isCompleted;
  final Future<void> Function() onRefresh;

  const _InspectionList({
    required this.asyncValue,
    required this.isCompleted,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRefresh, child: const Text('Reintentar')),
          ],
        ),
      ),
      data: (inspections) {
        if (inspections.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isCompleted ? Icons.check_circle_outline : Icons.inbox_outlined,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  isCompleted
                      ? 'No hay inspecciones completadas'
                      : 'No hay inspecciones pendientes',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        // Group by date
        final grouped = _groupByDate(inspections);

        return RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: grouped.length,
            itemBuilder: (context, index) {
              final entry = grouped[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Text(
                      entry.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  ...entry.bookings.map(
                    (b) => InspectionCard(
                      booking: b,
                      isCompleted: isCompleted,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  List<_DateGroup> _groupByDate(List<BookingModel> bookings) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final Map<String, List<BookingModel>> groups = {};

    for (final b in bookings) {
      final date = DateTime(b.startTime.year, b.startTime.month, b.startTime.day);
      String label;
      if (date == today) {
        label = 'Hoy';
      } else if (date == tomorrow) {
        label = 'Mañana';
      } else if (date.isAfter(today)) {
        final diff = date.difference(today).inDays;
        label = 'En $diff días';
      } else {
        label = DateFormat("d 'de' MMMM", 'es').format(date);
      }

      groups.putIfAbsent(label, () => []).add(b);
    }

    return groups.entries
        .map((e) => _DateGroup(label: e.key, bookings: e.value))
        .toList();
  }
}

class _DateGroup {
  final String label;
  final List<BookingModel> bookings;
  _DateGroup({required this.label, required this.bookings});
}
