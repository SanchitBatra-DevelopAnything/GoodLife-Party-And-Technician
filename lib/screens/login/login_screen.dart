import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/area_provider.dart';
import '../../models/area_model.dart';
import '../../widgets/app_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController contactController = TextEditingController();
  AreaModel? selectedArea;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AreaProvider>(context, listen: false).loadAreas();
    });
  }

  Future<void> handleLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final mobile = contactController.text.trim();

    if (mobile.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid mobile number")),
      );
      return;
    }

    if (selectedArea == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select area")),
      );
      return;
    }

    try {
      await authProvider.login(
        mobile: mobile,
        areaName: selectedArea!.name,
      );

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
  context,
  '/categories',
  (route) => false,
);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final areaProvider = Provider.of<AreaProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number',
                    border: OutlineInputBorder(),
                    counterText: "",
                  ),
                ),

                const SizedBox(height: 20),

                /// 📍 Area Dropdown
                areaProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : DropdownButtonFormField<AreaModel>(
                        value: selectedArea,
                        hint: const Text('Select Area'),
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
                        : const Text(
                            "Login",
                            style: TextStyle(fontSize: 16),
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
}