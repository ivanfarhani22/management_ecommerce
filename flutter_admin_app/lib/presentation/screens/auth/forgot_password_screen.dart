import 'package:flutter/material.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/error_dialog.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  void _resetPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        // TODO: Implement actual password reset logic
        await Future.delayed(const Duration(seconds: 2));
        
        // Show success dialog
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Password Reset'),
            content: const Text('A password reset link has been sent to your email.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Go back to login
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } catch (e) {
        // Show error dialog
        ErrorDialog.show(
          context, 
          title: 'Reset Failed', 
          message: e.toString()
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // TODO: Replace with appropriate icon
                const Icon(
                  Icons.lock_reset,
                  size: 100,
                  color: Colors.grey,
                ),
                
                const SizedBox(height: 30),
                
                const Text(
                  'Reset Your Password',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                const Text(
                  'Enter the email associated with your account. '
                  'We\'ll send you a link to reset your password.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                
                const SizedBox(height: 30),
                
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    // Basic email validation
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 30),
                
                CustomButton(
                  text: 'Send Reset Link',
                  onPressed: _resetPassword,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}