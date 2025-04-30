import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderStatusCard extends StatelessWidget {
  final String orderNumber;
  final String customerName;
  final double total;
  final String status;
  final DateTime date;
  final VoidCallback? onTap;

  const OrderStatusCard({
    Key? key,
    required this.orderNumber,
    required this.customerName,
    required this.total,
    required this.status,
    required this.date,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Gunakan warna yang sama untuk seluruh card
    final cardColor = theme.brightness == Brightness.dark 
        ? colorScheme.surfaceVariant
        : colorScheme.surface;

    // Warna teks yang sesuai dengan tema
    final textColor = theme.brightness == Brightness.dark
        ? colorScheme.onSurface
        : colorScheme.onSurface;
        
    final subtleTextColor = theme.brightness == Brightness.dark
        ? colorScheme.onSurface.withOpacity(0.7)
        : colorScheme.onSurfaceVariant;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shadowColor: colorScheme.shadow.withOpacity(0.4),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: colorScheme.primary.withOpacity(0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan indikator status - warna sama dengan card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cardColor, // Menggunakan warna yang sama dengan content area
                border: Border(
                  left: BorderSide(
                    color: _getStatusColor(status, colorScheme),
                    width: 4,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #$orderNumber',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  _buildStatusChip(context),
                ],
              ),
            ),
            
            // Garis pemisah halus untuk memisahkan header dengan content
            Divider(
              height: 1,
              thickness: 1,
              color: colorScheme.outlineVariant.withOpacity(0.3),
            ),
            
            // Content area
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer info
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline, 
                        size: 18, 
                        color: subtleTextColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          customerName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Order date
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today, 
                        size: 18, 
                        color: subtleTextColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(date),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: subtleTextColor,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Total amount dengan background lebih menarik
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.attach_money, 
                          size: 20, 
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatCurrency(total),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
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

  Widget _buildStatusChip(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _getStatusColor(status, colorScheme);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(status),
            size: 14,
            color: statusColor,
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final orderDate = DateTime(date.year, date.month, date.day);
    
    if (orderDate == today) {
      return 'Hari ini, ${DateFormat('HH:mm').format(date)}';
    } else if (orderDate == today.subtract(const Duration(days: 1))) {
      return 'Kemarin, ${DateFormat('HH:mm').format(date)}';
    } else {
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    }
  }

  // Get appropriate icon for status
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'processing':
        return Icons.sync;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  // Get theme-aware status color
  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'pending':
        return colorScheme.error.withBlue(128); // Orange-ish
      case 'processing':
        return colorScheme.primary;
      case 'completed':
        return colorScheme.tertiary.withBlue(100); // Green-ish
      case 'cancelled':
        return colorScheme.error;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }
}