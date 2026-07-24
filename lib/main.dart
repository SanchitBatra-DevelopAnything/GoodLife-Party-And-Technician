import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:goodlife_party/providers/area_provider.dart';
import 'package:goodlife_party/providers/auth_provider.dart';
import 'package:goodlife_party/providers/cart_provider.dart';
import 'package:goodlife_party/providers/categories_provider.dart';
import 'package:goodlife_party/providers/items_provider.dart';
import 'package:goodlife_party/providers/order_provider.dart';
import 'package:goodlife_party/providers/outstanding_balance_provider.dart';
import 'package:goodlife_party/providers/service_request_provider.dart';
import 'package:goodlife_party/providers/signup_provider.dart';
import 'package:goodlife_party/providers/technician_auth_provider.dart';
import 'package:goodlife_party/providers/technician_service_request_provider.dart';
import 'package:goodlife_party/providers/whats_new_provider.dart';
import 'package:goodlife_party/routes/app_routes.dart';
import 'package:goodlife_party/routes/route_generator.dart';
import 'package:goodlife_party/theme/app_theme.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'providers/locale_provider.dart';
import 'l10n/app_localizations.dart';
import 'services/notification_service.dart';
import 'widgets/session_monitor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localeProvider = LocaleProvider();
  await localeProvider.loadLocale();

  await Hive.initFlutter();
  await Firebase.initializeApp();

  // Initialize notifications BEFORE loading saved sessions so APNs/FCM tokens are ready
  await NotificationService().initialize();

  final authProvider = AuthProvider();
  NotificationService().addTokenRefreshListener(
    (token) => authProvider.syncDeviceToken(token),
  );
  await authProvider.loadSavedContext();

  final technicianAuthProvider = TechnicianAuthProvider();
  NotificationService().addTokenRefreshListener(
    (token) => technicianAuthProvider.syncDeviceToken(token),
  );
  await technicianAuthProvider.loadSavedContext();

  // Start real-time outstanding balance listener if party is already logged in
  final outstandingBalanceProvider = OutstandingBalanceProvider();
  if (authProvider.isLoggedIn && authProvider.mobile.isNotEmpty) {
    outstandingBalanceProvider.startListening(authProvider.mobile);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider(create: (_) => AreaProvider()),
        ChangeNotifierProvider(create: (_) => SignupProvider()),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: outstandingBalanceProvider),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ItemsProvider()),
        ChangeNotifierProvider(create: (_) => WhatsNewProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ServiceRequestProvider()),
        ChangeNotifierProvider.value(value: technicianAuthProvider),
        ChangeNotifierProvider(
          create: (_) => TechnicianServiceRequestProvider(),
        ),
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

    return SessionMonitor(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: NotificationService.navigatorKey,

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
      ),
    );
  }
}
