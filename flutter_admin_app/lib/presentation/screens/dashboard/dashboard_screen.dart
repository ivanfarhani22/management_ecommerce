import 'package:flutter/material.dart';
import '../../../config/routes.dart';
import '../../widgets/app_bar.dart';
import './widgets/sales_chart.dart';
import './widgets/stock_alert.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Dashboard',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Summary Cards
            _buildSummaryCard(
              title: 'Total Sales',
              value: 'Rp 250,000,000',
              icon: Icons.attach_money,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            
            _buildSummaryCard(
              title: 'Total Orders',
              value: '1,234',
              icon: Icons.shopping_cart,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            
            // Sales Chart
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SalesChart(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Stock Alerts
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: StockAlert(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
        
        // Handle navigation based on index
        switch (index) {
          case 0:
            // Already on dashboard
            break;
          case 1:
            AppRoutes.navigateTo(context, AppRoutes.inventory);
            break;
          case 2:
            AppRoutes.navigateTo(context, AppRoutes.orders);
            break;
          case 3:
            AppRoutes.navigateTo(context, AppRoutes.transactions);
            break;
          case 4:
            // More options - could show a modal bottom sheet with additional options
            _showMoreOptions();
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory),
          label: 'Inventory',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt),
          label: 'Transactions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.more_horiz),
          label: 'More',
        ),
      ],
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Financial Reports'),
              onTap: () {
                Navigator.pop(context);
                AppRoutes.navigateTo(context, AppRoutes.financialReports);
              },
            ),
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('Wholesale Notes'),
              onTap: () {
                Navigator.pop(context);
                AppRoutes.navigateTo(context, AppRoutes.wholesaleNotes);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                AppRoutes.replaceWith(context, AppRoutes.login);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}