import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/database_helper.dart';
import 'admin_dashboard_screen.dart';
import 'committee_dashboard_screen.dart';
import 'committee_form_screen.dart';

class CommitteesScreen extends StatefulWidget {
  const CommitteesScreen({super.key});

  @override
  State<CommitteesScreen> createState() => _CommitteesScreenState();
}

class _CommitteesScreenState extends State<CommitteesScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: r'$');

  bool _isLoading = false;
  List<Map<String, Object?>> _committees = [];
  Map<int, String> _clientNames = {};
  String _searchQuery = '';
  String _statusFilter = 'all';
  String _paymentFilter = 'all'; // all, paid, pending

  int _toInt(Object? value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _toDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _loadCommittees();
  }

  Future<void> _loadCommittees() async {
    setState(() {
      _isLoading = true;
    });

    final committees = await _databaseHelper.getAllCommittees();
    final clients = await _databaseHelper.getClients();
    final members = await _databaseHelper.getAllMembers();
    final clientNames = <int, String>{};
    for (final client in clients) {
      final id = _toInt(client['id']);
      final name = (client['name'] ?? '').toString();
      clientNames[id] = name;
    }

    final memberCountByCommittee = <int, int>{};
    for (final member in members) {
      final committeeId = _toInt(member['committee_id']);
      memberCountByCommittee[committeeId] =
          (memberCountByCommittee[committeeId] ?? 0) + 1;
    }

    // Add members_count to committees
    final committeesWithCount =
        committees.map((committee) {
          final id = _toInt(committee['id']);
          return {
            ...committee,
            'members_count': memberCountByCommittee[id] ?? 0,
          };
        }).toList();

    if (!mounted) {
      return;
    }

    setState(() {
      _committees = committeesWithCount;
      _clientNames = clientNames;
      _isLoading = false;
    });
  }

  Future<void> _deleteCommittee(int id) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete committee'),
          content: const Text(
            'This will remove the committee and related members/payments.',
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

    await _databaseHelper.deleteCommittee(id);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Committee deleted.')));
    await _loadCommittees();
  }

  Future<void> _openCommitteeForm({Map<String, Object?>? committee}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CommitteeFormScreen(committee: committee),
      ),
    );
    await _loadCommittees();
  }

  Future<void> _openCommitteeDashboard(Map<String, Object?> committee) async {
    final id = _toInt(committee['id']);
    final name = (committee['name'] ?? '').toString();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) =>
                CommitteeDashboardScreen(committeeId: id, committeeName: name),
      ),
    );
    await _loadCommittees();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Committees Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCommittees,
            tooltip: 'Refresh',
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
              );
            },
            icon: const Icon(Icons.dashboard_outlined),
            label: const Text('Admin Dashboard'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCommitteeForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Committee'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8F5E8), // Light green
              Color(0xFFF3E5F5), // Light purple
              Color(0xFFFFF3E0), // Light orange
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            child: const Icon(Icons.groups_outlined),
                          ),
                          title: const Text('Total Committees'),
                          subtitle: const Text(
                            'Manage committees and their progress',
                          ),
                          trailing: Text(
                            '${_committees.length}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'Search',
                                prefixIcon: Icon(Icons.search),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          DropdownButton<String>(
                            value: _statusFilter,
                            items: const [
                              DropdownMenuItem(
                                value: 'all',
                                child: Text('All Status'),
                              ),
                              DropdownMenuItem(
                                value: 'active',
                                child: Text('Active'),
                              ),
                              DropdownMenuItem(
                                value: 'completed',
                                child: Text('Completed'),
                              ),
                              DropdownMenuItem(
                                value: 'inactive',
                                child: Text('Inactive'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _statusFilter = value!;
                              });
                            },
                          ),
                          const SizedBox(width: 12),
                          DropdownButton<String>(
                            value: _paymentFilter,
                            items: const [
                              DropdownMenuItem(
                                value: 'all',
                                child: Text('All Payments'),
                              ),
                              DropdownMenuItem(
                                value: 'paid',
                                child: Text('Paid'),
                              ),
                              DropdownMenuItem(
                                value: 'pending',
                                child: Text('Pending'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _paymentFilter = value!;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child:
                                _committees.isEmpty
                                    ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.groups_2_outlined,
                                            size: 52,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                          ),
                                          const SizedBox(height: 10),
                                          const Text(
                                            'No committees added yet.',
                                          ),
                                        ],
                                      ),
                                    )
                                    : SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        columns: const [
                                          DataColumn(label: Text('ID')),
                                          DataColumn(label: Text('Name')),
                                          DataColumn(label: Text('Client')),
                                          DataColumn(label: Text('Budget')),
                                          DataColumn(label: Text('Members')),
                                          DataColumn(label: Text('Actions')),
                                        ],
                                        rows:
                                            _committees
                                                .where((committee) {
                                                  final name =
                                                      (committee['name'] ?? '')
                                                          .toString()
                                                          .toLowerCase();
                                                  final clientId = _toInt(
                                                    committee['client_id'],
                                                  );
                                                  final clientName =
                                                      _clientNames[clientId]
                                                          ?.toLowerCase() ??
                                                      '';
                                                  final status =
                                                      (committee['status'] ??
                                                              '')
                                                          .toString()
                                                          .toLowerCase();
                                                  final query =
                                                      _searchQuery
                                                          .toLowerCase();
                                                  final matchesSearch =
                                                      name.contains(query) ||
                                                      clientName.contains(
                                                        query,
                                                      );
                                                  final matchesStatus =
                                                      _statusFilter == 'all' ||
                                                      status == _statusFilter;
                                                  return matchesSearch &&
                                                      matchesStatus;
                                                })
                                                .map((committee) {
                                                  final id = _toInt(
                                                    committee['id'],
                                                  );
                                                  final name =
                                                      (committee['name'] ?? '')
                                                          .toString();
                                                  final clientId = _toInt(
                                                    committee['client_id'],
                                                  );
                                                  final clientName =
                                                      _clientNames[clientId] ??
                                                      'Unknown';
                                                  final budget = _toDouble(
                                                    committee['budget'],
                                                  );
                                                  final membersCount = _toInt(
                                                    committee['members_count'],
                                                  );
                                                  return DataRow(
                                                    cells: [
                                                      DataCell(Text('$id')),
                                                      DataCell(Text(name)),
                                                      DataCell(
                                                        Text(clientName),
                                                      ),
                                                      DataCell(
                                                        Text(
                                                          _currencyFormat
                                                              .format(budget),
                                                        ),
                                                      ),
                                                      DataCell(
                                                        Text('$membersCount'),
                                                      ),
                                                      DataCell(
                                                        Row(
                                                          children: [
                                                            IconButton(
                                                              icon: const Icon(
                                                                Icons.dashboard,
                                                              ),
                                                              tooltip:
                                                                  'View Dashboard',
                                                              onPressed:
                                                                  () => _openCommitteeDashboard(
                                                                    committee,
                                                                  ),
                                                            ),
                                                            IconButton(
                                                              icon: const Icon(
                                                                Icons.edit,
                                                              ),
                                                              tooltip:
                                                                  'Edit Committee',
                                                              onPressed:
                                                                  () => _openCommitteeForm(
                                                                    committee:
                                                                        committee,
                                                                  ),
                                                            ),
                                                            IconButton(
                                                              icon: const Icon(
                                                                Icons
                                                                    .delete_outline,
                                                              ),
                                                              tooltip:
                                                                  'Delete Committee',
                                                              onPressed:
                                                                  () =>
                                                                      _deleteCommittee(
                                                                        id,
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
                    ],
                  ),
                ),
      ),
    );
  }
}
