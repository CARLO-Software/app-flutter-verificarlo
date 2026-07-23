import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_flutter_verificarlo/core/constants/app_colors.dart';
import 'package:app_flutter_verificarlo/data/models/booking_model.dart';

class InspectionCard extends StatelessWidget {
  final BookingModel booking;
  final bool isCompleted;

  const InspectionCard({
    super.key,
    required this.booking,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // ponytail: navigate to inspection detail in Fase 2
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: time + urgent + status badge
              Row(
                children: [
                  Text(
                    booking.timeDisplay,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (booking.isUrgent && !isCompleted) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                  const Spacer(),
                  _StatusBadge(
                    status: isCompleted
                        ? 'Completado'
                        : (booking.mechanicalStatus == 'EN_PROCESO'
                            ? 'En progreso'
                            : 'Pendiente'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Vehicle
              Row(
                children: [
                  const Icon(Icons.directions_car,
                      size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      booking.vehicleDisplay,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              // Plate
              if (booking.vehiclePlate != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const SizedBox(width: 26),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        booking.vehiclePlate!,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 8),

              // Client
              Row(
                children: [
                  const Icon(Icons.person_outline,
                      size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      booking.clientName,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Plan
              Row(
                children: [
                  const Icon(Icons.assignment_outlined,
                      size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    booking.planTitle,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Code
              Row(
                children: [
                  const Icon(Icons.tag,
                      size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    booking.code,
                    style: TextStyle(
                      color: AppColors.primary.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),

              // Actions
              if (!isCompleted && booking.clientPhone != null) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _ActionButton(
                      icon: Icons.phone,
                      label: 'Llamar',
                      onTap: () => _launch('tel:${booking.clientPhone}'),
                    ),
                    const SizedBox(width: 12),
                    _ActionButton(
                      icon: Icons.chat,
                      label: 'WhatsApp',
                      onTap: () => _launch(
                        'https://wa.me/${booking.clientPhone?.replaceAll(RegExp(r'[^0-9]'), '')}?text=Hola, soy el inspector de VerifiCARLO para su inspección ${booking.code}',
                      ),
                    ),
                    const Spacer(),
                    FilledButton.tonal(
                      onPressed: () {
                        // ponytail: navigate to inspection in Fase 2
                      },
                      child: Text(
                        booking.mechanicalStatus == 'EN_PROCESO'
                            ? 'Continuar'
                            : 'Iniciar',
                      ),
                    ),
                  ],
                ),
              ],

              if (isCompleted) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // ponytail: navigate to report detail in Fase 2
                    },
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('Ver reporte'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _launch(String url) {
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bgColor) = switch (status) {
      'Completado' => (AppColors.completed, AppColors.completed.withValues(alpha: 0.1)),
      'En progreso' => (AppColors.inProgress, AppColors.inProgress.withValues(alpha: 0.1)),
      _ => (AppColors.pending, AppColors.pending.withValues(alpha: 0.1)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
