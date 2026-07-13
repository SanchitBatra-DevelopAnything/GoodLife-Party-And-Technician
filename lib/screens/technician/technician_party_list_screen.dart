import 'package:flutter/material.dart';
import '../../services/technician_document_service.dart';
import '../../routes/app_routes.dart';
import '../../widgets/technician/technician_bottom_nav_bar.dart';

class TechnicianPartyListScreen extends StatefulWidget {
  const TechnicianPartyListScreen({super.key});

  @override
  State<TechnicianPartyListScreen> createState() =>
      _TechnicianPartyListScreenState();
}

class _TechnicianPartyListScreenState extends State<TechnicianPartyListScreen> {
  final TechnicianDocumentService _documentService = TechnicianDocumentService();
  List<Map<String, dynamic>> _parties = [];
  List<Map<String, dynamic>> _filteredParties = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchParties();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchParties() async {
    setState(() => _isLoading = true);
    try {
      final parties = await _documentService.fetchParties();
      setState(() {
        _parties = parties;
        _filteredParties = parties;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load parties: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterParties(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredParties = _parties;
      });
    } else {
      final lowerQuery = query.toLowerCase();
      setState(() {
        _filteredParties = _parties.where((party) {
          final partyName =
              (party['distributorName'] ?? party['name'] ?? '').toLowerCase();
          return partyName.contains(lowerQuery);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Party'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_parties.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterParties,
                      decoration: InputDecoration(
                        hintText: 'Search Party...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 0),
                      ),
                    ),
                  ),
                Expanded(
                  child: _filteredParties.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _parties.isEmpty
                                    ? 'No parties found.'
                                    : 'No party matches your search.',
                                style: const TextStyle(fontSize: 16),
                              ),
                              if (_parties.isEmpty) ...[
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _fetchParties,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: _filteredParties.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final party = _filteredParties[index];
                            final partyName = party['distributorName'] ??
                                party['name'] ??
                                'Unknown Party';
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.1),
                                child: Icon(
                                  Icons.business,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              title: Text(
                                partyName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('ID: ${party['id']}'),
                              trailing: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 16),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.technicianUploadDocument,
                                  arguments: {
                                    'partyId': party['id'],
                                    'partyName': partyName,
                                  },
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
      bottomNavigationBar: const TechnicianBottomNavBar(currentIndex: 1),
    );
  }
}
