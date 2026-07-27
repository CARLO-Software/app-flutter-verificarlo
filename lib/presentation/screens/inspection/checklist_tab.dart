import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_flutter_verificarlo/core/constants/app_colors.dart';
import 'package:app_flutter_verificarlo/data/models/checklist_models.dart';
import 'package:app_flutter_verificarlo/presentation/providers/checklist_controller.dart';
import 'package:app_flutter_verificarlo/presentation/providers/photo_controller.dart';
import 'package:app_flutter_verificarlo/presentation/widgets/status_buttons.dart';
import 'package:app_flutter_verificarlo/presentation/widgets/comment_chips.dart';
import 'package:app_flutter_verificarlo/presentation/widgets/photo_capture.dart';
import 'package:app_flutter_verificarlo/presentation/widgets/voice_button.dart';

class ChecklistTab extends ConsumerStatefulWidget {
  final int reportId;
  const ChecklistTab({super.key, required this.reportId});

  @override
  ConsumerState<ChecklistTab> createState() => _ChecklistTabState();
}

class _ChecklistTabState extends ConsumerState<ChecklistTab> {
  final _categories = InspectionCategory.buildAll();
  int _selectedCategory = 0;

  @override
  Widget build(BuildContext context) {
    final checkState = ref.watch(checklistProvider(widget.reportId));
    final category = _categories[_selectedCategory];
    final completed = checkState.countCompleted(category.items);

    return Column(
      children: [
        // Category selector - horizontal scroll
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _categories.length,
            itemBuilder: (_, i) {
              final cat = _categories[i];
              final isSelected = i == _selectedCategory;
              final catCompleted = checkState.countCompleted(cat.items);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: ChoiceChip(
                  label: Text('${cat.name} ($catCompleted/${cat.items.length})'),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedCategory = i),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.secondary : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              );
            },
          ),
        ),

        // Progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: category.items.isEmpty ? 0 : completed / category.items.length,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$completed/${category.items.length} (${category.items.isEmpty ? 0 : (completed * 100 ~/ category.items.length)}%)',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),

        // "Todo OK" button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => ref
                  .read(checklistProvider(widget.reportId).notifier)
                  .setAllOk(category.items),
              icon: const Icon(Icons.check_circle, size: 16),
              label: const Text('Todo OK', style: TextStyle(fontSize: 13)),
            ),
          ),
        ),

        // Items list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            itemCount: category.items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) => _ItemCard(
              item: category.items[i],
              category: category,
              reportId: widget.reportId,
            ),
          ),
        ),
      ],
    );
  }
}

class _ItemCard extends ConsumerStatefulWidget {
  final InspectionItem item;
  final InspectionCategory category;
  final int reportId;

  const _ItemCard({
    required this.item,
    required this.category,
    required this.reportId,
  });

  @override
  ConsumerState<_ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends ConsumerState<_ItemCard> {
  bool _expanded = false;
  late final TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(checklistProvider(widget.reportId)).results[widget.item.id];
    final notifier = ref.read(checklistProvider(widget.reportId).notifier);
    final status = result?.status;

    // Sync comment controller
    if (_commentController.text != (result?.comment ?? '')) {
      _commentController.text = result?.comment ?? '';
    }

    // Determine which chips to show based on status
    final chips = status == ItemStatus.defecto
        ? widget.item.defectoChips
        : status == ItemStatus.observacion
            ? widget.item.obsChips
            : <String>[];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + status buttons
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.item.name,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                ),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          StatusButtons(
            selected: status,
            allowed: widget.category.allowedStatuses,
            onChanged: (s) => notifier.setStatus(widget.item.id, s),
          ),

          // Expanded detail
          if (_expanded || status == ItemStatus.observacion || status == ItemStatus.defecto) ...[
            const SizedBox(height: 8),

            if (chips.isNotEmpty)
              CommentChips(
                chips: chips,
                selected: result?.selectedChips ?? [],
                onToggle: (chip) => notifier.toggleChip(widget.item.id, chip),
              ),

            const SizedBox(height: 6),

            // Comment + voice
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    onChanged: (v) => notifier.setComment(widget.item.id, v),
                    decoration: const InputDecoration(
                      hintText: 'Comentario...',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    style: const TextStyle(fontSize: 13),
                    maxLines: 2,
                  ),
                ),
                VoiceButton(
                  onResult: (text) {
                    final current = _commentController.text;
                    final newText = current.isEmpty ? text : '$current $text';
                    _commentController.text = newText;
                    notifier.setComment(widget.item.id, newText);
                  },
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Photos
            PhotoCapture(
              photoUrls: result?.photoUrls ?? [],
              onCamera: () async {
                final path = await ref.read(photoControllerProvider).capturePhoto();
                if (path != null) notifier.addPhoto(widget.item.id, path);
              },
              onGallery: () async {
                final path = await ref.read(photoControllerProvider).pickFromGallery();
                if (path != null) notifier.addPhoto(widget.item.id, path);
              },
              onDelete: (url) => notifier.removePhoto(widget.item.id, url),
            ),
          ],
        ],
      ),
    );
  }
}
