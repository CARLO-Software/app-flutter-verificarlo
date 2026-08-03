import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app_flutter_verificarlo/core/constants/api_endpoints.dart';
import 'package:app_flutter_verificarlo/core/constants/app_colors.dart';
import 'package:app_flutter_verificarlo/core/network/api_client.dart';
import 'package:app_flutter_verificarlo/core/services/checklist_service.dart';
import 'package:app_flutter_verificarlo/core/services/verdict_service.dart';
import 'package:app_flutter_verificarlo/data/models/checklist_models.dart';
import 'package:app_flutter_verificarlo/presentation/providers/checklist_controller.dart';
import 'package:app_flutter_verificarlo/presentation/providers/dashboard_provider.dart';
import 'package:app_flutter_verificarlo/presentation/widgets/score_circle.dart';
import 'package:app_flutter_verificarlo/presentation/widgets/voice_button.dart';

class SummaryTab extends ConsumerStatefulWidget {
  final int bookingId;
  const SummaryTab({super.key, required this.bookingId});

  @override
  ConsumerState<SummaryTab> createState() => _SummaryTabState();
}

class _SummaryTabState extends ConsumerState<SummaryTab> {
  final _summaryController = TextEditingController();
  final _costController = TextEditingController();
  final _mileageController = TextEditingController();
  bool _hasSiniestro = false;
  bool _hasKmAdulterado = false;
  String _selectedVerdict = 'APROBADO';

