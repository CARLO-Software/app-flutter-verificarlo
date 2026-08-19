import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_flutter_verificarlo/core/constants/app_colors.dart';
import 'package:app_flutter_verificarlo/data/models/booking_model.dart';
import 'package:app_flutter_verificarlo/presentation/screens/inspection/info_tab.dart';
import 'package:app_flutter_verificarlo/presentation/screens/inspection/checklist_tab.dart';
import 'package:app_flutter_verificarlo/presentation/screens/inspection/summary_tab.dart';

class InspectionScreen extends ConsumerWidget {
  final BookingModel booking;
  const InspectionScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Inspección ${booking.code}'),
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
        body: Column(
          children: [
            if (booking.isFinalized)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: AppColors.success.withValues(alpha: 0.15),
                child: const Row(
                  children: [
                    Icon(Icons.lock, size: 16, color: AppColors.success),
                    SizedBox(width: 8),
                    Text('Inspección finalizada — solo lectura',
                        style: TextStyle(fontSize: 13, color: AppColors.success, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            Expanded(
              child: TabBarView(
                children: [
                  InfoTab(booking: booking),
                  ChecklistTab(bookingId: booking.id, readOnly: booking.isFinalized),
                  SummaryTab(booking: booking),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
