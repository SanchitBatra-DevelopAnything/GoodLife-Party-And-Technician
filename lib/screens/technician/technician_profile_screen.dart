import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/service_request_model.dart';
import '../../providers/technician_auth_provider.dart';
import '../../providers/technician_service_request_provider.dart';
import '../../routes/app_routes.dart';
import '../../utils/service_request_status_helper.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/technician/technician_bottom_nav_bar.dart';
import '../../widgets/technician/technician_curved_app_bar.dart';

class TechnicianProfileScreen extends StatefulWidget {
  const TechnicianProfileScreen({super.key});

  @override
  State<TechnicianProfileScreen> createState() =>
      _TechnicianProfileScreenState();
}

class _TechnicianProfileScreenState extends State<TechnicianProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final techId = context.read<TechnicianAuthProvider>().technicianId;
    await context
        .read<TechnicianServiceRequestProvider>()
        .fetchAssignedRequests(techId);
  }

  Future<void> _logout() async {
    await context.read<TechnicianAuthProvider>().logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (r) => false);
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'VERIFIED':
      case 'CLOSED_BY_ADMIN':
        return Colors.green;
      case 'CLOSED':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<TechnicianAuthProvider>();
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const TechnicianCurvedAppBar(
        title: 'My Profile',
        subtitle: 'Technician details & history',
        showBack: false,
      ),
      body: Consumer<TechnicianServiceRequestProvider>(
        builder: (context, provider, _) {
          final history = provider.completedRequests;

          return RefreshIndicator(
            onRefresh: _loadData,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: primary.withOpacity(0.12),
                          backgroundImage: auth.photoUrl != null
                              ? NetworkImage(auth.photoUrl!)
                              : null,
                          child: auth.photoUrl == null
                              ? Icon(Icons.person_rounded,
                                  size: 44, color: primary)
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          auth.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.phone_rounded,
                                size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              auth.phone,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                        if (auth.technician?.area.isNotEmpty == true) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 16, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text(
                                auth.technician!.area,
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Completed Service Requests',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Reference history of tickets you have closed',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 12),
                if (provider.isFetching)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (history.isEmpty)
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'No completed requests yet.',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    ),
                  )
                else
                  ...history.map(
                    (req) => _HistoryCard(
                      request: req,
                      statusColor: _statusColor(req.status),
                    ),
                  ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'Logout',
                  onPressed: _logout,
                  isIOS: false,
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const TechnicianBottomNavBar(currentIndex: 2),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final ServiceRequestModel request;
  final Color statusColor;

  const _HistoryCard({
    required this.request,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    request.type == 'INSTALLATION' ? 'Installation' : 'Service',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    ServiceRequestStatusHelper.technicianListLabel(
                      request.status,
                    ),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              request.orderedBy,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              request.shortAddress,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Text(
              '${request.requestDate}  •  ${request.requestTime}',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
            ),
            if (request.paymentAmount != null) ...[
              const SizedBox(height: 6),
              Text(
                'Collected: ₹${request.paymentAmount!.toStringAsFixed(0)} (${request.paymentMode ?? '—'})',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
