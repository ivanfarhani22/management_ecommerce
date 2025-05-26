import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../../data/api/auth_api.dart';
import '../../../data/api/api_client.dart';
import '../../../data/models/user.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  final apiClient = ApiClient(
    storage: const FlutterSecureStorage(),
  );
  
  late final AuthApi _authApi = AuthApi(apiClient);

  void _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Check terms agreement
      if (!_agreeToTerms) {
        _showErrorDialog('Please agree to the Terms and Conditions');
        return;
      }

      setState(() => _isLoading = true);

      try {
        // Debug logging
        print('Registering with:');
        print('Name: ${_nameController.text.trim()}');
        print('Email: ${_emailController.text.trim().toLowerCase()}');
        print('Password length: ${_passwordController.text.length}');
        print('Password confirmation matches: ${_passwordController.text == _confirmPasswordController.text}');
        
        // Use AuthApi register method with correct parameter names
        final user = await _authApi.register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim().toLowerCase(),
          password: _passwordController.text,
          passwordConfirmation: _confirmPasswordController.text, // Make sure this matches what AuthApi expects
        );
        
        // Registration successful - token is already saved by AuthApi
        if (user.token != null && user.token!.isNotEmpty) {
          _showSuccessDialog();
        } else {
          _showErrorDialog('Registration successful but no token received. Please login.');
        }
        
      } catch (e) {
        print('Registration error: $e'); // Debug logging
        String errorMessage = _getErrorMessage(e.toString());
        _showErrorDialog(errorMessage);
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  String _getErrorMessage(String error) {
    // Handle specific Laravel validation errors
    if (error.contains('validated does not exist')) {
      return 'Server configuration error. Backend is using validated() incorrectly.';
    } else if (error.contains('password') && (error.contains('confirmation') || error.contains('confirmed'))) {
      return 'Password confirmation does not match. Please check your passwords.';
    } else if (error.contains('email') && (error.contains('already') || error.contains('taken') || error.contains('unique'))) {
      return 'This email is already registered. Please use a different email or try logging in.';
    } else if (error.contains('name') && error.contains('required')) {
      return 'Name is required.';
    } else if (error.contains('email') && error.contains('required')) {
      return 'Email is required.';
    } else if (error.contains('password') && error.contains('required')) {
      return 'Password is required.';
    } else if (error.contains('password') && error.contains('min')) {
      return 'Password must be at least 8 characters long.';
    } else if (error.contains('Validation failed') || error.contains('422')) {
      return 'Please check your input and try again.';
    } else if (error.contains('Registration failed')) {
      return 'Registration failed. Please check your information and try again.';
    } else if (error.contains('network') || error.contains('connection')) {
      return 'Network error. Please check your internet connection and try again.';
    } else if (error.contains('timeout')) {
      return 'Request timeout. Please try again.';
    } else if (error.contains('500') || error.contains('Server Error')) {
      return 'Server error. Please fix the backend configuration or contact support.';
    } else if (error.contains('401') || error.contains('403')) {
      return 'Authentication error. Please try again.';
    }
    return 'Registration failed. Please try again.';
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Registration Successful'),
          ],
        ),
        content: const Text('Your account has been created successfully! Welcome aboard!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/dashboard');
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Registration Failed'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 255) { // Changed to match backend validation
      return 'Name must be less than 255 characters';
    }
    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(value.trim())) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    }
    // More comprehensive email validation
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    if (value.trim().length > 255) { // Changed to match backend validation
      return 'Email address is too long';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (value.length > 50) {
      return 'Password must be less than 50 characters';
    }
    
    // Updated validation to match Laravel backend requirements (without symbols)
    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    
    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    
    // Check for at least one number
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                // Logo
                SizedBox(
                  height: 100,
                  child: Center(
                    child: Image.asset(
                      'assets/images/icons/logo.jpg',
                      height: 80,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.account_circle,
                          size: 80,
                          color: Colors.grey,
                        );
                      },
                    ),
                  ),
                ),

                const Text(
                  'Create Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign up to get started',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 30),
                
                // Full Name Field
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Full Name',
                  prefixIcon: Icons.person,
                  keyboardType: TextInputType.name,
                  validator: _validateName,
                ),
                const SizedBox(height: 16),
                
                // Email Field
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email Address',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),
                
                // Password Field
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  prefixIcon: Icons.lock,
                  obscureText: _obscurePassword,
                  suffixIcon: _obscurePassword 
                    ? Icons.visibility_off 
                    : Icons.visibility,
                  onSuffixIconTap: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  validator: _validatePassword,
                ),
                const SizedBox(height: 8),
                
                // Password requirements hint
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password must contain:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• At least 8 characters\n• One uppercase letter (A-Z)\n• One lowercase letter (a-z)\n• One number (0-9)',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Confirm Password Field
                CustomTextField(
                  controller: _confirmPasswordController,
                  labelText: 'Confirm Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: _obscureConfirmPassword 
                    ? Icons.visibility_off 
                    : Icons.visibility,
                  onSuffixIconTap: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  validator: _validateConfirmPassword,
                ),
                const SizedBox(height: 20),
                
                // Terms and Conditions Checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreeToTerms = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _agreeToTerms = !_agreeToTerms;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Row(
                            children: [
                              const Text('I agree to the '),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushNamed('/terms');
                                },
                                child: const Text(
                                  'Terms and Conditions',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Register Button
                CustomButton(
                  text: 'Create Account',
                  onPressed: _register,
                  isLoading: _isLoading,
                ),
                
                const SizedBox(height: 24),
                
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      child: const Text(
                        'Sign In',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
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