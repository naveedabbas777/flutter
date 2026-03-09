import 'package:flutter/material.dart';

import '../data/database_helper.dart';
import 'admin_dashboard_screen.dart';
import 'member_form_screen.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  bool _isLoading = false;
  List<Map<String, Object?>> _members = [];
  Map<int, String> _committeeNames = {};
  String _searchQuery = '';

  int _toInt(Object? value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() {
      _isLoading = true;
    });

    final members = await _databaseHelper.getAllMembers();
    final committees = await _databaseHelper.getAllCommittees();
    final committeeNames = <int, String>{};
    for (final committee in committees) {
      final id = _toInt(committee['id']);
      final name = (committee['name'] ?? '').toString();
      committeeNames[id] = name;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _members = members;
      _committeeNames = committeeNames;
      _isLoading = false;
    });
  }

  Future<void> _deleteMember(int id) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete member'),
          content: const Text(
            'This member will be removed from all committees.',
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

    await _databaseHelper.deleteMember(id);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Member deleted.')));
    await _loadMembers();
  }

  Future<void> _openMemberForm({Map<String, Object?>? member}) async {
    // For adding new member, we need to select committee first
    if (member == null) {
      final selectedCommitteeId = await _showCommitteeSelectionDialog();
      if (selectedCommitteeId == null) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (_) => MemberFormScreen(
                committeeId: selectedCommitteeId,
                member: member,
              ),
        ),
      );
    } else {
      // For editing, use existing committee
      final committeeId = _toInt(member['committee_id']);
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (_) => MemberFormScreen(committeeId: committeeId, member: member),
        ),
      );
    }
    await _loadMembers();
  }

  Future<int?> _showCommitteeSelectionDialog() async {
    final committees = await _databaseHelper.getAllCommittees();
    if (committees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No committees available. Create a committee first.'),
        ),
      );
      return null;
    }

    return showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Select Committee'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: committees.length,
              itemBuilder: (context, index) {
                final committee = committees[index];
                final id = _toInt(committee['id']);
                final name = (committee['name'] ?? '').toString();
                return ListTile(
                  title: Text(name),
                  onTap: () => Navigator.of(dialogContext).pop(id),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Members Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMembers,
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
        onPressed: () => _openMemberForm(),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Member'),
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
                          title: const Text('Total Members'),
                          subtitle: const Text(
                            'Manage members across all committees',
                          ),
                          trailing: Text(
                            '${_members.length}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
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
                      const SizedBox(height: 12),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child:
                                _members.isEmpty
                                    ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.group_off_outlined,
                                            size: 52,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                          ),
                                          const SizedBox(height: 10),
                                          const Text('No members added yet.'),
                                        ],
                                      ),
                                    )
                                    : SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        columns: const [
                                          DataColumn(label: Text('ID')),
                                          DataColumn(label: Text('Name')),
                                          DataColumn(label: Text('Role')),
                                          DataColumn(label: Text('Committee')),
                                          DataColumn(label: Text('Phone')),
                                          DataColumn(label: Text('Email')),
                                          DataColumn(label: Text('Actions')),
                                        ],
                                        rows:
                                            _members
                                                .where((member) {
                                                  final name =
                                                      (member['name'] ?? '')
                                                          .toString()
                                                          .toLowerCase();
                                                  final role =
                                                      (member['role'] ?? '')
                                                          .toString()
                                                          .toLowerCase();
                                                  final committeeId = _toInt(
                                                    member['committee_id'],
                                                  );
                                                  final committeeName =
                                                      _committeeNames[committeeId]
                                                          ?.toLowerCase() ??
                                                      '';
                                                  final query =
                                                      _searchQuery
                                                          .toLowerCase();
                                                  return name.contains(query) ||
                                                      role.contains(query) ||
                                                      committeeName.contains(
                                                        query,
                                                      );
                                                })
                                                .map((member) {
                                                  final id = _toInt(
                                                    member['id'],
                                                  );
                                                  final name =
                                                      (member['name'] ?? '')
                                                          .toString();
                                                  final role =
                                                      (member['role'] ?? '')
                                                          .toString();
                                                  final committeeId = _toInt(
                                                    member['committee_id'],
                                                  );
                                                  final committeeName =
                                                      _committeeNames[committeeId] ??
                                                      'Unknown';
                                                  final phone =
                                                      (member['phone'] ?? '')
                                                          .toString();
                                                  final email =
                                                      (member['email'] ?? '')
                                                          .toString();
                                                  return DataRow(
                                                    cells: [
                                                      DataCell(Text('$id')),
                                                      DataCell(Text(name)),
                                                      DataCell(Text(role)),
                                                      DataCell(
                                                        Text(committeeName),
                                                      ),
                                                      DataCell(Text(phone)),
                                                      DataCell(Text(email)),
                                                      DataCell(
                                                        Row(
                                                          children: [
                                                            IconButton(
                                                              icon: const Icon(
                                                                Icons.edit,
                                                              ),
                                                              tooltip:
                                                                  'Edit Member',
                                                              onPressed:
                                                                  () => _openMemberForm(
                                                                    member:
                                                                        member,
                                                                  ),
                                                            ),
                                                            IconButton(
                                                              icon: const Icon(
                                                                Icons
                                                                    .delete_outline,
                                                              ),
                                                              tooltip:
                                                                  'Delete Member',
                                                              onPressed:
                                                                  () =>
                                                                      _deleteMember(
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
