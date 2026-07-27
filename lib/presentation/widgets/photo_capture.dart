import 'dart:io';
import 'package:flutter/material.dart';
import 'package:app_flutter_verificarlo/core/constants/app_colors.dart';

class PhotoCapture extends StatelessWidget {
  final List<String> photoUrls;
  final int maxPhotos;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final ValueChanged<String> onDelete;

  const PhotoCapture({
    super.key,
    required this.photoUrls,
    this.maxPhotos = 5,
    required this.onCamera,
    required this.onGallery,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (photoUrls.isNotEmpty)
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photoUrls.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final url = photoUrls[i];
                final isLocal = !url.startsWith('http');
                return GestureDetector(
                  onTap: () => _showLightbox(context, url, isLocal),
                  onLongPress: () => _confirmDelete(context, url),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: isLocal
                        ? Image.file(File(url), width: 72, height: 72, fit: BoxFit.cover)
                        : Image.network(url, width: 72, height: 72, fit: BoxFit.cover),
                  ),
                );
              },
            ),
          ),
        if (photoUrls.length < maxPhotos)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                _MiniButton(icon: Icons.camera_alt, label: 'Cámara', onTap: onCamera),
                const SizedBox(width: 8),
                _MiniButton(icon: Icons.photo_library, label: 'Galería', onTap: onGallery),
                const Spacer(),
                Text('${photoUrls.length}/$maxPhotos', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
      ],
    );
  }

  void _showLightbox(BuildContext context, String url, bool isLocal) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: isLocal
            ? Image.file(File(url))
            : Image.network(url),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar foto'),
        content: const Text('¿Seguro que deseas eliminar esta foto?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete(url);
            },
            child: const Text('Eliminar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MiniButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
