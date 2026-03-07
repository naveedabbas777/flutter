import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/database_helper.dart';
import 'committee_members_screen.dart';

class CommitteeDashboardScreen extends StatefulWidget {
  const CommitteeDashboardScreen({
    super.key,
    required this.committeeId,
    required this.committeeName,
  });

  final int committeeId;
  final String committeeName;

  @override
  State<CommitteeDashboardScreen> createState() => _CommitteeDashboardScreenState();
}

class _CommitteeDashboardScreenState extends State<CommitteeDashboardScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: r'$');

  bool _isLoading = true;
  List<Map<String, Object?>> _payments = [];
  int _memberCount = 0;
  Map<String, double> _summary = {'total': 0, 'received': 0, 'pending': 0};

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

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
    });

    final members = await _databaseHelper.getMembersByCommittee(widget.committeeId);
    final payments = await _databaseHelper.getPaymentsByCommittee(widget.committeeId);
    final summary = await _databaseHelper.getCommitteePaymentSummary(widget.committeeId);

    if (!mounted) {
      return;
    }

    setState(() {
      _memberCount = members.length;
      _payments = payments;
      _summary = summary;
      _isLoading = false;
    });
  }

  Future<void> _deletePayment(int id) async {
    await _databaseHelper.deletePayment(id);
    await _loadDashboard();
  }

  Future<void> _openAddPaymentDialog() async {
    final amountController = TextEditingController();
    final dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    final methodController = TextEditingController();
    final noteController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Payment'),
          content: Form(
            key: formKey,
            child: SizedBox(
              width: 440,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Amount'),
                    validator: (value) {
                      final amount = double.tryParse((value ?? '').trim());
                      if (amount == null || amount <= 0) {
                        return 'Enter valid amount';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Paid On',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_month),
                        onPressed: () async {
                          final now = DateTime.now();
                          final pickedDate = await showDatePicker(
                            context: dialogContext,
                            initialDate: now,
                            firstDate: DateTime(now.year - 10),
                            lastDate: DateTime(now.year + 5),
                          );
                          if (pickedDate == null) {
                            return;
                          }
                          dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: methodController,
                    decoration: const InputDecoration(labelText: 'Method (Cash/Bank/etc)'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: noteController,
                    decoration: const InputDecoration(labelText: 'Note'),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) {
                  return;
                }
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (shouldSave != true) {
      return;
    }

    await _databaseHelper.insertPayment(
      committeeId: widget.committeeId,
      amount: double.parse(amountController.text.trim()),
      paidOn: dateController.text.trim(),
      method: methodController.text.trim(),
      note: noteController.text.trim(),
    );

    if (!mounted) {
      return;
    }

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
      paidByMethod[key] = (paidByMethod[key] ?? 0) + _toDouble(payment['amount']);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.committeeName} Dashboard'),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (_) => CommitteeMembersScreen(
                        committeeId: widget.committeeId,
                        committeeName: widget.committeeName,
                      ),
                ),
              );
              await _loadDashboard();
            },
            icon: const Icon(Icons.groups_3_outlined),
            label: const Text('Members'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddPaymentDialog,
        icon: const Icon(Icons.add_card_outlined),
        label: const Text('Add Payment'),
      ),
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
                        _InfoCard(
                          title: 'Total Members',
                          value: '$_memberCount',
                          icon: Icons.people_outline,
                        ),
                        _InfoCard(
                          title: 'Total Amount',
                          value: _currencyFormat.format(total),
                          icon: Icons.account_balance_wallet_outlined,
                        ),
                        _InfoCard(
                          title: 'Received',
                          value: _currencyFormat.format(received),
                          icon: Icons.payments_outlined,
                        ),
                        _InfoCard(
                          title: 'Pending',
                          value: _currencyFormat.format(pending),
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
                            const Text('Payment Progress'),
                            const SizedBox(height: 10),
                            LinearProgressIndicator(value: progress, minHeight: 10),
                            const SizedBox(height: 8),
                            Text(
                              '${(progress * 100).toStringAsFixed(1)}% received',
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
                            const Text('Graphical Breakdown (by Method)'),
                            const SizedBox(height: 10),
                            if (paidByMethod.isEmpty)
                              const Text('No payment records yet.')
                            else
                              ...paidByMethod.entries.map(
                                (entry) {
                                  final ratio = received <= 0
                                      ? 0.0
                                      : (entry.value / received).clamp(0.0, 1.0);
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${entry.key} • ${_currencyFormat.format(entry.value)}',
                                        ),
                                        const SizedBox(height: 4),
                                        LinearProgressIndicator(value: ratio),
                                      ],
                                    ),
                                  );
                                },
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
                            const Text('Payment Table'),
                            const SizedBox(height: 12),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Date')),
                                  DataColumn(label: Text('Method')),
                                  DataColumn(label: Text('Amount')),
                                  DataColumn(label: Text('Note')),
                                  DataColumn(label: Text('Action')),
                                ],
                                rows:
                                    _payments
                                        .map(
                                          (payment) => DataRow(
                                            cells: [
                                              DataCell(
                                                Text((payment['paid_on'] ?? '').toString()),
                                              ),
                                              DataCell(
                                                Text((payment['method'] ?? '-').toString()),
                                              ),
                                              DataCell(
                                                Text(
                                                  _currencyFormat.format(
                                                    _toDouble(payment['amount']),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: 220,
                                                  child: Text(
                                                    (payment['note'] ?? '').toString(),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                IconButton(
                                                  icon: const Icon(Icons.delete_outline),
                                                  onPressed: () => _deletePayment(
                                                    (payment['id'] as num).toInt(),
                                                  ),
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
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
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
