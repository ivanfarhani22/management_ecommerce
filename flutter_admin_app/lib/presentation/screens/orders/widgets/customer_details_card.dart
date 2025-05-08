import 'package:flutter/material.dart';

class CustomerDetailsCard extends StatelessWidget {
  final Map<String, dynamic> customerData;
  final VoidCallback onEmail;
  final VoidCallback onCall;

  const CustomerDetailsCard({
    super.key,
    required this.customerData,
    required this.onEmail,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final hasName = customerData['name'] != null && customerData['name'].toString().isNotEmpty;
    final hasEmail = customerData['email'] != null && customerData['email'].toString().isNotEmpty;
    final hasPhone = customerData['phone'] != null && customerData['phone'].toString().isNotEmpty;
    final hasAddress = customerData['address'] != null && customerData['address'].toString().isNotEmpty;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer name with avatar
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: Icon(
                    Icons.person,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasName ? customerData['name'].toString() : 'Unknown Customer',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (customerData['id'] != null)
                      Text(
                        'ID: ${customerData['id']}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            
            // Contact Information
            if (hasEmail)
              ListTile(
                leading: Icon(
                  Icons.email,
                  color: Colors.blue[700],
                ),
                title: Text(customerData['email'].toString()),
                subtitle: const Text('Email'),
                contentPadding: EdgeInsets.zero,
                dense: true,
                trailing: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: onEmail,
                  tooltip: 'Send Email',
                ),
              ),
              
            if (hasPhone) ...[
              const SizedBox(height: 8),
              ListTile(
                leading: Icon(
                  Icons.phone,
                  color: Colors.green[700],
                ),
                title: Text(customerData['phone'].toString()),
                subtitle: const Text('Phone'),
                contentPadding: EdgeInsets.zero,
                dense: true,
                trailing: IconButton(
                  icon: const Icon(Icons.call),
                  onPressed: onCall,
                  tooltip: 'Call Customer',
                ),
              ),
            ],
            
            if (hasAddress) ...[
              const SizedBox(height: 8),
              ListTile(
                leading: Icon(
                  Icons.home,
                  color: Colors.orange[700],
                ),
                title: Text(customerData['address'].toString()),
                subtitle: const Text('Address'),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ],
            
            // Show additional customer fields if available
            if (customerData.keys.length > 4) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Additional Information',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              
              ...customerData.entries
                  .where((entry) => 
                      !['name', 'id', 'email', 'phone', 'address'].contains(entry.key) && 
                      entry.value != null &&
                      entry.value.toString().isNotEmpty)
                  .map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 120,
                              child: Text(
                                _formatKey(entry.key),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                entry.value.toString(),
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ))
                  ,
            ],
          ],
        ),
      ),
    );
  }
  
  // Format key string for display
  String _formatKey(String key) {
    if (key.isEmpty) return '';
    
    // Convert snake_case or camelCase to Title Case with spaces
    String result = key.replaceAllMapped(
      RegExp(r'(?<=[a-z])[A-Z]'),
      (Match m) => ' ${m.group(0)}',
    );
    
    result = result.replaceAll('_', ' ');
    
    // Capitalize first letter of each word
    result = result.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
    
    return result;
  }
}