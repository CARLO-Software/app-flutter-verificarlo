import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_flutter_verificarlo/core/constants/app_colors.dart';
import 'package:app_flutter_verificarlo/presentation/providers/inspection_controller.dart';

class InfoTab extends ConsumerStatefulWidget {
  final int reportId;
  const InfoTab({super.key, required this.reportId});

  @override
  ConsumerState<InfoTab> createState() => _InfoTabState();
}

class _InfoTabState extends ConsumerState<InfoTab> {
  final _plateController = TextEditingController();
  static final _plateRegex = RegExp(r'^[A-Z]{3}-\d{3}$');

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inspectionProvider(widget.reportId));
    final report = state.report;

    if (state.isLoading || report == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final vehicle = report['vehicle'] as Map<String, dynamic>? ?? {};
    final client = report['client'] as Map<String, dynamic>? ?? {};
    final booking = report['booking'] as Map<String, dynamic>? ?? {};
    final plan = report['inspectionPlan'] as Map<String, dynamic>? ?? {};
    final plate = vehicle['plate'] as String?;
    final inspectionId = report['vehicleInspectionId'] as int? ?? report['id'] as int;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Section(title: 'Vehículo', children: [
            _InfoRow('Marca', vehicle['brand'] as String? ?? '-'),
            _InfoRow('Modelo', vehicle['model'] as String? ?? '-'),
            _InfoRow('Año', '${vehicle['year'] ?? '-'}'),
            _InfoRow('Placa', plate ?? 'Sin registrar'),
            if (vehicle['mileage'] != null)
              _InfoRow('Kilometraje', '${vehicle['mileage']} km'),
          ]),
          const SizedBox(height: 16),

          _Section(title: 'Cliente', children: [
            _InfoRow('Nombre', client['name'] as String? ?? '-'),
            if (client['phone'] != null) _InfoRow('Teléfono', client['phone'] as String),
            if (client['email'] != null) _InfoRow('Email', client['email'] as String),
          ]),
          const SizedBox(height: 16),

          _Section(title: 'Inspección', children: [
            _InfoRow('Plan', plan['title'] as String? ?? '-'),
            _InfoRow('Fecha', booking['date'] as String? ?? '-'),
            _InfoRow('Hora', booking['timeSlot'] as String? ?? '-'),
          ]),

          // Plate registration
          if (plate == null || plate.isEmpty) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const Text('Registrar placa', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _plateController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      hintText: 'AAA-123',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    final value = _plateController.text.trim().toUpperCase();
                    if (!_plateRegex.hasMatch(value)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Formato: AAA-123')),
                      );
                      return;
                    }
                    ref.read(inspectionProvider(widget.reportId).notifier)
                        .registerPlate(inspectionId, value);
                  },
                  child: const Text('Registrar'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
