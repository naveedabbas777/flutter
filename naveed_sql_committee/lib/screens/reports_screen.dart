import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/database_helper.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: r'$');

  bool _isLoading = true;
  Map<String, dynamic> _reportData = {};

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
    });

    final committees = await _databaseHelper.getAllCommittees();
    final clients = await _databaseHelper.getClients();
    final members = await _databaseHelper.getAllMembers();
    final payments = await _databaseHelper.getAllPayments();

    final totalCommittees = committees.length;
    final totalClients = clients.length;
    final totalMembers = members.length;
    final totalPayments = payments.length;

    final totalBudget = committees.fold<double>(
      0,
      (sum, committee) => sum + (committee['total_budget'] as double? ?? 0),
    );

    final totalReceived = payments.fold<double>(
      0,
      (sum, payment) => sum + (payment['amount'] as double? ?? 0),
    );

    final activeCommittees =
        committees.where((c) => c['status'] == 'active').length;
    final completedCommittees =
        committees.where((c) => c['status'] == 'completed').length;

    if (!mounted) {
      return;
    }

    setState(() {
      _reportData = {
        'totalCommittees': totalCommittees,
        'totalClients': totalClients,
        'totalMembers': totalMembers,
        'totalPayments': totalPayments,
        'totalBudget': totalBudget,
        'totalReceived': totalReceived,
        'activeCommittees': activeCommittees,
        'completedCommittees': completedCommittees,
      };
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Reports')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF3E0), // Light orange
              Color(0xFFF3E5F5), // Light purple
              Color(0xFFE3F2FD), // Light blue
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                  onRefresh: _loadReports,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text(
                        'System Overview',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _ReportCard(
                            title: 'Total Committees',
                            value: '${_reportData['totalCommittees']}',
                            icon: Icons.account_tree_outlined,
                          ),
                          _ReportCard(
                            title: 'Active Committees',
                            value: '${_reportData['activeCommittees']}',
                            icon: Icons.play_arrow,
                          ),
                          _ReportCard(
                            title: 'Completed Committees',
                            value: '${_reportData['completedCommittees']}',
                            icon: Icons.check_circle_outline,
                          ),
                          _ReportCard(
                            title: 'Total Clients',
                            value: '${_reportData['totalClients']}',
                            icon: Icons.business_outlined,
                          ),
                          _ReportCard(
                            title: 'Total Members',
                            value: '${_reportData['totalMembers']}',
                            icon: Icons.groups_3_outlined,
                          ),
                          _ReportCard(
                            title: 'Total Payments',
                            value: '${_reportData['totalPayments']}',
                            icon: Icons.payment_outlined,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Financial Summary',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total Budget'),
                                  Text(
                                    _currencyFormat.format(
                                      _reportData['totalBudget'],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total Received'),
                                  Text(
                                    _currencyFormat.format(
                                      _reportData['totalReceived'],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Pending Amount'),
                                  Text(
                                    _currencyFormat.format(
                                      (_reportData['totalBudget'] as double) -
                                          (_reportData['totalReceived']
                                              as double),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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

class _ReportCard extends StatelessWidget {
  const _ReportCard({
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
      width: 180,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
      ),
    );
  }
}
