import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/service_request_model.dart';
import '../../providers/technician_auth_provider.dart';
import '../../providers/technician_service_request_provider.dart';
import '../../routes/app_routes.dart';
import '../../utils/service_request_status_helper.dart';
import '../../widgets/technician/technician_bottom_nav_bar.dart';
import '../../widgets/technician/technician_curved_app_bar.dart';

class TechnicianServiceRequestsScreen extends StatefulWidget {
  const TechnicianServiceRequestsScreen({super.key});

  @override
  State<TechnicianServiceRequestsScreen> createState() =>
      _TechnicianServiceRequestsScreenState();
}

class _TechnicianServiceRequestsScreenState
    extends State<TechnicianServiceRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRequests());
  }

  Future<void> _loadRequests() async {
    final techId = context.read<TechnicianAuthProvider>().technicianId;
    await context
        .read<TechnicianServiceRequestProvider>()
        .fetchAssignedRequests(techId);
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'VERIFIED':
      case 'CLOSED_BY_ADMIN':
        return Colors.green;
      case 'CLOSED':
        return Colors.purple;
      case 'IN_PROGRESS':
        return Colors.blue;
      case 'TECHNICIAN_ASSIGNED':
      case 'APPROVED':
        return Colors.teal;
      case 'PENDING':
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const TechnicianCurvedAppBar(
        title: 'My Service Requests',
        subtitle: 'Tickets assigned to you by admin',
        showBack: false,
      ),
      body: Consumer<TechnicianServiceRequestProvider>(
        builder: (context, provider, _) {
          if (provider.isFetching) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.fetchError != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline_rounded,
                        size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      provider.fetchError!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _loadRequests,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final active = provider.activeRequests;

          if (active.isEmpty) {
            return RefreshIndicator(
              onRefresh: _loadRequests,
              child: ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.assignment_turned_in_outlined,
                            size: 90, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const Text(
                          'No Active Requests',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Assigned service and installation tickets\nwill appear here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadRequests,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: active.length,
              itemBuilder: (context, index) {
                final req = active[index];
                return _TicketCard(
                  request: req,
                  statusColor: _statusColor(req.status),
                  onTap: () async {
                    await Navigator.pushNamed(
                      context,
                      AppRoutes.technicianServiceRequestDetail,
                      arguments: req,
                    );
                    if (context.mounted) _loadRequests();
                  },
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: const TechnicianBottomNavBar(currentIndex: 0),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final ServiceRequestModel request;
  final Color statusColor;
  final VoidCallback onTap;

  const _TicketCard({
    required this.request,
    required this.statusColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      request.type == 'INSTALLATION'
                          ? 'Installation'
                          : 'Service',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      ServiceRequestStatusHelper.technicianListLabel(
                        request.status,
                      ),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.store_rounded,
                      size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      request.orderedBy,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 15, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      request.shortAddress,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded,
                      size: 13, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    '${request.requestDate}  •  ${request.requestTime}',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 13, color: Colors.grey.shade400),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
