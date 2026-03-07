import 'package:flutter/material.dart';

import '../data/database_helper.dart';
import 'admin_dashboard_screen.dart';
import 'client_committees_screen.dart';
import 'client_form_screen.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  List<Map<String, Object?>> _clients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    setState(() {
      _isLoading = true;
    });

    final clients = await _databaseHelper.getClients();

    if (!mounted) {
      return;
    }

    setState(() {
      _clients = clients;
      _isLoading = false;
    });
  }

  Future<void> _deleteClient(int id) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete client'),
          content: const Text(
            'This will remove the client and related committees/members.',
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

    await _databaseHelper.deleteClient(id);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Client deleted.')));
    await _loadClients();
  }

  Future<void> _openClientForm({Map<String, Object?>? client}) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ClientFormScreen(client: client)));

    await _loadClients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Directory'),
        actions: [
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
        onPressed: () => _openClientForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Client'),
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
                          child: const Icon(Icons.business_center_outlined),
                        ),
                        title: const Text('Total Clients'),
                        subtitle: const Text(
                          'Manage your client base and teams',
                        ),
                        trailing: Text(
                          '${_clients.length}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child:
                          _clients.isEmpty
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                    const Text('No clients added yet.'),
                                  ],
                                ),
                              )
                              : ListView.separated(
                                itemCount: _clients.length,
                                separatorBuilder:
                                    (_, __) => const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final client = _clients[index];
                                  final id = client['id'] as int;
                                  final name =
                                      (client['name'] ?? '').toString();
                                  final company =
                                      (client['company'] ?? '').toString();
                                  final phone =
                                      (client['phone'] ?? '').toString();

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
                                        [company, phone]
                                            .where(
                                              (part) => part.trim().isNotEmpty,
                                            )
                                            .join(' • '),
                                      ),
                                      onTap: () {
                                        Navigator.of(context)
                                            .push(
                                              MaterialPageRoute(
                                                builder:
                                                    (_) =>
                                                        ClientCommitteesScreen(
                                                          clientId: id,
                                                          clientName: name,
                                                        ),
                                              ),
                                            )
                                            .then((_) => _loadClients());
                                      },
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed:
                                                () => _openClientForm(
                                                  client: client,
                                                ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                            ),
                                            onPressed: () => _deleteClient(id),
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
