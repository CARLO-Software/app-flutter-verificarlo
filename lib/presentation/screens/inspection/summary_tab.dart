import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:app_flutter_verificarlo/core/constants/api_endpoints.dart';
import 'package:app_flutter_verificarlo/core/constants/app_colors.dart';
import 'package:app_flutter_verificarlo/core/network/api_client.dart';
import 'package:app_flutter_verificarlo/core/services/checklist_service.dart';
import 'package:app_flutter_verificarlo/core/services/verdict_service.dart';
import 'package:app_flutter_verificarlo/core/storage/local_storage.dart';
import 'package:app_flutter_verificarlo/data/models/booking_model.dart';
import 'package:app_flutter_verificarlo/data/models/checklist_models.dart';
import 'package:app_flutter_verificarlo/presentation/providers/checklist_controller.dart';
import 'package:app_flutter_verificarlo/presentation/providers/dashboard_provider.dart';
import 'package:app_flutter_verificarlo/data/repositories/photo_repository.dart';
import 'package:app_flutter_verificarlo/presentation/widgets/score_circle.dart';
import 'package:app_flutter_verificarlo/core/storage/secure_storage.dart';
import 'package:app_flutter_verificarlo/presentation/widgets/voice_button.dart';

class SummaryTab extends ConsumerStatefulWidget {
  final BookingModel booking;
  int get bookingId => booking.id;
  const SummaryTab({super.key, required this.booking});

  @override
  ConsumerState<SummaryTab> createState() => _SummaryTabState();
}

