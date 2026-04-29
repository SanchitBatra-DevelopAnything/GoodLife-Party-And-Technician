import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:goodlife_party/providers/area_provider.dart';
import 'package:goodlife_party/routes/app_routes.dart';
import 'package:goodlife_party/routes/route_generator.dart';
import 'package:goodlife_party/theme/app_theme.dart';
import 'package:provider/provider.dart';

import 'providers/locale_provider.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localeProvider = LocaleProvider();
  await localeProvider.loadLocale();

  runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: localeProvider),
      ChangeNotifierProvider(create: (_) => AreaProvider()),
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

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}