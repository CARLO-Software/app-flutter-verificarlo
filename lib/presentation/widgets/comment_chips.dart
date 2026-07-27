import 'package:flutter/material.dart';
import 'package:app_flutter_verificarlo/core/constants/app_colors.dart';

class CommentChips extends StatelessWidget {
  final List<String> chips;
  final List<String> selected;
  final ValueChanged<String> onToggle;

  const CommentChips({
    super.key,
    required this.chips,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (chips.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: chips.map((chip) {
        final isSelected = selected.contains(chip);
        return GestureDetector(
          onTap: () => onToggle(chip),
          child: Chip(
            label: Text(chip, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : AppColors.textPrimary)),
            backgroundColor: isSelected ? AppColors.warning : Colors.grey.shade200,
            padding: EdgeInsets.zero,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        );
      }).toList(),
    );
  }
}
