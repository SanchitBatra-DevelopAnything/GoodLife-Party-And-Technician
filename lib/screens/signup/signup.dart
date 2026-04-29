import 'dart:io';
import 'package:flutter/material.dart';
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
    Future.microtask(() =>
        Provider.of<AreaProvider>(context, listen: false).loadAreas());
  }

  void onSignup() {
    // Simple validation
    if (usernameController.text.isEmpty ||
        contactController.text.isEmpty ||
        selectedArea == null ||
        selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    // TODO: Call signup API
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
                decoration: const InputDecoration(labelText: 'Contact'),
              ),

              const SizedBox(height: 12),

              provider.isLoading
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<AreaModel>(
                      value: selectedArea,
                      hint: const Text('Select Area'),
                      items: provider.areas
                          .map((area) => DropdownMenuItem(
                                value: area,
                                child: Text(area.name),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => selectedArea = value);
                      },
                    ),

              const SizedBox(height: 20),

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
                  child: const Text('Sign Up'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}