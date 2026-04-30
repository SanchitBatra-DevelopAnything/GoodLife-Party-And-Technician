import 'package:flutter/material.dart';

class SignupSuccessScreen extends StatelessWidget {
  const SignupSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signup Successful'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.green,
            ),

            const SizedBox(height: 24),

            const Text(
              'You have signed up successfully!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
  'Your request is currently under approval.\n\n'
  'We will notify you once it is approved.\n\n'
  'You can close the app now and come back later to log in.',
  textAlign: TextAlign.center,
  style: TextStyle(
    fontSize: 16,
    color: Colors.black54,
  ),
),
          ],
        ),
      ),
    );
  }
}