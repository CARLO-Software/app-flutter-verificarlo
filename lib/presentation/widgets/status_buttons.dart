import 'package:flutter/material.dart';
import 'package:app_flutter_verificarlo/data/models/checklist_models.dart';
import 'package:app_flutter_verificarlo/core/constants/app_colors.dart';

class StatusButtons extends StatelessWidget {
  final ItemStatus? selected;
  final List<ItemStatus> allowed;
  final ValueChanged<ItemStatus?>? onChanged;

  const StatusButtons({
    super.key,
    required this.selected,
    required this.allowed,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: allowed.map((status) {
        final isSelected = selected == status;
        final (label, color) = _labelColor(status);
        return Padding(
          padding: const EdgeInsets.only(right: 6),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onChanged != null ? () => onChanged!(isSelected ? null : status) : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? color.withValues(alpha: 0.15) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? color : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  (String, Color) _labelColor(ItemStatus status) => switch (status) {
        ItemStatus.ok => ('OK', AppColors.success),
        ItemStatus.observacion => ('Observación', AppColors.warning),
        ItemStatus.defecto => ('Defecto', AppColors.error),
        ItemStatus.noAplica => ('No aplica', AppColors.textSecondary),
      };
}
