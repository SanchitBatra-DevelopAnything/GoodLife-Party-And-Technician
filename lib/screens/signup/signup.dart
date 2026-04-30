import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goodlife_party/providers/signup_provider.dart';
import 'package:provider/provider.dart';

import '../../providers/area_provider.dart';
import '../../models/area_model.dart';
import '../../widgets/image_picker_widget.dart';
import '../../widgets/app_logo.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();

  AreaModel? selectedArea;
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<AreaProvider>(context, listen: false).loadAreas(),
    );
  }

  void onSignup() async {
    if (usernameController.text.isEmpty ||
        contactController.text.isEmpty ||
        selectedArea == null ||
        selectedImage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final signupProvider = Provider.of<SignupProvider>(context, listen: false);

    try {
      await signupProvider.signup(
        username: usernameController.text,
        contact: contactController.text,
        area: selectedArea!.name,
        image: selectedImage!,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Signup successful')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AreaProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const AppLogo(),

              const SizedBox(height: 20),

              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: contactController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // ✅ only numbers
                  LengthLimitingTextInputFormatter(
                    10,
                  ), // ✅ limit (adjust if needed)
                ],
                decoration: const InputDecoration(labelText: 'Contact'),
              ),

              const SizedBox(height: 12),

              provider.isLoading
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<AreaModel>(
                      value: selectedArea,
                      hint: const Text('Select Area'),
                      items: provider.areas
                          .map(
                            (area) => DropdownMenuItem(
                              value: area,
                              child: Text(area.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => selectedArea = value);
                      },
                    ),

              const SizedBox(height: 20),

              const Text(
                'Please upload a photo of the machine along with your selfie. '
                'Without this, your request will not be approved.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              ImagePickerWidget(
                onImageSelected: (file) {
                  selectedImage = file;
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onSignup,
                  child: Consumer<SignupProvider>(
                    builder: (_, signupProvider, __) {
                      if (signupProvider.isLoading) {
                        // ✅ Phase 2: Submitting (after upload complete)
                        if (signupProvider.isSubmitting) {
                          return const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        }

                        // ✅ Phase 1: Upload progress
                        final percent = (signupProvider.uploadProgress * 100)
                            .toStringAsFixed(0);

                        return Text('Uploading... $percent%');
                      }

                      return const Text('Sign Up');
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
