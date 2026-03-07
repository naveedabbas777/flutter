import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/database_helper.dart';
import 'committee_dashboard_screen.dart';

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
          final pending = (total - received).clamp(0, double.infinity).toDouble();
          final membersCount = memberCountByCommittee[committeeId] ?? 0;

          totalBudget += total;
          totalReceived += received;
          totalMembers += membersCount;

          return {
            'id': committeeId,
            'client_name': clientNameById[_toInt(committee['client_id'])] ?? '-',
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
        'pending': (totalBudget - totalReceived).clamp(0, double.infinity).toDouble(),
        'members': totalMembers.toDouble(),
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
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body:
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
                          title: 'Total Members',
                          value: '${_totals['members']!.toInt()}',
                          icon: Icons.groups_3_outlined,
                        ),
                        _MetricCard(
                          title: 'Total Budget',
                          value: _currencyFormat.format(_totals['budget']),
                          icon: Icons.request_quote_outlined,
                        ),
                        _MetricCard(
                          title: 'Received',
                          value: _currencyFormat.format(_totals['received']),
                          icon: Icons.payments_outlined,
                        ),
                        _MetricCard(
                          title: 'Pending',
                          value: _currencyFormat.format(_totals['pending']),
                          icon: Icons.pending_actions_outlined,
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
                            const Text('Payment Progress (All Committees)'),
                            const SizedBox(height: 10),
                            LinearProgressIndicator(value: progress, minHeight: 10),
                            const SizedBox(height: 8),
                            Text(
                              '${(progress * 100).toStringAsFixed(1)}% received across all committees',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
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
                                                    await Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder:
                                                            (_) => CommitteeDashboardScreen(
                                                              committeeId: _toInt(row['id']),
                                                              committeeName:
                                                                  (row['name'] ?? '').toString(),
                                                            ),
                                                      ),
                                                    );
                                                    await _loadDashboard();
                                                  },
                                                  child: Text(
                                                    (row['name'] ?? '').toString(),
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(Text((row['client_name'] ?? '-').toString())),
                                              DataCell(Text('${_toInt(row['members_count'])}')),
                                              DataCell(
                                                Text(
                                                  _currencyFormat.format(_toDouble(row['total'])),
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
                                                  _currencyFormat.format(_toDouble(row['pending'])),
                                                ),
                                              ),
                                              DataCell(Text((row['status'] ?? '').toString())),
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
