import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/database_helper.dart';
import 'committee_members_screen.dart';
import 'member_form_screen.dart';

class CommitteeDashboardScreen extends StatefulWidget {
  const CommitteeDashboardScreen({
    super.key,
    required this.committeeId,
    required this.committeeName,
  });

  final int committeeId;
  final String committeeName;

  @override
  State<CommitteeDashboardScreen> createState() =>
      _CommitteeDashboardScreenState();
}

class _CommitteeDashboardScreenState extends State<CommitteeDashboardScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: r'$');

  bool _isLoading = true;
  List<Map<String, Object?>> _payments = [];
  List<Map<String, Object?>> _members = [];
  List<Map<String, Object?>> _draws = [];
  Map<String, double> _summary = {'total': 0, 'received': 0, 'pending': 0};

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);

    final members = await _databaseHelper.getMembersByCommittee(
      widget.committeeId,
    );
    final payments = await _databaseHelper.getPaymentsByCommittee(
      widget.committeeId,
    );
    final summary = await _databaseHelper.getCommitteePaymentSummary(
      widget.committeeId,
    );
    final draws = await _databaseHelper.getDrawsByCommittee(
      widget.committeeId,
    );

    if (!mounted) return;

    setState(() {
      _members = members;
      _payments = payments;
      _summary = summary;
      _draws = draws;
      _isLoading = false;
    });
  }

  Future<void> _deletePayment(int id) async {
    await _databaseHelper.deletePayment(id);
    await _loadDashboard();
  }

  String _getMemberName(int? memberId) {
    if (memberId == null) return '-';
    for (final m in _members) {
      if (m['id'] == memberId) return (m['name'] ?? '-').toString();
    }
    return '-';
  }

  double _memberTotalPaid(int memberId) {
    var total = 0.0;
    for (final p in _payments) {
      if (p['member_id'] == memberId) {
        total += _toDouble(p['amount']);
      }
    }
    return total;
  }

  Future<void> _openAddPaymentDialog({int? preselectedMemberId}) async {
    final amountController = TextEditingController();
    final dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    final methodController = TextEditingController();
    final noteController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    int? selectedMemberId = preselectedMemberId;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFF4CAF50).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add_card_rounded,
                        color: Color(0xFF4CAF50)),
                  ),
                  const SizedBox(width: 12),
                  const Text('Add Payment'),
                ],
              ),
              content: Form(
                key: formKey,
                child: SizedBox(
                  width: 440,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Member picker
                        DropdownButtonFormField<int?>(
                          value: selectedMemberId,
                          decoration: const InputDecoration(
                            labelText: 'Member',
                            prefixIcon: Icon(Icons.person_rounded),
                          ),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('-- No specific member --'),
                            ),
                            ..._members.map((m) {
                              final id = m['id'] as int;
                              final name =
                                  (m['name'] ?? '').toString();
                              return DropdownMenuItem<int?>(
                                value: id,
                                child: Text(name),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setDialogState(
                                () => selectedMemberId = value);
                          },
                          validator: (value) {
                            if (_members.isNotEmpty && value == null) {
                              return 'Please select a member';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: amountController,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Amount',
                            prefixIcon:
                                Icon(Icons.attach_money_rounded),
                          ),
                          validator: (value) {
                            final amount =
                                double.tryParse((value ?? '').trim());
                            if (amount == null || amount <= 0) {
                              return 'Enter valid amount';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: dateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Paid On',
                            prefixIcon:
                                const Icon(Icons.calendar_month_rounded),
                            suffixIcon: IconButton(
                              icon: const Icon(
                                  Icons.edit_calendar_rounded),
                              onPressed: () async {
                                final now = DateTime.now();
                                final pickedDate =
                                    await showDatePicker(
                                  context: dialogContext,
                                  initialDate: now,
                                  firstDate:
                                      DateTime(now.year - 10),
                                  lastDate:
                                      DateTime(now.year + 5),
                                );
                                if (pickedDate == null) return;
                                dateController.text =
                                    DateFormat('yyyy-MM-dd')
                                        .format(pickedDate);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: methodController,
                          decoration: const InputDecoration(
                            labelText: 'Method (Cash / Bank / etc)',
                            prefixIcon: Icon(Icons.payment_rounded),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: noteController,
                          decoration: const InputDecoration(
                            labelText: 'Note',
                            prefixIcon: Icon(Icons.note_rounded),
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(dialogContext).pop(null),
                  child: const Text('Cancel'),
                ),
                FilledButton.icon(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.of(dialogContext).pop({
                      'memberId': selectedMemberId,
                    });
                  },
                  icon: const Icon(Icons.save_rounded, size: 18),
                  label: const Text('Save Payment'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) return;

    await _databaseHelper.insertPayment(
      committeeId: widget.committeeId,
      amount: double.parse(amountController.text.trim()),
      paidOn: dateController.text.trim(),
      method: methodController.text.trim(),
      note: noteController.text.trim(),
      memberId: result['memberId'] as int?,
    );

    if (!mounted) return;
    await _loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final total = _summary['total'] ?? 0;
    final received = _summary['received'] ?? 0;
    final pending = _summary['pending'] ?? 0;
    final progress = total <= 0 ? 0.0 : (received / total).clamp(0.0, 1.0);

    final paidByMethod = <String, double>{};
    for (final payment in _payments) {
      final method = (payment['method'] ?? '').toString().trim();
      final key = method.isEmpty ? 'Other' : method;
      paidByMethod[key] =
          (paidByMethod[key] ?? 0) + _toDouble(payment['amount']);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.committeeName,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Committee Dashboard',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8))),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadDashboard,
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddPaymentDialog,
        backgroundColor: const Color(0xFF11998E),
        icon: const Icon(Icons.add_card_rounded),
        label: const Text('Add Payment'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Summary header
                  _buildSummaryHeader(total, received, pending, progress),
                  const SizedBox(height: 16),
                  // Progress card
                  _buildProgressCard(progress),
                  const SizedBox(height: 16),
                  // Members section
                  _buildMembersSection(context),
                  const SizedBox(height: 16),
                  // Lucky Draw section
                  _buildLuckyDrawSection(),
                  const SizedBox(height: 16),
                  // Payment breakdown
                  if (paidByMethod.isNotEmpty) ...[
                    _buildPaymentBreakdown(paidByMethod, received),
                    const SizedBox(height: 16),
                  ],
                  // Payment history
                  _buildPaymentHistory(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  // ─── Summary Header ──────────────────────────────────────────────

  Widget _buildSummaryHeader(
      double total, double received, double pending, double progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF11998E).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  label: 'Members',
                  value: '${_members.length}',
                  icon: Icons.groups_rounded,
                ),
              ),
              Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withValues(alpha: 0.3)),
              Expanded(
                child: _SummaryItem(
                  label: 'Budget',
                  value: _currencyFormat.format(total),
                  icon: Icons.account_balance_wallet_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  label: 'Received',
                  value: _currencyFormat.format(received),
                  icon: Icons.check_circle_rounded,
                ),
              ),
              Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withValues(alpha: 0.3)),
              Expanded(
                child: _SummaryItem(
                  label: 'Pending',
                  value: _currencyFormat.format(pending),
                  icon: Icons.pending_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Progress Card ───────────────────────────────────────────────

  Widget _buildProgressCard(double progress) {
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
                    color: const Color(0xFF11998E).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.trending_up_rounded,
                      color: Color(0xFF11998E), size: 20),
                ),
                const SizedBox(width: 10),
                const Text('Payment Progress',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: progress >= 1.0
                        ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                        : const Color(0xFFFF9800).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(progress * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: progress >= 1.0
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFFF9800),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 14,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 1.0
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFF11998E),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              progress >= 1.0
                  ? 'All payments collected!'
                  : '${(progress * 100).toStringAsFixed(1)}% of budget collected',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Members Section ─────────────────────────────────────────────

  Widget _buildMembersSection(BuildContext context) {
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667EEA).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.groups_rounded,
                      color: Color(0xFF667EEA), size: 20),
                ),
                const SizedBox(width: 10),
                Text('Members (${_members.length})',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton.icon(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CommitteeMembersScreen(
                          committeeId: widget.committeeId,
                          committeeName: widget.committeeName,
                        ),
                      ),
                    );
                    _loadDashboard();
                  },
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_members.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.person_add_alt_1_rounded,
                          size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 8),
                      Text('No members yet',
                          style: TextStyle(color: Colors.grey.shade500)),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MemberFormScreen(
                                  committeeId: widget.committeeId),
                            ),
                          );
                          _loadDashboard();
                        },
                        icon:
                            const Icon(Icons.person_add_rounded, size: 18),
                        label: const Text('Add First Member'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF667EEA),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...List.generate(
                _members.length > 5 ? 5 : _members.length,
                (index) {
                  final member = _members[index];
                  final name = (member['name'] ?? '').toString();
                  final role = (member['role'] ?? '').toString();
                  final phone = (member['phone'] ?? '').toString();
                  final email = (member['email'] ?? '').toString();

                  return Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: _memberHasWon(member['id'] as int)
                              ? const Color(0xFFFF6B35)
                                  .withValues(alpha: 0.15)
                              : const Color(0xFF667EEA)
                                  .withValues(alpha: 0.1),
                          child: _memberHasWon(member['id'] as int)
                              ? const Icon(Icons.emoji_events_rounded,
                                  color: Color(0xFFFF6B35), size: 20)
                              : Text(
                                  name.isNotEmpty
                                      ? name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                      color: Color(0xFF667EEA),
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _memberTotalPaid(
                                            member['id'] as int) >
                                        0
                                    ? const Color(0xFF4CAF50)
                                        .withValues(alpha: 0.1)
                                    : Colors.orange
                                        .withValues(alpha: 0.1),
                                borderRadius:
                                    BorderRadius.circular(10),
                              ),
                              child: Text(
                                _currencyFormat.format(
                                    _memberTotalPaid(
                                        member['id'] as int)),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _memberTotalPaid(
                                              member['id'] as int) >
                                          0
                                      ? const Color(0xFF4CAF50)
                                      : Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (role.isNotEmpty)
                              Text(role,
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12)),
                            Row(
                              children: [
                                if (phone.isNotEmpty) ...[
                                  Icon(Icons.phone_rounded,
                                      size: 12,
                                      color: Colors.grey.shade400),
                                  const SizedBox(width: 4),
                                  Text(phone,
                                      style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 11)),
                                ],
                                if (phone.isNotEmpty &&
                                    email.isNotEmpty)
                                  const SizedBox(width: 12),
                                if (email.isNotEmpty) ...[
                                  Icon(Icons.email_rounded,
                                      size: 12,
                                      color: Colors.grey.shade400),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(email,
                                        style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 11),
                                        overflow:
                                            TextOverflow.ellipsis),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.add_card_rounded,
                              color: Color(0xFF4CAF50), size: 20),
                          tooltip: 'Add payment for $name',
                          onPressed: () => _openAddPaymentDialog(
                              preselectedMemberId:
                                  member['id'] as int),
                        ),
                        isThreeLine: role.isNotEmpty,
                      ),
                      if (index <
                          (_members.length > 5
                              ? 4
                              : _members.length - 1))
                        Divider(
                            height: 1, color: Colors.grey.shade200),
                    ],
                  );
                },
              ),
            if (_members.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(
                  child: TextButton(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CommitteeMembersScreen(
                            committeeId: widget.committeeId,
                            committeeName: widget.committeeName,
                          ),
                        ),
                      );
                      _loadDashboard();
                    },
                    child: Text(
                        'View all ${_members.length} members →'),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            if (_members.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MemberFormScreen(
                            committeeId: widget.committeeId),
                      ),
                    );
                    _loadDashboard();
                  },
                  icon: const Icon(Icons.person_add_rounded, size: 18),
                  label: const Text('Add Member'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Lucky Draw Section ────────────────────────────────────────

  Future<void> _conductLuckyDraw() async {
    if (_members.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add members first before conducting a draw')),
      );
      return;
    }

    final received = _summary['received'] ?? 0;
    if (received <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No payments collected yet for this round')),
      );
      return;
    }

    final winner = await _databaseHelper.pickLuckyDrawWinner(
      widget.committeeId,
    );

    if (!mounted) return;

    if (winner == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All members have already won a draw!')),
      );
      return;
    }

    final winnerName = (winner['name'] ?? '').toString();
    final nextRound = _draws.isEmpty
        ? 1
        : (_draws.map((d) => d['round_number'] as int).reduce(
                (a, b) => a > b ? a : b) +
            1);

    // Show animated result dialog
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFFFD700)],
                  ),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B35)
                          .withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.emoji_events_rounded,
                    color: Colors.white, size: 44),
              ),
              const SizedBox(height: 20),
              Text('Round $nextRound Winner!',
                  style: const TextStyle(
                      fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 8),
              Text(
                winnerName,
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Receives ${_currencyFormat.format(received)}',
                  style: const TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pooled from ${_members.length} members',
                style: TextStyle(
                    color: Colors.grey.shade500, fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(true),
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Confirm Draw'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await _databaseHelper.insertDraw(
      committeeId: widget.committeeId,
      roundNumber: nextRound,
      winnerMemberId: winner['id'] as int,
      totalAmount: received,
    );

    if (!mounted) return;
    await _loadDashboard();
  }

  bool _memberHasWon(int memberId) {
    return _draws
        .any((d) => d['winner_member_id'] == memberId);
  }

  Widget _buildLuckyDrawSection() {
    final winnerIds =
        _draws.map((d) => d['winner_member_id'] as int).toSet();
    final eligibleCount =
        _members.where((m) => !winnerIds.contains(m['id'] as int)).length;
    final allDrawn = _members.isNotEmpty && eligibleCount == 0;

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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFFFF6B35).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.emoji_events_rounded,
                      color: Color(0xFFFF6B35), size: 20),
                ),
                const SizedBox(width: 10),
                const Text('Lucky Draw',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: allDrawn
                        ? const Color(0xFF4CAF50)
                            .withValues(alpha: 0.1)
                        : const Color(0xFFFF6B35)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    allDrawn
                        ? 'All drawn'
                        : '$eligibleCount / ${_members.length} eligible',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: allDrawn
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFFF6B35),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Member chips showing won / eligible
            if (_members.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _members.map((m) {
                  final name = (m['name'] ?? '').toString();
                  final hasWon = _memberHasWon(m['id'] as int);
                  return Chip(
                    avatar: Icon(
                      hasWon
                          ? Icons.emoji_events_rounded
                          : Icons.person_rounded,
                      size: 16,
                      color: hasWon
                          ? const Color(0xFFFF6B35)
                          : Colors.grey,
                    ),
                    label: Text(
                      name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            hasWon ? FontWeight.bold : FontWeight.normal,
                        decoration:
                            hasWon ? TextDecoration.lineThrough : null,
                        color: hasWon ? Colors.grey : Colors.black87,
                      ),
                    ),
                    backgroundColor: hasWon
                        ? const Color(0xFFFF6B35)
                            .withValues(alpha: 0.08)
                        : Colors.grey.shade100,
                    side: BorderSide.none,
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],
            // Conduct draw button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: allDrawn ? null : _conductLuckyDraw,
                icon: const Icon(Icons.casino_rounded, size: 20),
                label: Text(allDrawn
                    ? 'All Members Have Won'
                    : 'Conduct Lucky Draw'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            // Draw history
            if (_draws.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.history_rounded,
                      size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Text('Draw History',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600)),
                ],
              ),
              const SizedBox(height: 8),
              ..._draws.map((draw) {
                final round = draw['round_number'] as int;
                final winnerId = draw['winner_member_id'] as int;
                final winnerName = _getMemberName(winnerId);
                final amount = _toDouble(draw['total_amount']);
                final drawnAt = (draw['drawn_at'] ?? '').toString();
                final dateStr = drawnAt.length >= 10
                    ? drawnAt.substring(0, 10)
                    : drawnAt;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFFF6B35).withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFFF6B35)
                            .withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFF6B35),
                                Color(0xFFFFD700),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Center(
                            child: Text(
                              '#$round',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                winnerName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                              Text(
                                dateStr,
                                style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _currencyFormat.format(amount),
                            style: const TextStyle(
                              color: Color(0xFF4CAF50),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Payment Breakdown ───────────────────────────────────────────

  Widget _buildPaymentBreakdown(
      Map<String, double> paidByMethod, double received) {
    final methodColors = [
      const Color(0xFF667EEA),
      const Color(0xFF4CAF50),
      const Color(0xFFFF9800),
      const Color(0xFFF44336),
      const Color(0xFF9C27B0),
      const Color(0xFF00BCD4),
    ];

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
                    color: const Color(0xFF9C27B0).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.pie_chart_rounded,
                      color: Color(0xFF9C27B0), size: 20),
                ),
                const SizedBox(width: 10),
                const Text('Payment Breakdown',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ...paidByMethod.entries.toList().asMap().entries.map((entry) {
              final index = entry.key;
              final method = entry.value;
              final color = methodColors[index % methodColors.length];
              final ratio = received <= 0
                  ? 0.0
                  : (method.value / received).clamp(0.0, 1.0);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(method.key,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                        Text(
                          _currencyFormat.format(method.value),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: color),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 8,
                        backgroundColor: color.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ─── Payment History ─────────────────────────────────────────────

  Widget _buildPaymentHistory() {
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.receipt_long_rounded,
                      color: Color(0xFF4CAF50), size: 20),
                ),
                const SizedBox(width: 10),
                Text('Payment History (${_payments.length})',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            if (_payments.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_rounded,
                          size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 8),
                      Text('No payments recorded yet',
                          style: TextStyle(color: Colors.grey.shade500)),
                      const SizedBox(height: 4),
                      Text(
                          'Tap "Add Payment" to record the first payment',
                          style: TextStyle(
                              color: Colors.grey.shade400, fontSize: 12)),
                    ],
                  ),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    const Color(0xFF4CAF50).withValues(alpha: 0.05),
                  ),
                  headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(label: Text('Member')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Method')),
                    DataColumn(label: Text('Amount')),
                    DataColumn(label: Text('Note')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: _payments.map((payment) {
                    final memberId = payment['member_id'] as int?;
                    final memberName = _getMemberName(memberId);
                    return DataRow(
                      cells: [
                        DataCell(Text(
                          memberName,
                          style: TextStyle(
                            fontWeight: memberName != '-'
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: memberName != '-'
                                ? const Color(0xFF667EEA)
                                : Colors.grey,
                          ),
                        )),
                        DataCell(Text(
                            (payment['paid_on'] ?? '').toString())),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF667EEA)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              (payment['method'] ?? '-').toString(),
                              style: const TextStyle(
                                  color: Color(0xFF667EEA),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        DataCell(Text(
                          _currencyFormat
                              .format(_toDouble(payment['amount'])),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4CAF50)),
                        )),
                        DataCell(SizedBox(
                          width: 200,
                          child: Text(
                            (payment['note'] ?? '').toString(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )),
                        DataCell(IconButton(
                          icon: const Icon(Icons.delete_rounded,
                              color: Color(0xFFF44336), size: 20),
                          onPressed: () => _deletePayment(
                              (payment['id'] as num).toInt()),
                          tooltip: 'Delete payment',
                        )),
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
}

// ─── Summary Item ────────────────────────────────────────────────

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 24),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            textAlign: TextAlign.center),
        Text(label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            )),
      ],
    );
  }
}
