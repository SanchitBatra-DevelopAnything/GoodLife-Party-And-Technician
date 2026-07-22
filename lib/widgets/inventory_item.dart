import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:goodlife_party/models/categories_model.dart';

class InventoryItem extends StatelessWidget {
  final CategoryModel machine;

  const InventoryItem({
    super.key,
    required this.machine,
  });

  void openImagePreview(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) {
          return GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Stack(
                children: [
                  Center(
                    child: Hero(
                      tag: machine.imageUrl,
                      child: InteractiveViewer(
                        minScale: 1,
                        maxScale: 4,
                        child: machine.imageUrl.isEmpty
                          ? const Center(child: Icon(Icons.image, color: Colors.grey, size: 60))
                          : CachedNetworkImage(
                              imageUrl: machine.imageUrl,
                              fit: BoxFit.contain,
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.image_not_supported),
                            ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: MediaQuery.of(context).padding.top + 10,
                    right: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  Future<void> openVideo() async {
    if (machine.videoUrl.isEmpty) return;

    final uri = Uri.parse(machine.videoUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      elevation: 3,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Hero(
                    tag: machine.imageUrl,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: machine.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade200,
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),

                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.15),
                            Colors.transparent,
                            Colors.black.withOpacity(0.25),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () => openImagePreview(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),
                          child: const Icon(
                            Icons.fullscreen_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Text(
              machine.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: openVideo,
                icon: const Icon(Icons.play_circle_fill),
                label: const Text('Watch Video'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}