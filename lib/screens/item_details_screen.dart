import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:goodlife_party/models/item_model.dart';

class ItemDetailsScreen extends StatelessWidget {
  final ItemModel item;

  const ItemDetailsScreen({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: item.id,
                child: CachedNetworkImage(
                  imageUrl: item.imgUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    item.itemName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '₹${item.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    item.details,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}