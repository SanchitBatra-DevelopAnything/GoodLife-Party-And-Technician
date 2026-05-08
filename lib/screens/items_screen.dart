
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:goodlife_party/providers/items_provider.dart';
import 'package:goodlife_party/widgets/bottom_nav_bar.dart';
import 'package:goodlife_party/widgets/category_shimmer.dart';
import 'package:goodlife_party/widgets/item_card.dart';
import 'package:provider/provider.dart';


class ItemsScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const ItemsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context
          .read<ItemsProvider>()
          .fetchItems(widget.categoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ItemsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: GestureDetector(
  behavior: HitTestBehavior.translucent,
  onTap: () {
    FocusScope.of(context).unfocus();
  },
  child: Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: CupertinoSearchTextField(
          controller: _searchController,
          onChanged: provider.search,
        ),
      ),
      Expanded(
        child: provider.isLoading
            ? const CategoryShimmer()
            : provider.items.isEmpty
                ? const Center(
                    child: Text('No Items Found'),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: provider.items.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.62,
                    ),
                    itemBuilder: (context, index) {
                      final item = provider.items[index];

                      return RepaintBoundary(
                        child: ItemCard(item: item),
                      );
                    },
                  ),
      ),
    ],
  ),
),

bottomNavigationBar: AppBottomNavBar(
  currentIndex: 1,
  onTap: (index) {
    // TODO: Navigation logic
  },
),

    );
  }
}