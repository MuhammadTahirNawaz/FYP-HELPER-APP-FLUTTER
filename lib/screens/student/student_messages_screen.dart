import 'package:flutter/material.dart';
import '../shared/messages_screen.dart';
import 'student_nav_bar.dart';

class StudentMessagesScreen extends StatelessWidget {
  const StudentMessagesScreen({super.key});

  static const String routeName = '/student-messages';

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
      bottomNavigationBar: const StudentNavBar(selectedIndex: 2),
    );
  }
}