  @override
  void dispose() {
    _summaryController.dispose();
    _costController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final checkState = ref.watch(checklistProvider(widget.bookingId));
    final categories = InspectionCategory.buildAll();

    // Compute scores per category
    final catScores = <CategoryType, CategoryScore>{};
    for (final cat in categories) {
      final results = cat.items
          .map((i) => checkState.results[i.id])
          .where((r) => r != null)
          .cast<ItemResult>()
          .toList();
      catScores[cat.type] = ChecklistService.scoreCategory(results);
    }

    final totalScore = ChecklistService.weightedScore(catScores);
    final overallStatus = ChecklistService.overallStatus(catScores);
    final finalVerdict = VerdictService.finalVerdict(
      calculatedStatus: _selectedVerdict,
      hasSiniestro: _hasSiniestro,
      hasKmAdulterado: _hasKmAdulterado,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Score circle
          Center(child: ScoreCircle(score: totalScore, label: overallStatus)),
          const SizedBox(height: 16),

          // Status counts summary
          _StatusCountsCard(checkState: checkState, categories: categories),
          const SizedBox(height: 12),

          // Category grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: categories.map((cat) {
              final score = catScores[cat.type]!;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('${score.score.round()}%', style: TextStyle(fontWeight: FontWeight.bold, color: _statusColor(score.status))),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _statusColor(score.status).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(score.status, style: TextStyle(fontSize: 10, color: _statusColor(score.status), fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Mileage
          const Text('Kilometraje real', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: _mileageController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Ej: 85000', suffixText: 'km', isDense: true),
          ),
          const SizedBox(height: 16),

          // Executive summary
          Row(
            children: [
              const Expanded(child: Text('Resumen ejecutivo', style: TextStyle(fontWeight: FontWeight.w600))),
              VoiceButton(onResult: (text) {
                final current = _summaryController.text;
                _summaryController.text = current.isEmpty ? text : '$current $text';
              }),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _summaryController,
            maxLines: 4,
            decoration: const InputDecoration(hintText: 'Resumen de la inspección...'),
          ),
          const SizedBox(height: 16),

          // Estimated cost
          const Text('Costo estimado de reparaciones', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: _costController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(prefixText: 'S/ ', hintText: '0.00', isDense: true),
          ),
          const SizedBox(height: 16),

          // Flags
          CheckboxListTile(
            value: _hasSiniestro,
            onChanged: (v) => setState(() => _hasSiniestro = v ?? false),
            title: const Text('Vehículo con siniestro', style: TextStyle(fontSize: 14)),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
          CheckboxListTile(
            value: _hasKmAdulterado,
            onChanged: (v) => setState(() => _hasKmAdulterado = v ?? false),
            title: const Text('Kilometraje adulterado', style: TextStyle(fontSize: 14)),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
          const SizedBox(height: 12),

          // Verdict radio
          const Text('Veredicto', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          if (_hasSiniestro || _hasKmAdulterado)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: const Text('Veredicto forzado a NO APROBADO por siniestro o km adulterado',
                  style: TextStyle(color: AppColors.error, fontSize: 12)),
            ),
          RadioGroup<String>(
            groupValue: (_hasSiniestro || _hasKmAdulterado) ? 'NO_APROBADO' : _selectedVerdict,
            onChanged: (_hasSiniestro || _hasKmAdulterado) ? (val) {} : (val) => setState(() => _selectedVerdict = val ?? _selectedVerdict),
            child: Column(
              children: ['APROBADO', 'OBSERVADO', 'NO_APROBADO'].map((v) => RadioListTile<String>(
                value: v,
                toggleable: !(_hasSiniestro || _hasKmAdulterado),
                title: Text(v.replaceAll('_', ' '), style: const TextStyle(fontSize: 14)),
                dense: true,
                contentPadding: EdgeInsets.zero,
              )).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Finalize
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submitting ? null : () => _finalize(finalVerdict),
              icon: _submitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.check_circle),
              label: Text(_submitting ? 'Enviando...' : 'Finalizar Inspección'),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  bool _submitting = false;

  void _finalize(String verdict) {
    final checkState = ref.read(checklistProvider(widget.bookingId));
    final categories = InspectionCategory.buildAll();
    final allItems = categories.expand((c) => c.items).toList();
    final pending = allItems.length - checkState.countCompleted(allItems);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Finalizar con veredicto $verdict?'),
            if (pending > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Atención: $pending ítems sin evaluar',
                style: const TextStyle(color: AppColors.warning, fontSize: 13),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _submitToBackend(verdict, checkState);
            },
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitToBackend(String verdict, ChecklistState checkState) async {
    if (_submitting) return;
    setState(() => _submitting = true);

    try {
      final checklistData = checkState.results.map((k, v) => MapEntry(k, v.toJson()));

      await ApiClient.instance.post(
        ApiEndpoints.bookingComplete(widget.bookingId),
        data: {
          'overallStatus': verdict,
          'executiveSummary': _summaryController.text,
          'estimatedCost': double.tryParse(_costController.text) ?? 0,
          'realMileage': int.tryParse(_mileageController.text),
          'hasSiniestro': _hasSiniestro,
          'hasKmAdulterado': _hasKmAdulterado,
          'checklistResults': jsonEncode(checklistData),
        },
      );

      if (!mounted) return;

      // Refresh dashboard lists
      ref.invalidate(pendingInspectionsProvider);
      ref.invalidate(completedInspectionsProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inspección finalizada'),
          backgroundColor: AppColors.success,
        ),
      );

      context.pop(); // Back to dashboard
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al finalizar: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Color _statusColor(String status) => switch (status) {
        'APROBADO' => AppColors.success,
        'OBSERVADO' => AppColors.warning,
        'NO_APROBADO' => AppColors.error,
        _ => AppColors.pending,
      };
}

class _StatusCountsCard extends StatelessWidget {
  final ChecklistState checkState;
  final List<InspectionCategory> categories;

  const _StatusCountsCard({
    required this.checkState,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final allItems = categories.expand((c) => c.items).toList();
    final ok = checkState.countByStatus(allItems, ItemStatus.ok);
    final obs = checkState.countByStatus(allItems, ItemStatus.observacion);
    final def = checkState.countByStatus(allItems, ItemStatus.defecto);
    final na = checkState.countByStatus(allItems, ItemStatus.noAplica);
    final pending = allItems.length - ok - obs - def - na;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Resumen de evaluación',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _CountChip('OK', ok, AppColors.success),
                _CountChip('OBS', obs, AppColors.warning),
                _CountChip('DEF', def, AppColors.error),
                _CountChip('N/A', na, AppColors.textSecondary),
              ],
            ),
            if (pending > 0) ...[
              const SizedBox(height: 8),
              Text(
                '$pending ítems sin evaluar de ${allItems.length}',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _CountChip(this.label, this.count, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }
}
