import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:goodlife_party/providers/area_provider.dart';
import 'package:goodlife_party/providers/auth_provider.dart';
import 'package:goodlife_party/providers/cart_provider.dart';
import 'package:goodlife_party/providers/categories_provider.dart';
import 'package:goodlife_party/providers/items_provider.dart';
import 'package:goodlife_party/providers/order_provider.dart';
import 'package:goodlife_party/providers/signup_provider.dart';
import 'package:goodlife_party/providers/whats_new_provider.dart';
import 'package:goodlife_party/routes/app_routes.dart';
import 'package:goodlife_party/routes/route_generator.dart';
import 'package:goodlife_party/theme/app_theme.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'providers/locale_provider.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localeProvider = LocaleProvider();
  await localeProvider.loadLocale();

  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Firebase.initializeApp();

  runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: localeProvider),
      ChangeNotifierProvider(create: (_) => AreaProvider()),
      ChangeNotifierProvider(create: (_) => SignupProvider()),
      ChangeNotifierProvider(create: (_)=> AuthProvider()),
      ChangeNotifierProvider(create: (_)=> CartProvider()),
      ChangeNotifierProvider(create: (_)=> CategoryProvider()),
      ChangeNotifierProvider(create: (_)=>ItemsProvider()),
      ChangeNotifierProvider(create: (_)=> WhatsNewProvider()),
      ChangeNotifierProvider(create: (_)=>OrderProvider())
    ],
    child: const MyApp(),
  ),
);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // ✅ KEEP YOUR THEME EXACTLY SAME
      theme: AppTheme.getMaterialTheme(),

      // ✅ KEEP YOUR ROUTING EXACTLY SAME
      initialRoute: AppRoutes.home,
      onGenerateRoute: RouteGenerator.generateRoute,

      // ✅ ADD ONLY LOCALIZATION
      locale: provider.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
    );
  }
}