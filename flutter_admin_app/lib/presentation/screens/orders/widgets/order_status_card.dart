import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderStatusCard extends StatelessWidget {
  final String orderNumber;
  final String customerName;
  final double total;
  final String status;
  final DateTime date;
  final VoidCallback? onTap;
  final Function(String)? onStatusChange; // Callback to handle status changes
  // Add a list of available status options
  final List<String> statusOptions;

  const OrderStatusCard({
    super.key,
    required this.orderNumber,
    required this.customerName,
    required this.total,
    required this.status,
    required this.date,
    this.onTap,
    this.onStatusChange,
    this.statusOptions = const ['pending', 'processing', 'shipped', 'delivered', 'cancelled'],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Gunakan warna yang sama untuk seluruh card
    final cardColor = theme.brightness == Brightness.dark 
        ? colorScheme.surfaceContainerHighest
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
                  GestureDetector(
                    onTap: () => _showStatusChangeDialog(context),
                    child: _buildStatusChip(context),
                  ),
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
                  
                  // Status confirmation button
                  const SizedBox(height: 16),
                  _buildConfirmationButton(context),
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
            _formatStatusText(status),
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

  // Add the showStatusChangeDialog method
  void _showStatusChangeDialog(BuildContext context) {
    if (onStatusChange == null) return; // Don't show dialog if no callback

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ubah Status Pesanan #$orderNumber'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Pilih status baru:'),
              const SizedBox(height: 16),
              ...statusOptions.map((statusOption) {
                final bool isSelected = status.toLowerCase() == statusOption.toLowerCase();
                return ListTile(
                  title: Text(_formatStatusText(statusOption)),
                  selected: isSelected,
                  selectedTileColor: colorScheme.primaryContainer.withOpacity(0.2),
                  onTap: () {
                    Navigator.pop(context);
                    if (!isSelected) {
                      onStatusChange!(statusOption);
                    }
                  },
                  tileColor: isSelected 
                      ? colorScheme.primaryContainer.withOpacity(0.2)
                      : null,
                  leading: Icon(
                    _getStatusIcon(statusOption), 
                    color: _getStatusColor(statusOption, colorScheme)
                  ),
                );
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildConfirmationButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Determine next status and button appearance based on current status
    String nextStatus = '';
    String buttonText = '';
    Color buttonColor = Colors.transparent;
    IconData buttonIcon = Icons.check;
    bool showButton = true;
    
    switch (status.toLowerCase()) {
      case 'pending':
        nextStatus = 'processing';
        buttonText = 'Konfirmasi Pesanan';
        buttonColor = colorScheme.primary;
        buttonIcon = Icons.check_circle_outline;
        break;
      case 'processing':
        nextStatus = 'shipped';
        buttonText = 'Kirim Pesanan';
        buttonColor = colorScheme.tertiary;
        buttonIcon = Icons.local_shipping_outlined;
        break;
      case 'shipped':
        nextStatus = 'delivered';
        buttonText = 'Konfirmasi Pengiriman';
        buttonColor = colorScheme.tertiary.withBlue(100);
        buttonIcon = Icons.task_alt;
        break;
      case 'delivered':
        // No button needed for delivered orders
        showButton = false;
        break;
      case 'cancelled':
        // No button needed for cancelled orders
        showButton = false;
        break;
      default:
        nextStatus = 'processing';
        buttonText = 'Konfirmasi Pesanan';
        buttonColor = colorScheme.primary;
    }
    
    if (!showButton || onStatusChange == null) {
      return const SizedBox.shrink(); // Don't show button if no callback or status is final
    }
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showConfirmationDialog(context, nextStatus),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: buttonColor,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        icon: Icon(buttonIcon),
        label: Text(
          buttonText,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Dialog untuk konfirmasi perubahan status
  Future<void> _showConfirmationDialog(BuildContext context, String nextStatus) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Perubahan Status'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Apakah Anda yakin ingin mengubah status pesanan #$orderNumber dari "${_formatStatusText(status)}" menjadi "${_formatStatusText(nextStatus)}"?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Batal',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: const Text('Konfirmasi'),
              onPressed: () {
                Navigator.of(context).pop();
                if (onStatusChange != null) {
                  onStatusChange!(nextStatus);
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Format status text for better display
  String _formatStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
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
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
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
      case 'shipped':
        return colorScheme.secondary.withGreen(150); // Blue-green
      case 'delivered':
        return colorScheme.tertiary.withBlue(100); // Green-ish
      case 'cancelled':
        return colorScheme.error;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }
}