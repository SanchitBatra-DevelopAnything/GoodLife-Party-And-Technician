import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../screens/full_screen_image_screen.dart';

class ImageUploadGrid extends StatelessWidget {
  final String title;
  final int maxImages;
  final List<File> localImages;
  final List<String> remoteUrls;
  final bool enabled;
  final void Function(File file) onImageAdded;
  final void Function(int index, bool isLocal) onImageRemoved;

  const ImageUploadGrid({
    super.key,
    required this.title,
    required this.maxImages,
    required this.localImages,
    required this.remoteUrls,
    required this.enabled,
    required this.onImageAdded,
    required this.onImageRemoved,
  });

  int get _totalCount => localImages.length + remoteUrls.length;

  Future<void> _pickImage(BuildContext context) async {
    if (!enabled || _totalCount >= maxImages) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 50,
    );
    if (picked != null) {
      onImageAdded(File(picked.path));
    }
  }

  void _openImage(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenImageScreen(imageUrl: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const Spacer(),
            Text(
              '$_totalCount / $maxImages',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ...remoteUrls.asMap().entries.map((entry) {
              final index = entry.key;
              final url = entry.value;
              return _ImageTile(
                child: GestureDetector(
                  onTap: () => _openImage(context, url),
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                onRemove: enabled
                    ? () => onImageRemoved(index, false)
                    : null,
              );
            }),
            ...localImages.asMap().entries.map((entry) {
              final index = entry.key;
              final file = entry.value;
              return _ImageTile(
                child: Image.file(file, fit: BoxFit.cover),
                onRemove: enabled
                    ? () => onImageRemoved(index, true)
                    : null,
              );
            }),
            if (enabled && _totalCount < maxImages)
              GestureDetector(
                onTap: () => _pickImage(context),
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                    color: primary.withOpacity(0.04),
                  ),
                  child: Icon(Icons.add_a_photo_rounded, color: primary),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ImageTile extends StatelessWidget {
  final Widget child;
  final VoidCallback? onRemove;

  const _ImageTile({required this.child, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(width: 90, height: 90, child: child),
        ),
        if (onRemove != null)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
