import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:goodlife_party/providers/auth_provider.dart';
import 'package:goodlife_party/providers/cart_provider.dart';
import 'package:goodlife_party/providers/categories_provider.dart';
import 'package:goodlife_party/routes/app_routes.dart';
import 'package:goodlife_party/widgets/bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/category_item.dart';
import '../widgets/category_shimmer.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => CategoriesScreenState();
}

class CategoriesScreenState extends State<CategoriesScreen> {
  String userName = '';

  @override
void initState() {
  super.initState();

  loadUser();

  Future.microtask(() async {
    await Provider.of<CartProvider>(
      context,
      listen: false,
    ).loadLocalCart();

    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    await Provider.of<CategoryProvider>(
      context,
      listen: false,
    ).fetchCategories(
      machineIds: authProvider.machineIds,
    );
  });
}

  Future<void> loadUser() async {
  final authProvider = context.read<AuthProvider>();

  setState(() {
    userName = authProvider.distributorName;
  });
}

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(26),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.18),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My Machines',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.4,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          'Welcome back, $userName',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color:
                                Colors.white.withOpacity(0.85),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.build,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              child: TextField(
                onChanged: provider.search,
                decoration: InputDecoration(
                  hintText: 'Search machines...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding:
                      const EdgeInsets.symmetric(
                    vertical: 0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            Expanded(
              child: provider.isLoading
                  ? const CategoryShimmer()
                  : GridView.builder(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      itemCount:
                          provider.categories.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.85,
                      ),
                      itemBuilder:
                          (context, index) {
                        final category =
                            provider.categories[index];

                        return CategoryItem(
                          category: category,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.items,
                              arguments: {
                                'categoryId':
                                    category.id,
                                'categoryName':
                                    category.name,
                              },
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 100),
    );
  }
}