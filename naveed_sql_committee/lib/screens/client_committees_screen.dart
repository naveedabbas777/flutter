import 'package:flutter/material.dart';

import '../core/app_preferences.dart';
import '../data/database_helper.dart';
import 'committee_form_screen.dart';
import 'committee_members_screen.dart';

class ClientCommitteesScreen extends StatefulWidget {
  const ClientCommitteesScreen({
    super.key,
    required this.clientId,
    required this.clientName,
  });

  final int clientId;
  final String clientName;

  @override
  State<ClientCommitteesScreen> createState() => _ClientCommitteesScreenState();
}

class _ClientCommitteesScreenState extends State<ClientCommitteesScreen> {
  static const List<String> _statusOptions = [
    'All',
    'Active',
    'Completed',
    'On Hold',
  ];

  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  List<Map<String, Object?>> _committees = [];
  bool _isLoading = true;
  String _statusFilter = 'All';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final savedFilter = await AppPreferences.getCommitteeStatusFilter();
    if (!mounted) {
      return;
    }

    setState(() {
      _statusFilter = _statusOptions.contains(savedFilter)
          ? savedFilter
          : 'All';
    });

    await _loadCommittees();
  }

  Future<void> _loadCommittees() async {
    setState(() {
      _isLoading = true;
    });

    final committees = await _databaseHelper.getCommitteesByClient(
      widget.clientId,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _committees = committees;
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
            'This will remove the committee and all member records.',
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Committee deleted.')),
    );
    await _loadCommittees();
  }

  Future<void> _openCommitteeForm({Map<String, Object?>? committee}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CommitteeFormScreen(
          clientId: widget.clientId,
          committee: committee,
        ),
      ),
    );

    await _loadCommittees();
  }

  Future<void> _changeFilter(String? value) async {
    if (value == null) {
      return;
    }

    setState(() {
      _statusFilter = value;
    });
    await AppPreferences.setCommitteeStatusFilter(value);
  }

  @override
  Widget build(BuildContext context) {
    final filteredCommittees = _statusFilter == 'All'
        ? _committees
        : _committees
            .where(
              (item) => (item['status'] ?? '').toString() == _statusFilter,
            )
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.clientName} Committees'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCommitteeForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Committee'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Committee Overview'),
                                const SizedBox(height: 4),
                                Text(
                                  '${filteredCommittees.length} of ${_committees.length} shown',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          DropdownButton<String>(
                            value: _statusFilter,
                            onChanged: _changeFilter,
                            items: _statusOptions
                                .map(
                                  (status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(status),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: filteredCommittees.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.account_tree_outlined,
                                  size: 52,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: 10),
                                const Text('No committees available.'),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: filteredCommittees.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final committee = filteredCommittees[index];
                              final id = committee['id'] as int;
                              final name = (committee['name'] ?? '').toString();
                              final status =
                                  (committee['status'] ?? '').toString();
                              final startDate =
                                  (committee['start_date'] ?? '').toString();

                              final colorScheme = Theme.of(context).colorScheme;
                              final statusColor = switch (status) {
                                'Active' => colorScheme.primary,
                                'Completed' => Colors.green,
                                'On Hold' => Colors.orange,
                                _ => colorScheme.outline,
                              };

                              return Card(
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.groups_outlined),
                                  ),
                                  title: Text(name),
                                  subtitle: Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withAlpha(25),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          status,
                                          style: TextStyle(
                                            color: statusColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      if (startDate.trim().isNotEmpty)
                                        Text('Start: $startDate'),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                CommitteeMembersScreen(
                                                  committeeId: id,
                                                  committeeName: name,
                                                ),
                                          ),
                                        )
                                        .then((_) => _loadCommittees());
                                  },
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () => _openCommitteeForm(
                                          committee: committee,
                                        ),
                                      ),
                                      IconButton(
                                        icon:
                                            const Icon(Icons.delete_outline),
                                        onPressed: () => _deleteCommittee(id),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
