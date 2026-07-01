import 'package:flutter/material.dart';
import 'package:goodlife_party/routes/app_routes.dart';

class MyServiceRequestsScreen extends StatelessWidget {
  const MyServiceRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for demonstration purposes
    final mockRequests = [
      {
        'id': 'SR-1029',
        'date': '2023-10-24',
        'status': 'Pending',
        'machine': 'Coffee Machine XP-200',
        'happyCode': '4829',
      },
      {
        'id': 'SR-1028',
        'date': '2023-10-15',
        'status': 'Resolved',
        'machine': 'Espresso Maker v2',
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
                        Text('Machine: ${req['machine']}'),
                        const SizedBox(height: 4),
                        Text('Date: ${req['date']}'),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isPending ? Colors.orange.shade100 : Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            req['status']!,
                            style: TextStyle(
                              color: isPending ? Colors.orange.shade800 : Colors.green.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
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
