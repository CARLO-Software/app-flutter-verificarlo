import 'package:flutter/material.dart';
import 'package:app_flutter_verificarlo/core/constants/app_colors.dart';
import 'package:app_flutter_verificarlo/data/models/booking_model.dart';

class InfoTab extends StatelessWidget {
  final BookingModel booking;
  const InfoTab({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Section(title: 'Vehículo', children: [
            _InfoRow('Marca', booking.vehicleBrand.isNotEmpty ? booking.vehicleBrand : '-'),
            _InfoRow('Modelo', booking.vehicleModel.isNotEmpty ? booking.vehicleModel : '-'),
            _InfoRow('Año', booking.vehicleYear > 0 ? '${booking.vehicleYear}' : '-'),
            _InfoRow('Placa', booking.vehiclePlate ?? 'Sin registrar'),
          ]),
          const SizedBox(height: 16),

          _Section(title: 'Cliente', children: [
            _InfoRow('Nombre', booking.clientName.isNotEmpty ? booking.clientName : '-'),
            if (booking.clientPhone != null) _InfoRow('Teléfono', booking.clientPhone!),
            if (booking.clientEmail != null) _InfoRow('Email', booking.clientEmail!),
          ]),
          const SizedBox(height: 16),

          _Section(title: 'Inspección', children: [
            _InfoRow('Plan', booking.planTitle.isNotEmpty ? booking.planTitle : '-'),
            _InfoRow('Fecha', booking.date.isNotEmpty ? booking.date : '-'),
            _InfoRow('Hora', booking.timeSlot.isNotEmpty ? booking.timeSlot : '-'),
            _InfoRow('Código', booking.code),
          ]),

          const SizedBox(height: 32),

          // Siguiente → lleva al tab de Checklist
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
