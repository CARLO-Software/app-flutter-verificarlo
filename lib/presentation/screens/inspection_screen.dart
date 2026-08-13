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
        body: TabBarView(
          children: [
            InfoTab(booking: booking),
            ChecklistTab(bookingId: booking.id),
            SummaryTab(booking: booking),
          ],
        ),
      ),
    );
  }
}
