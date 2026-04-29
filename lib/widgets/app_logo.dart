import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Replace with your asset
        Image.asset(
          'assets/logo.jpeg',
          height: 100,
        ),
        const SizedBox(height: 12),
        Text(
          'Goodlife Machines Pvt. Ltd.',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ],
    );
  }
}