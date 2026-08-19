import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_flutter_verificarlo/core/constants/app_colors.dart';
import 'package:app_flutter_verificarlo/data/models/checklist_models.dart';
import 'package:app_flutter_verificarlo/presentation/providers/checklist_controller.dart';
import 'package:app_flutter_verificarlo/presentation/providers/photo_controller.dart';
import 'package:app_flutter_verificarlo/presentation/widgets/status_buttons.dart';
import 'package:app_flutter_verificarlo/presentation/widgets/voice_button.dart';

class ChecklistTab extends ConsumerStatefulWidget {
  final int bookingId;
  final bool readOnly;
  const ChecklistTab({super.key, required this.bookingId, this.readOnly = false});

  @override
  ConsumerState<ChecklistTab> createState() => _ChecklistTabState();
}

class _ChecklistTabState extends ConsumerState<ChecklistTab>
    with SingleTickerProviderStateMixin {
  final _categories = InspectionCategory.buildAll();
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final checkState = ref.watch(checklistProvider(widget.bookingId));

    return Column(
      children: [
        // Category tabs
        TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabAlignment: TabAlignment.start,
          tabs: _categories.map((cat) {
            final done = checkState.countCompleted(cat.items);
            return Tab(text: '${cat.name} ($done/${cat.items.length})');
          }).toList(),
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _categories.map((cat) {
              return _CategoryContent(
                category: cat,
                bookingId: widget.bookingId,
                readOnly: widget.readOnly,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Renders one category's items grouped by subcategory.
class _CategoryContent extends ConsumerWidget {
  final InspectionCategory category;
  final int bookingId;
  final bool readOnly;

  const _CategoryContent({required this.category, required this.bookingId, this.readOnly = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkState = ref.watch(checklistProvider(bookingId));
    final notifier = ref.read(checklistProvider(bookingId).notifier);
    final grouped = category.itemsBySubcategory;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      children: [
        // Progress bar
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: category.items.isEmpty
                      ? 0
                      : checkState.countCompleted(category.items) /
                          category.items.length,
                  backgroundColor: Colors.grey.shade200,
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${checkState.countCompleted(category.items)}/${category.items.length}',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),

        // "Todo OK" shortcut
        if (!readOnly)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => notifier.setAllOk(category.items),
              icon: const Icon(Icons.check_circle, size: 16),
              label: const Text('Todo OK', style: TextStyle(fontSize: 13)),
            ),
          ),

        // Subcategory sections
        for (final entry in grouped.entries) ...[
          _SubcategoryHeader(
            title: entry.key,
            completed: checkState.countCompleted(entry.value),
            total: entry.value.length,
          ),
          for (final item in entry.value)
            _ItemTile(
              item: item,
              result: checkState.results[item.id],
              allowed: category.allowedStatuses,
              readOnly: readOnly,
              onStatusChanged: (s) => notifier.setStatus(item.id, s),
              onCommentChanged: (c) => notifier.setComment(item.id, c),
              onChipToggled: (c) => notifier.toggleChip(item.id, c),
              onAddPhoto: () async {
                final photo = ref.read(photoControllerProvider);
                final path = await photo.capturePhoto();
                if (path != null) notifier.addPhoto(item.id, path);
              },
              onRemovePhoto: (url) => notifier.removePhoto(item.id, url),
            ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _SubcategoryHeader extends StatelessWidget {
  final String title;
  final int completed;
  final int total;

  const _SubcategoryHeader({
    required this.title,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.secondary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: completed == total && total > 0
                  ? AppColors.success.withValues(alpha: 0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$completed de $total',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: completed == total && total > 0
                    ? AppColors.success
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemTile extends StatefulWidget {
  final InspectionItem item;
  final ItemResult? result;
  final List<ItemStatus> allowed;
  final bool readOnly;
  final ValueChanged<ItemStatus?> onStatusChanged;
  final ValueChanged<String> onCommentChanged;
  final ValueChanged<String> onChipToggled;
  final VoidCallback onAddPhoto;
  final ValueChanged<String> onRemovePhoto;

  const _ItemTile({
    required this.item,
    required this.result,
    required this.allowed,
    this.readOnly = false,
    required this.onStatusChanged,
    required this.onCommentChanged,
    required this.onChipToggled,
    required this.onAddPhoto,
    required this.onRemovePhoto,
  });

  @override
  State<_ItemTile> createState() => _ItemTileState();
}

class _ItemTileState extends State<_ItemTile> {
  late final TextEditingController _commentController;
  String _baseComment = '';

  @override
  void initState() {
    super.initState();
    _commentController =
        TextEditingController(text: widget.result?.comment ?? '');
  }

  // ponytail: no didUpdateWidget sync — controller is source of truth, state stays in sync via onChanged

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.result?.status;
    final showChips = status == ItemStatus.observacion ||
        status == ItemStatus.defecto;
    final chips = status != null ? widget.item.quickChipsFor(status) : widget.item.quickChips;
    final selectedChips = widget.result?.selectedChips ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.item.name,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 6),
          StatusButtons(
            selected: status,
            allowed: widget.allowed,
            onChanged: widget.readOnly ? null : widget.onStatusChanged,
          ),
          // Quick-response chips — shown on observación/defecto
          if (showChips && chips.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: chips.map((chip) {
                final isSelected = selectedChips.contains(chip);
                return GestureDetector(
                  onTap: widget.readOnly ? null : () => widget.onChipToggled(chip),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      chip,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 6),
          TextField(
            controller: _commentController,
            onChanged: widget.readOnly ? null : widget.onCommentChanged,
            readOnly: widget.readOnly,
            decoration: InputDecoration(
              hintText: 'Comentario (opcional)...',
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              suffixIcon: widget.readOnly ? null : VoiceButton(
                onListeningChanged: (listening) {
                  if (listening) {
                    final t = _commentController.text;
                    _baseComment = t.isEmpty ? '' : '$t ';
                  }
                },
                onPartialResult: (partial) {
                  _commentController.text = '$_baseComment$partial';
                },
                onResult: (text) {
                  final newText = '$_baseComment$text';
                  _commentController.text = newText;
                  widget.onCommentChanged(newText);
                },
              ),
              suffixIconConstraints:
                  const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
            style: const TextStyle(fontSize: 13),
            minLines: 1,
            maxLines: 3,
          ),
          const SizedBox(height: 6),
          _PhotoRow(
            photoUrls: widget.result?.photoUrls ?? [],
            onAdd: widget.onAddPhoto,
            onRemove: widget.onRemovePhoto,
          ),
          const Divider(height: 16),
        ],
      ),
    );
  }
}

class _PhotoRow extends StatelessWidget {
  final List<String> photoUrls;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  const _PhotoRow({required this.photoUrls, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (photoUrls.length < 5)
            GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 56,
                height: 56,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.camera_alt, color: AppColors.textSecondary),
              ),
            ),
          for (final url in photoUrls)
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: url.startsWith('http') ? NetworkImage(url) as ImageProvider : FileImage(File(url)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => onRemove(url),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
