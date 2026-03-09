import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/database_helper.dart';
import 'client_form_screen.dart';
import 'clients_screen.dart';
import 'committee_dashboard_screen.dart';
import 'committee_form_screen.dart';
import 'committees_screen.dart';
import 'login_screen.dart';
import 'member_form_screen.dart';
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
  List<Map<String, Object?>> _recentMembers = [];
  List<Map<String, Object?>> _recentPayments = [];
  Map<String, double> _totals = {
    'budget': 0,
    'received': 0,
    'pending': 0,
    'members': 0,
    'clients': 0,
    'payments': 0,
    'activeCommittees': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  int _toInt(Object? value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);

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
    var activeCommittees = 0;

    final rows = committees.map((committee) {
      final committeeId = _toInt(committee['id']);
      final total = _toDouble(committee['total_budget']);
      final received = receivedByCommittee[committeeId] ?? 0;
      final pending = (total - received).clamp(0, double.infinity).toDouble();
      final membersCount = memberCountByCommittee[committeeId] ?? 0;
      final status = (committee['status'] ?? '').toString();

      totalBudget += total;
      totalReceived += received;
      totalMembers += membersCount;
      if (status.toLowerCase() == 'active') activeCommittees++;

      return {
        'id': committeeId,
        'client_name': clientNameById[_toInt(committee['client_id'])] ?? '-',
        'name': (committee['name'] ?? '').toString(),
        'status': status,
        'members_count': membersCount,
        'total': total,
        'received': received,
        'pending': pending,
      };
    }).toList()
      ..sort((a, b) => _toInt(b['id']).compareTo(_toInt(a['id'])));

    final committeeNameById = {
      for (final c in committees)
        _toInt(c['id']): (c['name'] ?? '').toString(),
    };

    // Recent members (last 5)
    final sortedMembers = List<Map<String, Object?>>.from(members)
      ..sort((a, b) => _toInt(b['id']).compareTo(_toInt(a['id'])));
    final recentMembers = sortedMembers.take(5).map((m) {
      return {
        ...m,
        'committee_name':
            committeeNameById[_toInt(m['committee_id'])] ?? 'Unknown',
      };
    }).toList();

    // Recent payments (last 5)
    final sortedPayments = List<Map<String, Object?>>.from(payments)
      ..sort((a, b) => _toInt(b['id']).compareTo(_toInt(a['id'])));
    final recentPayments = sortedPayments.take(5).map((p) {
      return {
        ...p,
        'committee_name':
            committeeNameById[_toInt(p['committee_id'])] ?? 'Unknown',
      };
    }).toList();

    if (!mounted) return;

    setState(() {
      _committeeRows = rows;
      _recentMembers = recentMembers;
      _recentPayments = recentPayments;
      _totals = {
        'budget': totalBudget,
        'received': totalReceived,
        'pending':
            (totalBudget - totalReceived).clamp(0, double.infinity).toDouble(),
        'members': totalMembers.toDouble(),
        'clients': clients.length.toDouble(),
        'payments': payments.length.toDouble(),
        'activeCommittees': activeCommittees.toDouble(),
      };
      _isLoading = false;
    });
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF4CAF50);
      case 'completed':
        return const Color(0xFF1976D2);
      case 'on hold':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF757575);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totals['budget']! <= 0
        ? 0.0
        : (_totals['received']! / _totals['budget']!).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            ),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dashboard',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Committee Management System',
                style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadDashboard,
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMenu(context),
        backgroundColor: const Color(0xFF667EEA),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add New'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildWelcomeCard(),
                  const SizedBox(height: 16),
                  _buildStatsGrid(),
                  const SizedBox(height: 16),
                  _buildFinancialSummary(progress),
                  const SizedBox(height: 16),
                  _buildSectionHeader(
                      'Quick Actions', Icons.flash_on_rounded),
                  const SizedBox(height: 8),
                  _buildQuickActions(context),
                  const SizedBox(height: 16),
                  if (_recentMembers.isNotEmpty) ...[
                    _buildSectionHeader(
                        'Recent Members', Icons.person_add_alt_1_rounded),
                    const SizedBox(height: 8),
                    _buildRecentMembersList(),
                    const SizedBox(height: 16),
                  ],
                  if (_recentPayments.isNotEmpty) ...[
                    _buildSectionHeader(
                        'Recent Payments', Icons.payment_rounded),
                    const SizedBox(height: 8),
                    _buildRecentPaymentsList(),
                    const SizedBox(height: 16),
                  ],
                  _buildSectionHeader(
                      'All Committees', Icons.account_tree_rounded),
                  const SizedBox(height: 8),
                  _buildCommitteeTable(context),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  // ─── Welcome Card ────────────────────────────────────────────────

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Welcome, Admin!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 6),
                Text(
                  'You have ${_committeeRows.length} committees with ${_totals['members']!.toInt()} members.',
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_totals['activeCommittees']!.toInt()} active  •  ${_totals['payments']!.toInt()} payments recorded',
                  style:
                      const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.dashboard_rounded,
                color: Colors.white, size: 40),
          ),
        ],
      ),
    );
  }

  // ─── Stats Grid ──────────────────────────────────────────────────

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _StatCard(
          title: 'Total Committees',
          value: '${_committeeRows.length}',
          icon: Icons.account_tree_rounded,
          gradient: const [Color(0xFF667EEA), Color(0xFF764BA2)],
          subtitle: '${_totals['activeCommittees']!.toInt()} active',
        ),
        _StatCard(
          title: 'Total Members',
          value: '${_totals['members']!.toInt()}',
          icon: Icons.groups_rounded,
          gradient: const [Color(0xFF11998E), Color(0xFF38EF7D)],
          subtitle: 'Across all committees',
        ),
        _StatCard(
          title: 'Total Clients',
          value: '${_totals['clients']!.toInt()}',
          icon: Icons.business_rounded,
          gradient: const [Color(0xFFFC5C7D), Color(0xFF6A82FB)],
          subtitle: 'Registered clients',
        ),
        _StatCard(
          title: 'Total Payments',
          value: '${_totals['payments']!.toInt()}',
          icon: Icons.payment_rounded,
          gradient: const [Color(0xFFF857A6), Color(0xFFFF5858)],
          subtitle: _currencyFormat.format(_totals['received']),
        ),
      ],
    );
  }

  // ─── Financial Summary ───────────────────────────────────────────

  Widget _buildFinancialSummary(double progress) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667EEA).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded,
                      color: Color(0xFF667EEA), size: 24),
                ),
                const SizedBox(width: 12),
                const Text('Financial Overview',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _FinancialItem(
                    label: 'Total Budget',
                    amount: _currencyFormat.format(_totals['budget']),
                    color: const Color(0xFF667EEA),
                    icon: Icons.account_balance_rounded,
                  ),
                ),
                Expanded(
                  child: _FinancialItem(
                    label: 'Received',
                    amount: _currencyFormat.format(_totals['received']),
                    color: const Color(0xFF4CAF50),
                    icon: Icons.check_circle_rounded,
                  ),
                ),
                Expanded(
                  child: _FinancialItem(
                    label: 'Pending',
                    amount: _currencyFormat.format(_totals['pending']),
                    color: const Color(0xFFFF9800),
                    icon: Icons.pending_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: Colors.grey.shade200,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toStringAsFixed(1)}% of total budget collected',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Section Header ──────────────────────────────────────────────

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF667EEA)),
        const SizedBox(width: 8),
        Text(title,
            style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ─── Quick Actions ───────────────────────────────────────────────

  Widget _buildQuickActions(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _QuickActionChip(
            label: 'Add Committee',
            icon: Icons.add_circle_outline_rounded,
            color: const Color(0xFF667EEA),
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const CommitteeFormScreen()),
              );
              _loadDashboard();
            },
          ),
          _QuickActionChip(
            label: 'Add Client',
            icon: Icons.person_add_alt_rounded,
            color: const Color(0xFF4CAF50),
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const ClientFormScreen()),
              );
              _loadDashboard();
            },
          ),
          _QuickActionChip(
            label: 'View Reports',
            icon: Icons.bar_chart_rounded,
            color: const Color(0xFFFF9800),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ReportsScreen()),
            ),
          ),
          _QuickActionChip(
            label: 'Messages',
            icon: Icons.mail_rounded,
            color: const Color(0xFF9C27B0),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MessagesScreen()),
            ),
          ),
          _QuickActionChip(
            label: 'All Members',
            icon: Icons.groups_rounded,
            color: const Color(0xFF00BCD4),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MembersScreen()),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Recent Members ──────────────────────────────────────────────

  Widget _buildRecentMembersList() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          for (var i = 0; i < _recentMembers.length; i++) ...[
            ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    const Color(0xFF11998E).withValues(alpha: 0.1),
                child: Text(
                  (_recentMembers[i]['name'] ?? 'U')
                      .toString()
                      .substring(0, 1)
                      .toUpperCase(),
                  style: const TextStyle(
                      color: Color(0xFF11998E),
                      fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                  (_recentMembers[i]['name'] ?? '').toString(),
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                '${(_recentMembers[i]['role'] ?? '').toString()} • ${(_recentMembers[i]['committee_name'] ?? '').toString()}',
                style:
                    TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              trailing: Text(
                (_recentMembers[i]['phone'] ?? '').toString(),
                style:
                    TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ),
            if (i < _recentMembers.length - 1)
              Divider(
                  height: 1, indent: 72, color: Colors.grey.shade200),
          ],
        ],
      ),
    );
  }

  // ─── Recent Payments ─────────────────────────────────────────────

  Widget _buildRecentPaymentsList() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          for (var i = 0; i < _recentPayments.length; i++) ...[
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.payments_rounded,
                    color: Color(0xFF4CAF50), size: 22),
              ),
              title: Text(
                _currencyFormat
                    .format(_toDouble(_recentPayments[i]['amount'])),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${(_recentPayments[i]['committee_name'] ?? '').toString()} • ${(_recentPayments[i]['method'] ?? '').toString()}',
                style:
                    TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              trailing: Text(
                (_recentPayments[i]['paid_on'] ?? '').toString(),
                style:
                    TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ),
            if (i < _recentPayments.length - 1)
              Divider(
                  height: 1, indent: 72, color: Colors.grey.shade200),
          ],
        ],
      ),
    );
  }

  // ─── Committee Table ─────────────────────────────────────────────

  Widget _buildCommitteeTable(BuildContext context) {
    if (_committeeRows.isEmpty) {
      return Card(
        elevation: 2,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.account_tree_rounded,
                  size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text('No committees yet',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              Text(
                'Tap the + button to create your first committee',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.table_chart_rounded,
                    color: Color(0xFF667EEA), size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Committee Financial Summary',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                Text('${_committeeRows.length} total',
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  const Color(0xFF667EEA).withValues(alpha: 0.05),
                ),
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
                dataRowMaxHeight: 56,
                columnSpacing: 24,
                columns: const [
                  DataColumn(label: Text('Committee')),
                  DataColumn(label: Text('Client')),
                  DataColumn(label: Text('Members')),
                  DataColumn(label: Text('Budget')),
                  DataColumn(label: Text('Received')),
                  DataColumn(label: Text('Pending')),
                  DataColumn(label: Text('Status')),
                ],
                rows: _committeeRows.map((row) {
                  final status = (row['status'] ?? '').toString();
                  final receivedPct = _toDouble(row['total']) <= 0
                      ? 0.0
                      : (_toDouble(row['received']) /
                              _toDouble(row['total']))
                          .clamp(0.0, 1.0);
                  return DataRow(
                    cells: [
                      DataCell(
                        InkWell(
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CommitteeDashboardScreen(
                                  committeeId: _toInt(row['id']),
                                  committeeName:
                                      (row['name'] ?? '').toString(),
                                ),
                              ),
                            );
                            _loadDashboard();
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.open_in_new_rounded,
                                  size: 14, color: Color(0xFF667EEA)),
                              const SizedBox(width: 6),
                              Text(
                                (row['name'] ?? '').toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF667EEA),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      DataCell(Text(
                          (row['client_name'] ?? '-').toString())),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.people_rounded,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('${_toInt(row['members_count'])}'),
                          ],
                        ),
                      ),
                      DataCell(Text(_currencyFormat
                          .format(_toDouble(row['total'])))),
                      DataCell(
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_currencyFormat
                                .format(_toDouble(row['received']))),
                            SizedBox(
                              width: 60,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: receivedPct,
                                  minHeight: 4,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          Color(0xFF4CAF50)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(Text(
                        _currencyFormat
                            .format(_toDouble(row['pending'])),
                        style: TextStyle(
                          color: _toDouble(row['pending']) > 0
                              ? const Color(0xFFFF9800)
                              : const Color(0xFF4CAF50),
                          fontWeight: FontWeight.w500,
                        ),
                      )),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusColor(status)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: _statusColor(status),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Add Menu Bottom Sheet ───────────────────────────────────────

  void _showAddMenu(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Create New',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE8EAF6),
                    child: Icon(Icons.account_tree_rounded,
                        color: Color(0xFF667EEA)),
                  ),
                  title: const Text('New Committee'),
                  subtitle: const Text(
                      'Create a committee to track payments'),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await Navigator.of(ctx).push(
                      MaterialPageRoute(
                          builder: (_) => const CommitteeFormScreen()),
                    );
                    _loadDashboard();
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE8F5E9),
                    child: Icon(Icons.business_rounded,
                        color: Color(0xFF4CAF50)),
                  ),
                  title: const Text('New Client'),
                  subtitle: const Text('Register a new client'),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await Navigator.of(ctx).push(
                      MaterialPageRoute(
                          builder: (_) => const ClientFormScreen()),
                    );
                    _loadDashboard();
                  },
                ),
                if (_committeeRows.isNotEmpty)
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFFF3E0),
                      child: Icon(Icons.person_add_alt_1_rounded,
                          color: Color(0xFFFF9800)),
                    ),
                    title: const Text('New Member'),
                    subtitle: const Text(
                        'Add a member to an existing committee'),
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      await _showCommitteePickerForMember(ctx);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showCommitteePickerForMember(BuildContext ctx) async {
    final selectedId = await showDialog<int>(
      context: ctx,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Select Committee'),
          content: SizedBox(
            width: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _committeeRows.length,
              itemBuilder: (_, index) {
                final row = _committeeRows[index];
                return ListTile(
                  title: Text((row['name'] ?? '').toString()),
                  subtitle: Text(
                      '${_toInt(row['members_count'])} members • ${(row['status'] ?? '').toString()}'),
                  onTap: () =>
                      Navigator.of(dialogCtx).pop(_toInt(row['id'])),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
    if (selectedId == null || !mounted) return;
    await Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (_) => MemberFormScreen(committeeId: selectedId),
      ),
    );
    _loadDashboard();
  }

  // ─── Drawer ──────────────────────────────────────────────────────

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.admin_panel_settings_rounded,
                      size: 36, color: Colors.white),
                ),
                const SizedBox(height: 16),
                const Text('Committee Management',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Admin Panel',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _DrawerItem(
            icon: Icons.dashboard_rounded,
            label: 'Dashboard',
            color: const Color(0xFF667EEA),
            isSelected: true,
            onTap: () => Navigator.of(context).pop(),
          ),
          _DrawerItem(
            icon: Icons.business_rounded,
            label: 'Manage Clients',
            color: const Color(0xFF4CAF50),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const ClientsScreen()),
              );
            },
          ),
          _DrawerItem(
            icon: Icons.account_tree_rounded,
            label: 'Manage Committees',
            color: const Color(0xFFFF9800),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const CommitteesScreen()),
              );
            },
          ),
          _DrawerItem(
            icon: Icons.groups_rounded,
            label: 'Manage Members',
            color: const Color(0xFF00BCD4),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const MembersScreen()),
              );
            },
          ),
          Divider(color: Colors.grey.shade200),
          _DrawerItem(
            icon: Icons.mail_rounded,
            label: 'Messages',
            color: const Color(0xFF9C27B0),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const MessagesScreen()),
              );
            },
          ),
          _DrawerItem(
            icon: Icons.bar_chart_rounded,
            label: 'Reports',
            color: const Color(0xFF607D8B),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const ReportsScreen()),
              );
            },
          ),
          Divider(color: Colors.grey.shade200),
          _DrawerItem(
            icon: Icons.logout_rounded,
            label: 'Logout',
            color: const Color(0xFFF44336),
            onTap: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stat Card ───────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    this.subtitle,
  });

  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradient;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(title,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
            ],
          ),
          Text(value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              )),
          if (subtitle != null)
            Text(subtitle!,
                style: TextStyle(
                    color: Colors.grey.shade500, fontSize: 11),
                overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ─── Financial Item ──────────────────────────────────────────────

class _FinancialItem extends StatelessWidget {
  const _FinancialItem({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  final String label;
  final String amount;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14,
            ),
            textAlign: TextAlign.center),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                color: Colors.grey.shade600, fontSize: 11),
            textAlign: TextAlign.center),
      ],
    );
  }
}

// ─── Quick Action Chip ───────────────────────────────────────────

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 100,
          padding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Drawer Item ─────────────────────────────────────────────────

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isSelected = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label,
            style: TextStyle(
              fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? color : null,
            )),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        selectedTileColor: color.withValues(alpha: 0.1),
        selected: isSelected,
        onTap: onTap,
      ),
    );
  }
}
