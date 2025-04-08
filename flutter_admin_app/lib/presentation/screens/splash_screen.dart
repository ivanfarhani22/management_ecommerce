import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/loading_indicator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure full screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    
    // Simulate app initialization
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 2));
    
    // TODO: Add actual authentication check
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  void dispose() {
    // Restore default system UI modes
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual, 
      overlays: SystemUiOverlay.values
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TODO: Replace with your app logo
            Image.asset(
            'assets/images/icons/logo.jpg',
            width: 100,
            height: 100,
            fit: BoxFit.cover, // Menyesuaikan tampilan gambar
          ),
            const SizedBox(height: 20),
            const Text(
              'Admin Toko',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const LoadingIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}