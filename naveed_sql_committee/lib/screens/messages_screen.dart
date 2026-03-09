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
    setState(() => _isLoading = true);

    final messages = await _databaseHelper.getMessages();

    if (!mounted) return;

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
    await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SendMessageScreen()));
    await _loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount =
        _messages.where((m) => m['is_read'] != true).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF9C27B0), Color(0xFFE040FB)],
            ),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Messages',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Send and receive messages',
                style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadMessages,
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openSendMessage,
        backgroundColor: const Color(0xFF9C27B0),
        icon: const Icon(Icons.edit_rounded),
        label: const Text('Compose'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadMessages,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Stats card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF9C27B0), Color(0xFFE040FB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9C27B0)
                              .withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.mail_rounded,
                              color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_messages.length} Messages',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              if (unreadCount > 0)
                                Text(
                                  '$unreadCount unread',
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_messages.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.mail_rounded,
                                size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text('No messages yet',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600)),
                            const SizedBox(height: 8),
                            Text('Tap Compose to send a new message',
                                style: TextStyle(
                                    color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._messages.map((message) {
                      final id = message['id'] as int;
                      final sender = message['sender'] as String;
                      final subject = message['subject'] as String;
                      final sentAt = message['sent_at'] as String;
                      final isRead = message['is_read'] as bool? ?? false;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          elevation: isRead ? 1 : 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: isRead
                                ? BorderSide.none
                                : const BorderSide(
                                    color: Color(0xFF9C27B0),
                                    width: 1),
                          ),
                          child: InkWell(
                            onTap: () => _showMessageDialog(message),
                            borderRadius: BorderRadius.circular(14),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: isRead
                                        ? Colors.grey.shade200
                                        : const Color(0xFF9C27B0)
                                            .withValues(alpha: 0.1),
                                    child: Icon(
                                      isRead
                                          ? Icons.drafts_rounded
                                          : Icons.mail_rounded,
                                      color: isRead
                                          ? Colors.grey.shade500
                                          : const Color(0xFF9C27B0),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(subject,
                                            style: TextStyle(
                                              fontWeight: isRead
                                                  ? FontWeight.normal
                                                  : FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                            maxLines: 1,
                                            overflow:
                                                TextOverflow.ellipsis),
                                        const SizedBox(height: 4),
                                        Text(
                                          'From: $sender',
                                          style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 13),
                                        ),
                                        Text(
                                          sentAt,
                                          style: TextStyle(
                                              color: Colors.grey.shade400,
                                              fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      switch (value) {
                                        case 'read':
                                          _markAsRead(id);
                                        case 'delete':
                                          _deleteMessage(id);
                                      }
                                    },
                                    itemBuilder: (context) => [
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
                                ],
                              ),
                            ),
                          ),
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
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFF9C27B0).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.mail_rounded,
                    color: Color(0xFF9C27B0), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(subject,
                    style: const TextStyle(fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _detailRow(Icons.person_rounded, 'From', sender),
                const SizedBox(height: 6),
                _detailRow(
                    Icons.person_outline_rounded, 'To', recipient),
                const SizedBox(height: 6),
                _detailRow(
                    Icons.schedule_rounded, 'Sent', sentAt),
                const Divider(height: 24),
                Text(messageText,
                    style: const TextStyle(fontSize: 15)),
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

    final id = message['id'] as int;
    final isRead = message['is_read'] as bool? ?? false;
    if (!isRead) {
      _markAsRead(id);
    }
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Text('$label: ',
            style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
                fontSize: 13)),
        Expanded(
          child: Text(value,
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
