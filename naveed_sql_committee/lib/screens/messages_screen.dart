import 'package:flutter/material.dart';

import '../data/database_helper.dart';
import 'send_message_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  bool _isLoading = false;
  List<Map<String, Object?>> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    final messages = await _databaseHelper.getMessages();

    if (!mounted) {
      return;
    }

    setState(() {
      _messages = messages;
      _isLoading = false;
    });
  }

  Future<void> _deleteMessage(int id) async {
    await _databaseHelper.deleteMessage(id);
    await _loadMessages();
  }

  Future<void> _markAsRead(int id) async {
    await _databaseHelper.markMessageAsRead(id);
    await _loadMessages();
  }

  Future<void> _openSendMessage() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SendMessageScreen()));
    await _loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMessages,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _openSendMessage,
            tooltip: 'Send Message',
          ),
        ],
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
                onRefresh: _loadMessages,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    children: [
                    Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          child: const Icon(Icons.mail_outline),
                        ),
                        title: const Text('Messages'),
                        subtitle: const Text('View and manage your messages'),
                        trailing: Text(
                          '${_messages.length}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_messages.isEmpty)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.mail_outline,
                              size: 52,
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 10),
                            const Text('No messages yet.'),
                          ],
                        ),
                      )
                    else
                      ..._messages.map((message) {
                        final id = message['id'] as int;
                        final sender = message['sender'] as String;
                        final subject = message['subject'] as String;
                        final sentAt = message['sent_at'] as String;
                        final isRead = message['is_read'] as bool? ?? false;

                        return Card(
                          child: ListTile(
                            leading: Icon(
                              isRead ? Icons.mail : Icons.mail_outline,
                              color:
                                  isRead
                                      ? null
                                      : Theme.of(context).colorScheme.primary,
                            ),
                            title: Text(subject),
                            subtitle: Text('From: $sender • $sentAt'),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                switch (value) {
                                  case 'read':
                                    _markAsRead(id);
                                  case 'delete':
                                    _deleteMessage(id);
                                }
                              },
                              itemBuilder:
                                  (context) => [
                                    if (!isRead)
                                      const PopupMenuItem(
                                        value: 'read',
                                        child: Text('Mark as Read'),
                                      ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete'),
                                    ),
                                  ],
                            ),
                            onTap: () => _showMessageDialog(message),
                          ),
                        );
                      }),
                  ],
                ),
              ),
    );
  }

  void _showMessageDialog(Map<String, Object?> message) {
    final sender = message['sender'] as String;
    final recipient = message['recipient'] as String;
    final subject = message['subject'] as String;
    final messageText = message['message'] as String;
    final sentAt = message['sent_at'] as String;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(subject),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('From: $sender'),
                Text('To: $recipient'),
                Text('Sent: $sentAt'),
                const SizedBox(height: 12),
                Text(messageText),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );

    // Mark as read if not already
    final id = message['id'] as int;
    final isRead = message['is_read'] as bool? ?? false;
    if (!isRead) {
      _markAsRead(id);
    }
  }
}
