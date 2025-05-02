import 'package:flutter/material.dart';

class ShippingDetailsCard extends StatelessWidget {
  final Map<String, dynamic> shippingData;
  final VoidCallback onTrackShipment;

  const ShippingDetailsCard({
    Key? key,
    required this.shippingData,
    required this.onTrackShipment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract shipping details with fallbacks
    final method = shippingData['method'] ?? 'Standard Delivery';
    final courier = shippingData['courier'] ?? 'Default Courier';
    final trackingNumber = shippingData['tracking_number'];
    final estimatedDelivery = shippingData['estimated_delivery'];
    final address = shippingData['address'] ?? '';
    final recipient = shippingData['recipient_name'] ?? '';
    final phone = shippingData['recipient_phone'] ?? '';
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shipping Method
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    Icons.local_shipping,
                    color: Colors.blue[700],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        courier,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Tracking Info
            if (trackingNumber != null && trackingNumber.toString().isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tracking Number',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          trackingNumber.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: onTrackShipment,
                    icon: const Icon(Icons.track_changes),
                    label: const Text('Track'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
            
            // Estimated Delivery
            if (estimatedDelivery != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Colors.grey[600],
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Estimated Delivery:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    estimatedDelivery.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
            
            // Shipping Address
            if (address.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              
              const Text(
                'Shipping Address',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              
              if (recipient.isNotEmpty)
                Text(
                  recipient,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
              if (phone.isNotEmpty)
                Text(
                  phone,
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
                
              const SizedBox(height: 4),
              Text(
                address,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
            
            // Shipping Notes
            if (shippingData['notes'] != null && 
                shippingData['notes'].toString().isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Shipping Notes',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(shippingData['notes'].toString()),
              ),
            ],
          ],
        ),
      ),
    );
  }
}