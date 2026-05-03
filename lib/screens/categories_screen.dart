import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:goodlife_party/providers/categories_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/category_item.dart';
import '../widgets/category_shimmer.dart';
import '../widgets/bottom_nav_bar.dart';

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

    Future.microtask(() =>
        Provider.of<CategoryProvider>(context, listen: false)
            .fetchCategories());
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('logged_in_user');

    if (userString != null) {
      final userMap = jsonDecode(userString);

      setState(() {
        userName = userMap['distributorName'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      // 🔴 AppBar
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Hello, $userName',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),

      body: GestureDetector(
  behavior: HitTestBehavior.opaque, // 👈 IMPORTANT
  onTap: () {
    FocusScope.of(context).unfocus();
  },
  child: Column(
    children: [
      // 🔍 Search Bar
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: TextField(
          onChanged: provider.search,
          decoration: InputDecoration(
            hintText: 'Search categories...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),

      // 📦 Categories Grid
      Expanded(
        child: provider.isLoading
            ? const CategoryShimmer()
            : GridView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                itemCount: provider.categories.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  final category = provider.categories[index];

                  return CategoryItem(
                    category: category,
                    onTap: () {
                      FocusScope.of(context).unfocus(); // 👈 also dismiss here
                      debugPrint("Clicked ${category.name}");
                    },
                  );
                },
              ),
      ),
    ],
  ),
),

      // 🔻 Bottom Navigation
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          // TODO: Navigation logic later
        },
      ),
    );
  }
}