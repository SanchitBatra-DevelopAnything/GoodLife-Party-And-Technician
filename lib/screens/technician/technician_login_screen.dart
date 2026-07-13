import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/technician_auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/local_storage_service.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/primary_button.dart';

class TechnicianLoginScreen extends StatefulWidget {
  const TechnicianLoginScreen({super.key});

  @override
  State<TechnicianLoginScreen> createState() => _TechnicianLoginScreenState();
}

class _TechnicianLoginScreenState extends State<TechnicianLoginScreen> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isAutoLoggingIn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLogin();
    });
  }

  Future<void> _initializeLogin() async {
    final auth = context.read<TechnicianAuthProvider>();

    if (auth.isLoggedIn) {
      final isValid = await auth.validateSession();
      if (!mounted) return;

      if (isValid) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.technicianServiceRequests,
          (route) => false,
        );
      }
      return;
    }

    final savedCredentials =
        await LocalStorageService.getTechnicianCredentials();
    if (savedCredentials == null || !mounted) return;

    _mobileController.text = savedCredentials.mobile;
    _passwordController.text = savedCredentials.password;
    await _handleLogin(isAutoLogin: true);
  }

  Future<void> _handleLogin({bool isAutoLogin = false}) async {
    final mobile = _mobileController.text.trim();
    final password = _passwordController.text;

    if (mobile.length != 10) {
      if (!isAutoLogin) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid 10-digit mobile number')),
        );
      }
      return;
    }

    if (password.isEmpty) {
      if (!isAutoLogin) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your password')),
        );
      }
      return;
    }

    if (isAutoLogin) {
      setState(() => _isAutoLoggingIn = true);
    }

    final auth = context.read<TechnicianAuthProvider>();
    try {
      await auth.login(mobile: mobile, password: password);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.technicianServiceRequests,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      await LocalStorageService.clearTechnicianCredentials();
      if (!isAutoLogin) {
        final message = e.toString().contains('Invalid password')
            ? 'Invalid password'
            : e.toString().contains('not found')
                ? 'Technician not found'
                : 'Login failed. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } finally {
      if (mounted && isAutoLogin) {
        setState(() => _isAutoLoggingIn = false);
      }
    }
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<TechnicianAuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Technician Login')),
      body: SafeArea(
        child: _isAutoLoggingIn
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Center(child: AppLogo()),
              const SizedBox(height: 40),
              TextField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  border: OutlineInputBorder(),
                  counterText: '',
                  prefixIcon: Icon(Icons.phone_rounded),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Use your registered technician mobile and password.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                text: auth.isLoading ? 'Logging in...' : 'Login',
                onPressed: auth.isLoading ? null : _handleLogin,
                isIOS: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
