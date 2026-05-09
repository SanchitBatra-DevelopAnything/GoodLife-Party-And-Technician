import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:goodlife_party/models/whats_new_item.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class WhatsNewDialog extends StatefulWidget {
  final List<WhatsNewItem> items;

  const WhatsNewDialog({super.key, required this.items});

  @override
  State<WhatsNewDialog> createState() => WhatsNewDialogState();
}

class WhatsNewDialogState extends State<WhatsNewDialog> {
  final List<YoutubePlayerController> controllers = [];
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    for (final item in widget.items) {
      final videoId = YoutubePlayer.convertUrlToId(item.url);

      controllers.add(
        YoutubePlayerController(
          initialVideoId: videoId ?? '',
          flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
        ),
      );
    }
  }

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }

    super.dispose();
  }

  Widget buildImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.network(url, fit: BoxFit.cover, width: double.infinity),
    );
  }

  Widget buildVideo(int index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: YoutubePlayer(
        controller: controllers[index],
        showVideoProgressIndicator: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: CarouselSlider.builder(
              itemCount: widget.items.length,
              options: CarouselOptions(
                height: 430,
                enlargeCenterPage: true,
                enableInfiniteScroll: false,
                viewportFraction: 1,
                onPageChanged: (index, reason) {
                  setState(() {
                    currentIndex = index;
                  });
                },
              ),
              itemBuilder: (context, index, realIndex) {
                final item = widget.items[index];

                if (item.type == 'image') {
                  return buildImage(item.url);
                }

                return buildVideo(index);
              },
            ),
          ),

          Positioned(
            bottom: 18,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.items.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: currentIndex == index ? 18 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: currentIndex == index
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Swipe to explore',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${currentIndex + 1} / ${widget.items.length}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),

          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
