import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:app_flutter_verificarlo/core/constants/app_colors.dart';
import 'package:app_flutter_verificarlo/core/constants/api_endpoints.dart';
import 'package:app_flutter_verificarlo/core/network/api_client.dart';
import 'package:app_flutter_verificarlo/data/models/booking_model.dart';

class InfoTab extends StatefulWidget {
  final BookingModel booking;
  const InfoTab({super.key, required this.booking});

  @override
  State<InfoTab> createState() => _InfoTabState();
}

class _InfoTabState extends State<InfoTab> {
  final _plateCtrl = TextEditingController();
  bool _sending = false;
  String? _sentPlate;

  bool _editingPlate = false;

  bool get _needsPlate =>
      (widget.booking.vehiclePlate == null && _sentPlate == null && widget.booking.vehicleInspectionId != null)
      || _editingPlate;

  Future<void> _submitPlate() async {
    final viId = widget.booking.vehicleInspectionId;
    if (viId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se puede registrar placa sin inspección asignada')),
      );
      return;
    }
    final plate = _plateCtrl.text;
    if (!RegExp(r'^[A-Z]{3}-\d{3}$').hasMatch(plate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Formato inválido. Use ABC-123')),
      );
      return;
    }
    setState(() => _sending = true);
    try {
      await ApiClient.instance.patch(
        ApiEndpoints.mechanicAction(viId),
        data: {'action': 'register_plate', 'plate': plate},
      );
      setState(() {
        _sentPlate = plate;
        _sending = false;
        _editingPlate = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Placa enviada correctamente')),
        );
      }
    } catch (e) {
      setState(() => _sending = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar placa: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _plateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    final formattedDate = DateFormat("EEEE d 'de' MMMM, yyyy", 'es').format(b.startTime);
    final formattedTime = '${b.timeDisplay} (hora Lima)';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Section(title: 'Vehículo', children: [
            _InfoRow('Marca', b.vehicleBrand.isNotEmpty ? b.vehicleBrand : '-'),
            _InfoRow('Modelo', b.vehicleModel.isNotEmpty ? b.vehicleModel : '-'),
            _InfoRow('Año', b.vehicleYear > 0 ? '${b.vehicleYear}' : '-'),
            if (!_needsPlate)
              Row(
                children: [
                  const SizedBox(width: 0, child: SizedBox.shrink()),
                  Expanded(child: _InfoRow('Placa', _sentPlate ?? b.vehiclePlate ?? '-')),
                  IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      onPressed: () => setState(() {
                        _editingPlate = true;
                        _plateCtrl.text = (_sentPlate ?? b.vehiclePlate ?? '').replaceAll('-', '');
                      }),
                      tooltip: 'Editar placa',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            if (_needsPlate) _buildPlateInput(),
          ]),
          const SizedBox(height: 16),

          _Section(title: 'Cliente', children: [
            _InfoRow('Nombre', b.clientName.isNotEmpty ? b.clientName : '-'),
            if (b.clientPhone != null) _InfoRow('Teléfono', b.clientPhone!),
            if (b.clientEmail != null) _InfoRow('Email', b.clientEmail!),
            if (b.address != null && b.address!.isNotEmpty)
              _InfoRow('Dirección', b.address!),
            if (b.district != null && b.district!.isNotEmpty)
              _InfoRow('Distrito', b.district!),
          ]),
          const SizedBox(height: 16),

          _Section(title: 'Inspección', children: [
            _InfoRow('Plan', b.planTitle.isNotEmpty ? b.planTitle : '-'),
            _InfoRow('Fecha', formattedDate),
            _InfoRow('Hora', formattedTime),
            _InfoRow('Código', b.code),
          ]),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                DefaultTabController.of(context).animateTo(1);
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Siguiente'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPlateInput() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Placa no registrada — ingrese manualmente:',
            style: TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _plateCtrl,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [_PlateFormatter()],
                  decoration: const InputDecoration(
                    hintText: 'ABC-123',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _sending || _plateCtrl.text.length < 7 ? null : _submitPlate,
                child: _sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Enviar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (text.length > 6) text = text.substring(0, 6);
    if (text.length > 3) text = '${text.substring(0, 3)}-${text.substring(3)}';
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
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
