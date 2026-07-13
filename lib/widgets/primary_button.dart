import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isIOS;

  const PrimaryButton({
    required this.text,
    required this.onPressed,
    required this.isIOS,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: isIOS
          ? CupertinoButton.filled(
              onPressed: onPressed,
              child: Text(text),
            )
          : ElevatedButton(
              onPressed: onPressed,
              child: Text(text),
            ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isIOS;

  const SecondaryButton({
    required this.text,
    required this.onPressed,
    required this.isIOS,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: isIOS
          ? CupertinoButton(
              onPressed: onPressed,
              child: Text(text),
            )
          : OutlinedButton(
              onPressed: onPressed,
              child: Text(text),
            ),
    );
  }
}