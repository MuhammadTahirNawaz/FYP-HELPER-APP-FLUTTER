import 'package:flutter/material.dart';
import '../shared/messages_screen.dart';
import 'supervisor_nav_bar.dart';

class SupervisorMessagesScreen extends StatelessWidget {
  const SupervisorMessagesScreen({super.key});

  static const String routeName = '/supervisor-messages';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        automaticallyImplyLeading: false,
      ),
      body: const MessagesScreen(
        isAdmin: false,
        showAppBar: false,
      ),
      bottomNavigationBar: const SupervisorNavBar(selectedIndex: 1),
    );
  }
}
