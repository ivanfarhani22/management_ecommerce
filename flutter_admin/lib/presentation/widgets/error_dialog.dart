import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? primaryButtonText;
  final VoidCallback? onPrimaryButtonPressed;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.primaryButtonText = 'OK',
    this.onPrimaryButtonPressed,
  });

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    String? primaryButtonText,
    VoidCallback? onPrimaryButtonPressed,
  }) {
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        title: title,
        message: message,
        primaryButtonText: primaryButtonText,
        onPrimaryButtonPressed: onPrimaryButtonPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onPrimaryButtonPressed?.call();
          },
          child: Text(primaryButtonText ?? 'OK'),
        ),
      ],
    );
  }
}