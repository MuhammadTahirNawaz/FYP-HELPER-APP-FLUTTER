import 'package:flutter/material.dart';
import '../../widgets/change_password_widget.dart';

class SupervisorSecuritySettingsScreen extends StatelessWidget {
  const SupervisorSecuritySettingsScreen({super.key});

  static const String routeName = '/supervisor-security-settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: ChangePasswordWidget(),
      ),
    );
  }
}
