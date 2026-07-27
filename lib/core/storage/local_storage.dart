import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

/// Hive-backed local storage for checklist offline backup and sync queue
class LocalStorage {
  static const _checklistBox = 'checklist_backup';
  static const _syncQueueBox = 'sync_queue';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_checklistBox);
    await Hive.openBox(_syncQueueBox);
  }

  // --- Checklist backup ---

  static Future<void> saveChecklist(int reportId, Map<String, dynamic> data) async {
    final box = Hive.box(_checklistBox);
    await box.put('report_$reportId', jsonEncode(data));
  }

  static Map<String, dynamic>? getChecklist(int reportId) {
    final box = Hive.box(_checklistBox);
    final raw = box.get('report_$reportId') as String?;
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<void> clearChecklist(int reportId) async {
    final box = Hive.box(_checklistBox);
    await box.delete('report_$reportId');
  }

  // --- Sync queue ---

  static Future<void> enqueue(Map<String, dynamic> operation) async {
    final box = Hive.box(_syncQueueBox);
    final queue = _getQueue(box);
    queue.add(operation);
    await box.put('queue', jsonEncode(queue));
  }

  static List<Map<String, dynamic>> getPendingOps() {
    final box = Hive.box(_syncQueueBox);
    return _getQueue(box);
  }

  static Future<void> clearQueue() async {
    final box = Hive.box(_syncQueueBox);
    await box.put('queue', jsonEncode([]));
  }

  static List<Map<String, dynamic>> _getQueue(Box box) {
    final raw = box.get('queue') as String?;
    if (raw == null) return [];
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }
}
