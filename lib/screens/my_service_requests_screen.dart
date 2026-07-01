import 'package:flutter/material.dart';
import 'package:goodlife_party/routes/app_routes.dart';

class MyServiceRequestsScreen extends StatelessWidget {
  const MyServiceRequestsScreen({super.key});

  /// Formats a date string from YYYY-MM-DD → DD-MM-YYYY.
  /// If already in DD-MM-YYYY format (or any other format), returns as-is.
  String _formatDate(String rawDate) {
    final parts = rawDate.split('-');
    if (parts.length == 3 && parts[0].length == 4) {
      // YYYY-MM-DD → DD-MM-YYYY
      return '${parts[2]}-${parts[1]}-${parts[0]}';
    }
    return rawDate;
  }

  @override
  Widget build(BuildContext context) {
    // Mock data for demonstration purposes
    final mockRequests = [
      {
        'id': 'SR-1029',
        'date': '24-06-2025',
        'status': 'Pending',
        'machines': ['Coffee Machine XP-200', 'Espresso Maker v2'],
        'happyCode': '4829',
      },
      {
        'id': 'SR-1028',
        'date': '15-06-2025',
        'status': 'Resolved',
        'machines': ['Ice Cream Dispenser Pro'],
        'happyCode': '1092',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Service Requests'),
        centerTitle: true,
      ),
      body: mockRequests.isEmpty
          ? const Center(child: Text('No service requests found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mockRequests.length,
              itemBuilder: (context, index) {
                final req = mockRequests[index];
                final isPending = req['status'] == 'Pending';
                final machines = req['machines'] as List<String>;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      'Request ID: ${req['id']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          machines.length == 1
                              ? 'Machine: ${machines.first}'
                              : 'Machines: ${machines.join(', ')}',
                        ),
                        const SizedBox(height: 4),
                        Text('Date: ${_formatDate(req['date'] as String)}'),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isPending
                                ? Colors.orange.shade100
                                : Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            req['status']! as String,
                            style: TextStyle(
                              color: isPending
                                  ? Colors.orange.shade800
                                  : Colors.green.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing:
                        const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.serviceRequestDetails,
                        arguments: req,
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
