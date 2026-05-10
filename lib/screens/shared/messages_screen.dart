import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({
    super.key,
    required this.isAdmin,
    this.showAppBar = false,
  });

  final bool isAdmin;
  final bool showAppBar;

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final DatabaseReference _threadsRef =
      FirebaseDatabase.instance.ref('messages/threads');
  final DatabaseReference _itemsRef =
      FirebaseDatabase.instance.ref('messages/items');
  final DatabaseReference _usersRef =
      FirebaseDatabase.instance.ref('users');
  final TextEditingController _messageController = TextEditingController();

  String? _selectedThreadId;
  bool _sending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String threadId, String text) async {
    if (_sending) {
      return;
    }
    setState(() => _sending = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _sending = false);
      return;
    }

    final payload = <String, dynamic>{
      'senderUid': user.uid,
      'senderRole': widget.isAdmin ? 'Admin' : 'User',
      'text': text.trim(),
      'createdAt': ServerValue.timestamp,
    };

    await _itemsRef.child(threadId).push().set(payload);
    await _threadsRef.child(threadId).update({
      'lastMessage': text.trim(),
      'updatedAt': ServerValue.timestamp,
    });

    _messageController.clear();
    if (mounted) {
      setState(() => _sending = false);
    }
  }

  Future<String?> _resolveThreadForUser(String uid, String email) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    // Create a unique key for this conversation pair (bidirectional)
    final uids = [user.uid, uid];
    uids.sort();
    final conversationKey = '${uids[0]}__${uids[1]}';

    final query = _threadsRef.orderByChild('conversationKey').equalTo(conversationKey);
    final snapshot = await query.get();
    if (snapshot.exists && snapshot.value is Map) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      return data.keys.first;
    }

    final newThread = _threadsRef.push();
    await newThread.set({
      'conversationKey': conversationKey,
      'participantUid1': uids[0],
      'participantUid2': uids[1],
      'userUid': uid,
      'userEmail': email,
      'initiatorUid': user.uid,
      'lastMessage': '',
      'createdAt': ServerValue.timestamp,
      'updatedAt': ServerValue.timestamp,
    });
    return newThread.key;
  }

  Future<void> _startAdminThread() async {
    final emailController = TextEditingController();
    final messageController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('New Message'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'User email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: messageController,
                  decoration: const InputDecoration(labelText: 'Message'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final email = emailController.text.trim();
                final message = messageController.text.trim();
                if (email.isEmpty || message.isEmpty) {
                  return;
                }
                Navigator.of(dialogContext).pop();
                await _sendToUserByEmail(email, message);
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
    emailController.dispose();
    messageController.dispose();
  }

  Future<void> _sendToUserByEmail(String email, String message) async {
    final normalizedEmail = email.trim().toLowerCase();
    
    String? foundUid;

    try {
      final query = FirebaseDatabase.instance.ref('users').orderByChild('email').equalTo(normalizedEmail);
      final snapshot = await query.get();
      if (snapshot.exists && snapshot.value is Map) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        foundUid = data.keys.first;
      }
    } catch (e) {
      debugPrint('Error searching for user: $e');
      if (e.toString().contains('permission-denied')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Firebase Permission Denied. Please add the "messages" node to your rules and ensure "users" has an index on "email".'),
              duration: Duration(seconds: 6),
            ),
          );
        }
        return;
      }
    }

    if (foundUid == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not found. Ensure the email is correct.'),
            duration: Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    final threadId = await _resolveThreadForUser(foundUid, normalizedEmail);
    if (threadId == null) {
      return;
    }
    setState(() => _selectedThreadId = threadId);
    await _sendMessage(threadId, message);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message sent.')),
      );
    }
  }

  Widget _buildThreadList(List<_Thread> threads) {
    if (threads.isEmpty) {
      return const Center(child: Text('No conversations yet.'));
    }

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: threads
          .map(
            (thread) => Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE6E6E6)),
              ),
              child: ListTile(
                title: Text(thread.userEmail),
                subtitle: Text(
                  thread.lastMessage.isEmpty
                      ? 'No messages yet.'
                      : thread.lastMessage,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => setState(() => _selectedThreadId = thread.id),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildMessageList(String threadId) {
    return StreamBuilder<DatabaseEvent>(
      stream: _itemsRef.child(threadId).onValue,
      builder: (context, snapshot) {
        final data = snapshot.data?.snapshot.value;
        final messages = _MessageItem.fromSnapshot(data);

        if (messages.isEmpty) {
          return const Center(child: Text('No messages yet.'));
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isMe =
                message.senderUid == FirebaseAuth.instance.currentUser?.uid;
            return Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(12),
                constraints: const BoxConstraints(maxWidth: 280),
                decoration: BoxDecoration(
                  color: isMe
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.12)
                      : const Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(message.text),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildComposer(String threadId) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _messageController,
            minLines: 1,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Type a message',
            ),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: _sending
              ? null
              : () {
                  final text = _messageController.text.trim();
                  if (text.isEmpty) {
                    return;
                  }
                  _sendMessage(threadId, text);
                },
          child: const Text('Send'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Please sign in.'));
    }

    final content = StreamBuilder<DatabaseEvent>(
      stream: _threadsRef.onValue,
      builder: (context, snapshot) {
        var threads = _Thread.fromSnapshot(snapshot.data?.snapshot.value);
        
        // For non-admin users, filter to only their conversations
        if (!widget.isAdmin) {
          threads = threads
              .where((thread) =>
                  thread.participantUid1 == user.uid ||
                  thread.participantUid2 == user.uid)
              .toList();
        }

        if (!widget.isAdmin && threads.isNotEmpty && _selectedThreadId == null) {
          _selectedThreadId = threads.first.id;
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.isAdmin ? 'Conversations' : 'Messages',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                FilledButton.icon(
                  onPressed: widget.isAdmin ? _startAdminThread : _startUserThread,
                  icon: const Icon(Icons.add),
                  label: const Text('New'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (threads.isEmpty && !widget.isAdmin)
              Center(
                child: Column(
                  children: [
                    const Text('No messages yet.'),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _startUserThread,
                      child: const Text('Start Conversation'),
                    ),
                  ],
                ),
              )
            else
              _buildThreadList(threads),
            const SizedBox(height: 16),
            if (_selectedThreadId != null) ...[
              Text(
                'Conversation',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              _buildMessageList(_selectedThreadId!),
              const SizedBox(height: 12),
              _buildComposer(_selectedThreadId!),
            ] else
              const Text('Select a conversation to view messages.'),
          ],
        );
      },
    );

    if (!widget.showAppBar) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: content,
    );
  }

  Future<void> _startUserThread() async {
    final emailController = TextEditingController();
    final messageController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('New Message'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Recipient email',
                    hintText: 'Enter email address',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: messageController,
                  decoration: const InputDecoration(labelText: 'Message'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final email = emailController.text.trim();
                final message = messageController.text.trim();
                if (email.isEmpty || message.isEmpty) {
                  return;
                }
                Navigator.of(dialogContext).pop();
                await _sendToUserByEmail(email, message);
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
    emailController.dispose();
    messageController.dispose();
  }
}

class _Thread {
  const _Thread({
    required this.id,
    required this.userEmail,
    required this.lastMessage,
    required this.updatedAt,
    this.participantUid1 = '',
    this.participantUid2 = '',
  });

  final String id;
  final String userEmail;
  final String lastMessage;
  final int updatedAt;
  final String participantUid1;
  final String participantUid2;

  static List<_Thread> fromSnapshot(Object? data) {
    if (data is! Map) {
      return <_Thread>[];
    }
    final entries = Map<String, dynamic>.from(data);
    final threads = entries.entries.map((entry) {
      final value = Map<String, dynamic>.from(entry.value as Map);
      return _Thread(
        id: entry.key,
        userEmail: (value['userEmail'] as String?) ?? 'Unknown',
        lastMessage: (value['lastMessage'] as String?) ?? '',
        updatedAt: (value['updatedAt'] as int?) ?? 0,
        participantUid1: (value['participantUid1'] as String?) ?? '',
        participantUid2: (value['participantUid2'] as String?) ?? '',
      );
    }).toList();
    threads.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return threads;
  }
}

class _MessageItem {
  const _MessageItem({
    required this.id,
    required this.senderUid,
    required this.text,
  });

  final String id;
  final String senderUid;
  final String text;

  static List<_MessageItem> fromSnapshot(Object? data) {
    if (data is! Map) {
      return <_MessageItem>[];
    }
    final entries = Map<String, dynamic>.from(data);
    final items = entries.entries.map((entry) {
      final value = Map<String, dynamic>.from(entry.value as Map);
      return _MessageItem(
        id: entry.key,
        senderUid: (value['senderUid'] as String?) ?? '',
        text: (value['text'] as String?) ?? '',
      );
    }).toList();
    return items;
  }
}
