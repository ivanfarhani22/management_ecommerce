import 'package:flutter/material.dart';

class OrderTimeline extends StatelessWidget {
  final String currentStatus;
  final List<String> statusOptions;
  final Map<String, Color> statusColors;

  const OrderTimeline({
    Key? key,
    required this.currentStatus,
    required this.statusOptions,
    required this.statusColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filter and sort the status options
    // We want to show only the statuses that are relevant based on the natural order
    // For example, if the current status is "shipped", we show "pending", "processing", "shipped"
    // We exclude "cancelled" unless it's the current status
    
    List<String> displayStatuses = [];
    
    if (currentStatus == 'cancelled') {
      displayStatuses = ['cancelled'];
    } else {
      final normalStatuses = ['pending', 'processing', 'shipped', 'delivered'];
      
      // Find the index of the current status
      final currentIndex = normalStatuses.indexOf(currentStatus.toLowerCase());
      if (currentIndex >= 0) {
        // Include all statuses up to and including the current one
        displayStatuses = normalStatuses.sublist(0, currentIndex + 1);
      } else {
        // Fallback: just use current status
        displayStatuses = [currentStatus.toLowerCase()];
      }
    }
    
    return Column(
      children: [
        Row(
          children: List.generate(displayStatuses.length * 2 - 1, (index) {
            // Even indices represent status dots, odd indices represent connectors
            if (index % 2 == 0) {
              final statusIndex = index ~/ 2;
              final status = displayStatuses[statusIndex];
              
              return Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: statusColors[status] ?? Colors.grey,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIconForStatus(status),
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatStatus(status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColors[status] ?? Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            } else {
              return Expanded(
                flex: 1,
                child: Container(
                  height: 2,
                  color: Colors.grey[300],
                ),
              );
            }
          }),
        ),
      ],
    );
  }
  
  // Get an appropriate icon for each status
  IconData _getIconForStatus(String status) {
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
        return Icons.circle;
    }
  }
  
  // Format status for display
  String _formatStatus(String status) {
    if (status.isEmpty) return '';
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }
}