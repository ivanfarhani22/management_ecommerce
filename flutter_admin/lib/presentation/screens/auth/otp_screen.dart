import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/error_dialog.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;

  const OTPScreen({super.key, required this.phoneNumber});

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final List<TextEditingController> _otpControllers = 
    List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = 
    List.generate(6, (_) => FocusNode());
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _verifyOTP() async {
    // Validate OTP
    final otp = _otpControllers.map((controller) => controller.text).join();
    
    if (otp.length != 6) {
      ErrorDialog.show(
        context, 
        title: 'Invalid OTP', 
        message: 'Please enter a complete 6-digit OTP'
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Implement actual OTP verification
      await Future.delayed(const Duration(seconds: 2));
      
      // Navigate to dashboard or set up profile
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } catch (e) {
      ErrorDialog.show(
        context, 
        title: 'Verification Failed', 
        message: e.toString()
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resendOTP() async {
    // TODO: Implement OTP resend logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP Resent')),
    );
  }

  Widget _buildOTPField(int index) {
    return SizedBox(
      width: 50,
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 20),
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          if (value.length == 1) {
            // Move focus to next field
            if (index < 5) {
              FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
            } else {
              // Last field, dismiss keyboard
              FocusScope.of(context).unfocus();
            }
          } else if (value.isEmpty && index > 0) {
            // Move focus to previous field if backspace
            FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Verify Your Phone Number',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Enter the 6-digit code sent to ${widget.phoneNumber}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            
            // OTP Input Fields
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                6, 
                (index) => _buildOTPField(index)
              ),
            ),
            
            const SizedBox(height: 30),
            
            CustomButton(
              text: 'Verify',
              onPressed: _verifyOTP,
              isLoading: _isLoading,
            ),
            
            const SizedBox(height: 20),
            
            TextButton(
              onPressed: _resendOTP,
              child: const Text('Resend OTP'),
            ),
          ],
        ),
      ),
    );
  }
}