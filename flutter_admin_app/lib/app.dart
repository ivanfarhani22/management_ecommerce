import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Config Imports
import 'config/routes.dart';
import 'config/theme.dart';

// Screen Imports
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';

// Bloc Imports
import 'presentation/blocs/auth/auth_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // App Configuration
      title: 'Management E-Commerce Admin',
      debugShowCheckedModeBanner: false,

      // Localization Support
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('id', ''), // Indonesian
      ],

      // Theme Configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Navigation
      onGenerateRoute: AppRoutes.generateRoute,
      
      // Fallback Home Screen with Authentication State Management
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          switch (state.status) {
            case AuthStatus.initial:
              return const SplashScreen();
            case AuthStatus.authenticated:
              return const DashboardScreen();
            case AuthStatus.unauthenticated:
              return const LoginScreen();
            case AuthStatus.loading:
              return const SplashScreen();
            case AuthStatus.error:
              return const LoginScreen(); // Or an error screen
          }
        },
      ),

      // Additional App Configurations
      locale: const Locale('id', ''), // Default to Indonesian
      builder: (context, child) {
        return MediaQuery(
          // Prevent text scaling affecting app design
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
          child: child!,
        );
      },
    );
  }
}