class _SummaryTabState extends ConsumerState<SummaryTab>
    with AutomaticKeepAliveClientMixin {
  final _summaryController = TextEditingController();
  final _costController = TextEditingController();
  final _mileageController = TextEditingController();
  bool _hasSiniestro = false;
  bool _hasKmAdulterado = false;
  String _selectedVerdict = 'APROBADO';
  Timer? _saveDebounce;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadSummary();
    _summaryController.addListener(_scheduleSave);
    _costController.addListener(_scheduleSave);
    _mileageController.addListener(_scheduleSave);
  }

  void _loadSummary() {
    final saved = LocalStorage.getSummary(widget.bookingId);
    if (saved == null) return;
    _summaryController.text = saved['summary'] as String? ?? '';
    _costController.text = saved['cost'] as String? ?? '';
    _mileageController.text = saved['mileage'] as String? ?? '';
    _hasSiniestro = saved['hasSiniestro'] as bool? ?? false;
    _hasKmAdulterado = saved['hasKmAdulterado'] as bool? ?? false;
    _selectedVerdict = saved['selectedVerdict'] as String? ?? 'APROBADO';
  }

  void _scheduleSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), _persistSummary);
  }

  void _persistSummary() {
    LocalStorage.saveSummary(widget.bookingId, {
      'summary': _summaryController.text,
      'cost': _costController.text,
      'mileage': _mileageController.text,
      'hasSiniestro': _hasSiniestro,
      'hasKmAdulterado': _hasKmAdulterado,
      'selectedVerdict': _selectedVerdict,
    });
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _summaryController.dispose();
    _costController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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

    final isFinalized = widget.booking.isFinalized;
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
            childAspectRatio: 1.9,
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
                      Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('${score.score.round()}%', style: TextStyle(fontWeight: FontWeight.bold, color: _statusColor(score.status))),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _statusColor(score.status).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(score.status, style: TextStyle(fontSize: 10, color: _statusColor(score.status), fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                            ),
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
            readOnly: isFinalized,
            decoration: const InputDecoration(hintText: 'Ej: 85000', suffixText: 'km', isDense: true),
          ),
          const SizedBox(height: 16),

          // Executive summary
          Row(
            children: [
              const Expanded(child: Text('Resumen ejecutivo', style: TextStyle(fontWeight: FontWeight.w600))),
              if (!isFinalized)
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
            readOnly: isFinalized,
            decoration: const InputDecoration(hintText: 'Resumen de la inspección...'),
          ),
          const SizedBox(height: 16),

          // Estimated cost
          const Text('Costo estimado de reparaciones', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: _costController,
            keyboardType: TextInputType.number,
            readOnly: isFinalized,
            decoration: const InputDecoration(prefixText: 'S/ ', hintText: '0.00', isDense: true),
          ),
          const SizedBox(height: 16),

          // Flags
          CheckboxListTile(
            value: _hasSiniestro,
            onChanged: isFinalized ? null : (v) { setState(() => _hasSiniestro = v ?? false); _scheduleSave(); },
            title: const Text('Vehículo con siniestro', style: TextStyle(fontSize: 14)),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
          CheckboxListTile(
            value: _hasKmAdulterado,
            onChanged: isFinalized ? null : (v) { setState(() => _hasKmAdulterado = v ?? false); _scheduleSave(); },
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
            onChanged: isFinalized || (_hasSiniestro || _hasKmAdulterado) ? (val) {} : (val) { setState(() => _selectedVerdict = val ?? _selectedVerdict); _scheduleSave(); },
            child: Column(
              children: ['APROBADO', 'OBSERVADO', 'NO_APROBADO'].map((v) => RadioListTile<String>(
                value: v,
                toggleable: !isFinalized && !(_hasSiniestro || _hasKmAdulterado),
                title: Text(v.replaceAll('_', ' '), style: const TextStyle(fontSize: 14)),
                dense: true,
                contentPadding: EdgeInsets.zero,
              )).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Finalize — hidden when already done
          if (!isFinalized)
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
      final api = ApiClient.instance;

      // 1. Create report
      final response = await api.post(ApiEndpoints.reports, data: {'bookingId': widget.bookingId});
      final reportId = response.data['report']['id'] as int;

      // 2. Upload checklist via section: "checklist"
      final categories = InspectionCategory.buildAll();
      final itemLookup = <String, InspectionItem>{};
      final itemCatLookup = <String, String>{};
      for (final cat in categories) {
        for (final item in cat.items) {
          itemLookup[item.id] = item;
          itemCatLookup[item.id] = cat.name;
        }
      }

      final checklistResults = <String, Map<String, dynamic>>{};
      for (final entry in checkState.results.entries) {
        final r = entry.value;
        if (r.status == null) continue;
        final item = itemLookup[entry.key];
        checklistResults[entry.key] = {
          'name': item?.name ?? entry.key,
          'category': itemCatLookup[entry.key] ?? '',
          'subcategory': item?.subcategory ?? '',
          'status': switch (r.status!) {
            ItemStatus.ok => 'OK',
            ItemStatus.observacion => 'OBSERVACION',
            ItemStatus.defecto => 'DEFECTO',
            ItemStatus.noAplica => 'NO_APLICA',
          },
          if (r.comment.isNotEmpty) 'comment': r.comment,
          if (r.selectedChips.isNotEmpty) 'selectedChips': r.selectedChips,
        };
      }
      await api.patch(ApiEndpoints.reportSections(reportId), data: {
        'section': 'checklist',
        'data': {'checklistResults': checklistResults},
      });

      // 3. Upload photos (best-effort, don't block finalization)
      final photoRepo = PhotoRepository();
      int photoErrors = 0;
      for (final entry in checkState.results.entries) {
        for (final path in entry.value.photoUrls) {
          if (!path.startsWith('http')) {
            try {
              await photoRepo.upload(reportId, path, entry.key);
            } catch (e) {
              photoErrors++;
              debugPrint('Photo upload error: $path → $e');
            }
          }
        }
      }
      if (photoErrors > 0 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$photoErrors foto(s) no se pudieron subir')),
        );
      }

      // 4+5. Mark mechanical inspection start → complete
      final viId = widget.booking.vehicleInspectionId;
      if (viId != null) {
        await api.patch(ApiEndpoints.mechanicAction(viId), data: {'action': 'start'});
        await api.patch(ApiEndpoints.mechanicAction(viId), data: {'action': 'complete'});
      }

      // 5. Finalize report
      await api.post(ApiEndpoints.reportComplete(reportId), data: {
        'mechanicalVerdict': verdict,
        'hasSiniestro': _hasSiniestro,
        'hasKilometrajeAdulterado': _hasKmAdulterado,
        'executiveSummary': _summaryController.text,
        'estimatedRepairCost': double.tryParse(_costController.text) ?? 0,
        'mileageAtInspection': int.tryParse(_mileageController.text),
      });

      if (!mounted) return;

      ref.invalidate(pendingInspectionsProvider);
      ref.invalidate(completedInspectionsProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inspección finalizada. Descargando PDF...'),
          backgroundColor: AppColors.success,
        ),
      );

      // 6. Download PDF
      await _downloadAndOpenPdf();

      if (!mounted) return;
      context.pop();
    } catch (e) {
      if (!mounted) return;
      String errorDetail = e.toString();
      if (e is DioException && e.response != null) {
        final data = e.response!.data;
        final body = data is List<int> ? utf8.decode(data) : '$data';
        errorDetail = 'Status ${e.response!.statusCode}: $body';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al finalizar: $errorDetail')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _downloadAndOpenPdf({int attempt = 1}) async {
    try {
      // ponytail: small delay on retry only, flow already completes inspection before this
      if (attempt > 1) await Future.delayed(const Duration(seconds: 3));

      final url = '${ApiEndpoints.nextBaseUrl}${ApiEndpoints.reportPdf(widget.bookingId)}';
      debugPrint('PDF download (attempt $attempt): $url');

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/informe-${widget.bookingId}.pdf');

      final token = await SecureStorage.getToken();
      final response = await Dio().get<List<int>>(
        url,
        options: Options(
          headers: {
            'x-api-key': ApiEndpoints.nextApiKey,
            if (token != null) 'Authorization': 'Bearer $token',
          },
          responseType: ResponseType.bytes,
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 15),
        ),
      );

      await file.writeAsBytes(response.data!);

      await OpenFilex.open(file.path);
    } catch (e) {
      String errorDetail = e.toString();
      if (e is DioException && e.response != null) {
        final data = e.response!.data;
        final body = data is List<int> ? utf8.decode(data) : '$data';
        errorDetail = 'Status ${e.response!.statusCode}: $body';
      }
      debugPrint('PDF download error (attempt $attempt): $errorDetail');

      // ponytail: 3 attempts total (~13s window), bump if backend is slower
      if (attempt < 3) {
        return _downloadAndOpenPdf(attempt: attempt + 1);
      }
      if (!mounted) return;
      // ponytail: PDF download is best-effort, inspection already saved
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Inspección guardada. Error PDF: $errorDetail')),
      );
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
