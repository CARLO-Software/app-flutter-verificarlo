import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_flutter_verificarlo/core/constants/app_colors.dart';
import 'package:app_flutter_verificarlo/core/services/sync_service.dart';
import 'package:app_flutter_verificarlo/presentation/providers/inspection_controller.dart';
import 'package:app_flutter_verificarlo/presentation/screens/inspection/info_tab.dart';
import 'package:app_flutter_verificarlo/presentation/screens/inspection/checklist_tab.dart';
import 'package:app_flutter_verificarlo/presentation/screens/inspection/summary_tab.dart';

class InspectionScreen extends ConsumerWidget {
  final int reportId;
  const InspectionScreen({super.key, required this.reportId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inspectionProvider(reportId));
    final syncState = ref.watch(syncProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inspección'),
          actions: [
            // Sync indicator
            if (syncState.status == SyncStatus.syncing)
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Center(
                  child: SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  ),
                ),
              ),
            if (syncState.status == SyncStatus.error)
              IconButton(
                icon: const Icon(Icons.cloud_off, color: AppColors.warning),
                onPressed: () => ref.read(syncProvider.notifier).retry(),
                tooltip: '${syncState.pendingCount} pendientes',
              ),
            if (syncState.status == SyncStatus.idle)
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.cloud_done, size: 18, color: AppColors.success),
              ),
          ],
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(text: 'Info'),
              Tab(text: 'Checklist'),
              Tab(text: 'Resumen'),
            ],
          ),
        ),
        body: state.error != null
            ? Center(child: Text('Error: ${state.error}'))
            : TabBarView(
                children: [
                  InfoTab(reportId: reportId),
                  ChecklistTab(reportId: reportId),
                  SummaryTab(reportId: reportId),
                ],
              ),
      ),
    );
  }
}
