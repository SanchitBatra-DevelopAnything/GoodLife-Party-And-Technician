import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/area_provider.dart';
import '../../providers/outstanding_balance_provider.dart';
import '../../models/area_model.dart';
import '../../services/local_storage_service.dart';
import '../../widgets/app_logo.dart';
import '../../l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController contactController = TextEditingController();
  AreaModel? selectedArea;
  bool _isAutoLoggingIn = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLogin();
    });
  }

  Future<void> _initializeLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.isLoggedIn) {
      final isValid = await authProvider.validateSession();
      if (!mounted) return;

      if (isValid) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/inventory',
          (route) => false,
        );
      }
      return;
    }

    final areaProvider = Provider.of<AreaProvider>(context, listen: false);
    await areaProvider.loadAreas();

    final savedCredentials = await LocalStorageService.getUserCredentials();
    SavedUserCredentials? credentials = savedCredentials;

    if (credentials == null) {
      final mobile = await LocalStorageService.getMobile();
      final areaName = await LocalStorageService.getArea();
      if (mobile != null && areaName != null) {
        credentials = SavedUserCredentials(
          mobile: mobile,
          areaName: areaName,
        );
        await LocalStorageService.saveUserCredentials(
          mobile: mobile,
          areaName: areaName,
        );
      }
    }

    if (credentials == null || !mounted) return;

    contactController.text = credentials.mobile;
    final matchingAreas = areaProvider.areas
        .where((area) => area.name == credentials!.areaName);
    final matchingArea =
        matchingAreas.isNotEmpty ? matchingAreas.first : null;

    if (matchingArea != null) {
      setState(() => selectedArea = matchingArea);
      await handleLogin(isAutoLogin: true);
    }
  }

  Future<void> handleLogin({bool isAutoLogin = false}) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    final mobile = contactController.text.trim();

    if (mobile.length != 10) {
      if (!isAutoLogin) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.enterValidMobile)),
        );
      }
      return;
    }

    if (selectedArea == null) {
      if (!isAutoLogin) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.pleaseSelectArea)),
        );
      }
      return;
    }

    if (isAutoLogin) {
      setState(() => _isAutoLoggingIn = true);
    }

    try {
      await authProvider.login(
        mobile: mobile,
        areaName: selectedArea!.name,
      );

      // Start real-time outstanding-balance listener for this party
      if (mounted) {
        final balanceProvider =
            Provider.of<OutstandingBalanceProvider>(context, listen: false);
        balanceProvider.startListening(mobile);
      }

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/inventory',
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      await LocalStorageService.clearUserCredentials();
      if (!isAutoLogin) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.loginFailed)),
        );
      }
    } finally {
      if (mounted && isAutoLogin) {
        setState(() => _isAutoLoggingIn = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final areaProvider = Provider.of<AreaProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.login),
        elevation: 0,
      ),
      body: SafeArea(
        child: _isAutoLoggingIn
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                /// ✅ LOGO
                const Center(child: AppLogo()),

                const SizedBox(height: 40),

                /// 📱 Mobile Input
                TextField(
                  controller: contactController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    labelText: l10n.mobileNumber,
                    border: const OutlineInputBorder(),
                    counterText: "",
                  ),
                ),

                const SizedBox(height: 20),

                /// 📍 Area Dropdown
                areaProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : DropdownButtonFormField<AreaModel>(
                        value: selectedArea,
                        hint: Text(l10n.selectArea),
                        items: areaProvider.areas
                            .map(
                              (area) => DropdownMenuItem<AreaModel>(
                                value: area,
                                child: Text(area.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => selectedArea = value);
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),

                const SizedBox(height: 30),

                /// 🔘 Login Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        authProvider.isLoading ? null : handleLogin,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: authProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            l10n.login,
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    contactController.dispose();
    super.dispose();
  }
}