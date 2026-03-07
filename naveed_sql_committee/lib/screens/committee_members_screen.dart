import 'package:flutter/material.dart';

import '../data/database_helper.dart';
import 'member_form_screen.dart';

class CommitteeMembersScreen extends StatefulWidget {
  const CommitteeMembersScreen({
    super.key,
    required this.committeeId,
    required this.committeeName,
  });

  final int committeeId;
  final String committeeName;

  @override
  State<CommitteeMembersScreen> createState() => _CommitteeMembersScreenState();
}

class _CommitteeMembersScreenState extends State<CommitteeMembersScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  List<Map<String, Object?>> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() {
      _isLoading = true;
    });

    final members = await _databaseHelper.getMembersByCommittee(
      widget.committeeId,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _members = members;
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
            'This member will be removed from the committee.',
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
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => MemberFormScreen(
              committeeId: widget.committeeId,
              member: member,
            ),
      ),
    );

    await _loadMembers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.committeeName} Members')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openMemberForm(),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Member'),
      ),
      body:
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
                          child: const Icon(Icons.groups_3_outlined),
                        ),
                        title: const Text('Committee Members'),
                        subtitle: const Text('Team overview and contacts'),
                        trailing: Text(
                          '${_members.length}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child:
                          _members.isEmpty
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                    const Text(
                                      'No committee members added yet.',
                                    ),
                                  ],
                                ),
                              )
                              : ListView.separated(
                                itemCount: _members.length,
                                separatorBuilder:
                                    (_, __) => const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final member = _members[index];
                                  final id = member['id'] as int;
                                  final name =
                                      (member['name'] ?? '').toString();
                                  final role =
                                      (member['role'] ?? '').toString();
                                  final phone =
                                      (member['phone'] ?? '').toString();

                                  return Card(
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 8,
                                          ),
                                      leading: const CircleAvatar(
                                        child: Icon(Icons.person_outline),
                                      ),
                                      title: Text(name),
                                      subtitle: Text(
                                        [role, phone]
                                            .where(
                                              (part) => part.trim().isNotEmpty,
                                            )
                                            .join(' • '),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed:
                                                () => _openMemberForm(
                                                  member: member,
                                                ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                            ),
                                            onPressed: () => _deleteMember(id),
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
