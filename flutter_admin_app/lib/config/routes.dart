import 'package:flutter/material.dart';

// Import screens
import '../presentation/screens/splash_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/forgot_password_screen.dart';
import '../presentation/screens/dashboard/dashboard_screen.dart';
import '../presentation/screens/inventory/inventory_screen.dart';
import '../presentation/screens/inventory/add_product_screen.dart';
import '../presentation/screens/inventory/edit_product_screen.dart';
import '../presentation/screens/orders/orders_list_screen.dart';
import '../presentation/screens/orders/order_details_screen.dart';
import '../presentation/screens/transactions/transactions_screen.dart';
import '../presentation/screens/wholesale/wholesale_notes_screen.dart';
import '../presentation/screens/reports/financial_reports_screen.dart';

class AppRoutes {
  // Route names as constants
  static const String splash = '/';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String inventory = '/inventory';
  static const String addProduct = '/inventory/add-product';
  static const String editProduct = '/inventory/edit-product';
  static const String showProduct = '/inventory/show-product';
  static const String orders = '/orders';
  static const String orderDetails = '/orders/details';
  static const String transactions = '/transactions';
  static const String wholesaleNotes = '/wholesale-notes';
  static const String financialReports = '/reports/financial';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      
      case inventory:
        return MaterialPageRoute(builder: (_) => const InventoryScreen());
      
      case addProduct:
        return MaterialPageRoute(builder: (_) => const AddProductScreen());
      
      case editProduct:
        // Robust argument handling
        if (settings.arguments is! Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(
                child: Text('Invalid arguments for edit product route'),
              ),
            ),
          );
        }
        
        final args = settings.arguments as Map<String, dynamic>;
        
        return MaterialPageRoute(
          builder: (_) => EditProductScreen(product: args)
        );
      
      case orders:
        return MaterialPageRoute(builder: (_) => const OrdersListScreen());
      
      case orderDetails:
        // Expects order ID as an argument
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => OrderDetailsScreen(orderId: args['orderId'])
        );
      
      case transactions:
        return MaterialPageRoute(builder: (_) => const TransactionsScreen());
      
      case wholesaleNotes:
        return MaterialPageRoute(builder: (_) => const WholesaleNotesScreen());
      
      case financialReports:
        return MaterialPageRoute(builder: (_) => const FinancialReportsScreen());
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  // Helper method to navigate with named routes
  static void navigateTo(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  // Helper method to replace current route
  static void replaceWith(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }
}