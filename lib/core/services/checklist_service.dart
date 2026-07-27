import 'package:app_flutter_verificarlo/data/models/checklist_models.dart';

class CategoryScore {
  final String name;
  final double score;
  final String status; // APROBADO, OBSERVADO, NO_APROBADO

  const CategoryScore({required this.name, required this.score, required this.status});
}

class ChecklistService {
  /// Score per category: (OK×100 + OBS×50) / total_evaluated
  static CategoryScore scoreCategory(List<ItemResult> results) {
    final evaluated = results.where((r) => r.status != null && r.status != ItemStatus.noAplica).toList();
    if (evaluated.isEmpty) return const CategoryScore(name: '', score: 0, status: 'PENDIENTE');

    int sum = 0;
    bool hasDefecto = false;
    for (final r in evaluated) {
      if (r.status == ItemStatus.ok) sum += 100;
      if (r.status == ItemStatus.observacion) sum += 50;
      if (r.status == ItemStatus.defecto) hasDefecto = true;
    }

    final score = sum / evaluated.length;
    final status = hasDefecto
        ? 'NO_APROBADO'
        : score >= 80
            ? 'APROBADO'
            : 'OBSERVADO';

    return CategoryScore(name: '', score: score, status: status);
  }

  /// Weighted total: Legal 30%, Mecánica 40%, Carrocería 30%
  static double weightedScore(Map<CategoryType, CategoryScore> scores) {
    final weights = {
      CategoryType.legal: 0.30,
      CategoryType.mecanica: 0.40,
      CategoryType.carroceria: 0.30,
    };
    double total = 0;
    for (final entry in weights.entries) {
      total += (scores[entry.key]?.score ?? 0) * entry.value;
    }
    return total;
  }

  /// Overall status = worst of all category statuses
  static String overallStatus(Map<CategoryType, CategoryScore> scores) {
    final statuses = scores.values.map((s) => s.status).toList();
    if (statuses.contains('NO_APROBADO')) return 'NO_APROBADO';
    if (statuses.contains('OBSERVADO')) return 'OBSERVADO';
    if (statuses.contains('PENDIENTE')) return 'PENDIENTE';
    return 'APROBADO';
  }
}
