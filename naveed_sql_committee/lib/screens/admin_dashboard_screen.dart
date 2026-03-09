import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/database_helper.dart';
import 'clients_screen.dart';
import 'committee_dashboard_screen.dart';
import 'committees_screen.dart';
import 'login_screen.dart';
import 'members_screen.dart';
import 'messages_screen.dart';
import 'reports_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: r'$');

  bool _isLoading = true;
  List<Map<String, Object?>> _committeeRows = [];
  Map<String, double> _totals = {
    'budget': 0,
    'received': 0,
    'pending': 0,
    'members': 0,
    'clients': 0,
    'payments': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  double _toDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  int _toInt(Object? value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
    });

    final committees = await _databaseHelper.getAllCommittees();
    final members = await _databaseHelper.getAllMembers();
    final clients = await _databaseHelper.getClients();
    final payments = await _databaseHelper.getAllPayments();

    _totals['clients'] = clients.length.toDouble();
    _totals['payments'] = payments.length.toDouble();

    final clientNameById = {
      for (final client in clients)
        _toInt(client['id']): (client['name'] ?? '').toString(),
    };

    final memberCountByCommittee = <int, int>{};
    for (final member in members) {
      final committeeId = _toInt(member['committee_id']);
      memberCountByCommittee[committeeId] =
          (memberCountByCommittee[committeeId] ?? 0) + 1;
    }

    final receivedByCommittee = <int, double>{};
    for (final payment in payments) {
      final committeeId = _toInt(payment['committee_id']);
      final amount = _toDouble(payment['amount']);
      receivedByCommittee[committeeId] =
          (receivedByCommittee[committeeId] ?? 0) + amount;
    }

    var totalBudget = 0.0;
    var totalReceived = 0.0;
    var totalMembers = 0;

    final rows =
        committees.map((committee) {
            final committeeId = _toInt(committee['id']);
            final total = _toDouble(committee['total_budget']);
            final received = receivedByCommittee[committeeId] ?? 0;
            final pending =
                (total - received).clamp(0, double.infinity).toDouble();
            final membersCount = memberCountByCommittee[committeeId] ?? 0;

            totalBudget += total;
            totalReceived += received;
            totalMembers += membersCount;

            return {
              'id': committeeId,
              'client_name':
                  clientNameById[_toInt(committee['client_id'])] ?? '-',
              'name': (committee['name'] ?? '').toString(),
              'status': (committee['status'] ?? '').toString(),
              'members_count': membersCount,
              'total': total,
              'received': received,
              'pending': pending,
            };
          }).toList()
          ..sort((a, b) => _toInt(b['id']).compareTo(_toInt(a['id'])));

    if (!mounted) {
      return;
    }

    setState(() {
      _committeeRows = rows;
      _totals = {
        'budget': totalBudget,
        'received': totalReceived,
        'pending':
            (totalBudget - totalReceived).clamp(0, double.infinity).toDouble(),
        'members': totalMembers.toDouble(),
        'clients': clients.length.toDouble(),
        'payments': payments.length.toDouble(),
      };
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        _totals['budget']! <= 0
            ? 0.0
            : (_totals['received']! / _totals['budget']!).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboard,
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1976D2),
                    Color(0xFF42A5F5),
                    Color(0xFF64B5F6),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.admin_panel_settings,
                      size: 30,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Committee Management',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Admin Panel', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard, color: Color(0xFF1976D2)),
              title: const Text('Dashboard'),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: const Icon(Icons.business, color: Color(0xFF4CAF50)),
              title: const Text('Manage Clients'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ClientsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_tree, color: Color(0xFFFF9800)),
              title: const Text('Manage Committees'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CommitteesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.mail, color: Color(0xFF1976D2)),
              title: const Text('Messages'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MessagesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart, color: Color(0xFF4CAF50)),
              title: const Text('Reports'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ReportsScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFFF44336)),
              title: const Text('Logout'),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE3F2FD), // Light blue
              Color(0xFFF3E5F5), // Light purple
              Color(0xFFFFF3E0), // Light orange
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                  onRefresh: _loadDashboard,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _MetricCard(
                          title: 'Committees',
                          value: '${_committeeRows.length}',
                          icon: Icons.account_tree_outlined,
                        ),
                        _MetricCard(
                          title: 'Members',
                          value: '${_totals['members']!.toInt()}',
                          icon: Icons.groups_3_outlined,
                        ),
                        _MetricCard(
                          title: 'Clients',
                          value: '${_totals['clients']!.toInt()}',
                          icon: Icons.business_outlined,
                        ),
                        _MetricCard(
                          title: 'Payments',
                          value: '${_totals['payments']!.toInt()}',
                          icon: Icons.payment_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _ActionCard(
                          title: 'Manage Committees',
                          icon: Icons.account_tree,
                          backgroundColor: const Color(
                            0xFFFF9800,
                          ), // Orange for manage
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CommitteesScreen(),
                              ),
                            );
                          },
                        ),
                        _ActionCard(
                          title: 'Manage Members',
                          icon: Icons.groups,
                          backgroundColor: const Color(
                            0xFF1976D2,
                          ), // Blue for manage
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const MembersScreen(),
                              ),
                            );
                          },
                        ),
                        _ActionCard(
                          title: 'Manage Clients',
                          icon: Icons.business,
                          backgroundColor: const Color(
                            0xFF4CAF50,
                          ), // Green for manage
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ClientsScreen(),
                              ),
                            );
                          },
                        ),
                        _ActionCard(
                          title: 'Messages',
                          icon: Icons.mail,
                          backgroundColor: const Color(
                            0xFF9C27B0,
                          ), // Purple for communication
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const MessagesScreen(),
                              ),
                            );
                          },
                        ),
                        _ActionCard(
                          title: 'Reports',
                          icon: Icons.bar_chart,
                          backgroundColor: const Color(
                            0xFF607D8B,
                          ), // Gray-blue for reports
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ReportsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Committee Financial Table'),
                            const SizedBox(height: 12),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Committee')),
                                  DataColumn(label: Text('Client')),
                                  DataColumn(label: Text('Members')),
                                  DataColumn(label: Text('Total')),
                                  DataColumn(label: Text('Received')),
                                  DataColumn(label: Text('Pending')),
                                  DataColumn(label: Text('Status')),
                                ],
                                rows:
                                    _committeeRows
                                        .map(
                                          (row) => DataRow(
                                            cells: [
                                              DataCell(
                                                InkWell(
                                                  onTap: () async {
                                                    await Navigator.of(
                                                      context,
                                                    ).push(
                                                      MaterialPageRoute(
                                                        builder:
                                                            (
                                                              _,
                                                            ) => CommitteeDashboardScreen(
                                                              committeeId:
                                                                  _toInt(
                                                                    row['id'],
                                                                  ),
                                                              committeeName:
                                                                  (row['name'] ??
                                                                          '')
                                                                      .toString(),
                                                            ),
                                                      ),
                                                    );
                                                    await _loadDashboard();
                                                  },
                                                  child: Text(
                                                    (row['name'] ?? '')
                                                        .toString(),
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  (row['client_name'] ?? '-')
                                                      .toString(),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  '${_toInt(row['members_count'])}',
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  _currencyFormat.format(
                                                    _toDouble(row['total']),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  _currencyFormat.format(
                                                    _toDouble(row['received']),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  _currencyFormat.format(
                                                    _toDouble(row['pending']),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  (row['status'] ?? '')
                                                      .toString(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                        .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(icon),
          ),
          title: Text(title),
          subtitle: Text(value, style: Theme.of(context).textTheme.titleMedium),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        color: backgroundColor ?? Theme.of(context).cardTheme.color,
        child: InkWell(
          onTap: onTap,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  backgroundColor?.withOpacity(0.2) ??
                  Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                icon,
                color: backgroundColor ?? Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(title),
          ),
        ),
      ),
    );
  }
}
