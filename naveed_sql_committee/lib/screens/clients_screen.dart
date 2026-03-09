import 'package:flutter/material.dart';

import '../data/database_helper.dart';
import 'admin_dashboard_screen.dart';
import 'client_committees_screen.dart';
import 'client_form_screen.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  Map<int, int> _committeeCountByClient = {};
  String _searchQuery = '';

  bool _isLoading = false;
  List<Map<String, Object?>> _clients = [];

  int _toInt(Object? value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    setState(() {
      _isLoading = true;
    });

    final clients = await _databaseHelper.getClients();

    final committees = await _databaseHelper.getAllCommittees();
    final committeeCountByClient = <int, int>{};
    for (final committee in committees) {
      final clientId = _toInt(committee['client_id']);
      committeeCountByClient[clientId] =
          (committeeCountByClient[clientId] ?? 0) + 1;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _clients = clients;
      _committeeCountByClient = committeeCountByClient;
      _isLoading = false;
    });
  }

  Future<void> _deleteClient(int id) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete client'),
          content: const Text(
            'This will remove the client and related committees/members.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await _databaseHelper.deleteClient(id);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Client deleted.')));
    await _loadClients();
  }

  Future<void> _openClientForm({Map<String, Object?>? client}) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ClientFormScreen(client: client)));

    await _loadClients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Directory'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF667EEA),
                Color(0xFF764BA2),
              ],
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                );
              },
              icon: const Icon(Icons.dashboard_outlined, color: Colors.white),
              label: const Text('Dashboard', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF4CAF50),
              Color(0xFF45A049),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4CAF50).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _openClientForm(),
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Add Client', style: TextStyle(color: Colors.white)),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8F9FA),
              Color(0xFFE3F2FD),
            ],
          ),
        ),
        child: _isLoading
            ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
              ),
            )
            : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Enhanced stats card
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF667EEA),
                          Color(0xFF764BA2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF667EEA).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Card(
                      color: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.business_center_outlined,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Total Clients',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Text(
                                    'Manage your client base and teams',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_clients.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Enhanced search field
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Search Clients',
                        hintText: 'Search by name, company, or phone',
                        prefixIcon: Container(
                          padding: const EdgeInsets.all(12),
                          child: const Icon(
                            Icons.search,
                            color: Color(0xFF667EEA),
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Enhanced data table card
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Card(
                        color: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: _clients.isEmpty
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF667EEA).withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.groups_2_outlined,
                                        size: 64,
                                        color: const Color(0xFF667EEA).withOpacity(0.5),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'No clients added yet.',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Tap the + button to add your first client',
                                      style: TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  headingRowColor: MaterialStateProperty.all(
                                    const Color(0xFF667EEA).withOpacity(0.1),
                                  ),
                                  dataRowColor: MaterialStateProperty.resolveWith(
                                    (states) {
                                      if (states.contains(MaterialState.selected)) {
                                        return const Color(0xFF667EEA).withOpacity(0.1);
                                      }
                                      return Colors.white;
                                    },
                                  ),
                                  columns: const [
                                    DataColumn(
                                      label: Text(
                                        'ID',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF667EEA),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Name',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF667EEA),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Company',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF667EEA),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Phone',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF667EEA),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Committees',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF667EEA),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Actions',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF667EEA),
                                        ),
                                      ),
                                    ),
                                  ],
                                  rows: _clients
                                      .where((client) {
                                        final name = (client['name'] ?? '').toString().toLowerCase();
                                        final company = (client['company'] ?? '').toString().toLowerCase();
                                        final phone = (client['phone'] ?? '').toString().toLowerCase();
                                        final query = _searchQuery.toLowerCase();
                                        return name.contains(query) ||
                                            company.contains(query) ||
                                            phone.contains(query);
                                      })
                                      .map((client) {
                                        final id = _toInt(client['id']);
                                        final name = (client['name'] ?? '').toString();
                                        final company = (client['company'] ?? '').toString();
                                        final phone = (client['phone'] ?? '').toString();
                                        final committeesCount = _committeeCountByClient[id] ?? 0;
                                        return DataRow(
                                          cells: [
                                            DataCell(Text('$id')),
                                            DataCell(Text(name)),
                                            DataCell(Text(company)),
                                            DataCell(Text(phone)),
                                            DataCell(
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: committeesCount > 0
                                                      ? const Color(0xFF4CAF50).withOpacity(0.1)
                                                      : Colors.grey.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  '$committeesCount',
                                                  style: TextStyle(
                                                    color: committeesCount > 0
                                                        ? const Color(0xFF4CAF50)
                                                        : Colors.grey,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Row(
                                                children: [
                                                  Container(
                                                    margin: const EdgeInsets.only(right: 8),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFFF9800).withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: IconButton(
                                                      icon: const Icon(
                                                        Icons.edit,
                                                        color: Color(0xFFFF9800),
                                                      ),
                                                      tooltip: 'Edit Client',
                                                      onPressed: () => _openClientForm(client: client),
                                                    ),
                                                  ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFF44336).withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: IconButton(
                                                      icon: const Icon(
                                                        Icons.delete_outline,
                                                        color: Color(0xFFF44336),
                                                      ),
                                                      tooltip: 'Delete Client',
                                                      onPressed: () => _deleteClient(id),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      })
                                      .toList(),
                                ),
                              ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}
