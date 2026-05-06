import 'package:flutter/material.dart';

class StudentNotificationsSettingsScreen extends StatefulWidget {
  const StudentNotificationsSettingsScreen({super.key});

  static const String routeName = '/student-notifications-settings';

  @override
  State<StudentNotificationsSettingsScreen> createState() =>
      _StudentNotificationsSettingsScreenState();
}

class _StudentNotificationsSettingsScreenState
    extends State<StudentNotificationsSettingsScreen> {
  bool _reportReminders = true;
  bool _deadlineAlerts = true;
  bool _supervisorUpdates = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFE6E6E6)),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Report reminders'),
                  subtitle: const Text('Remind me about report deadlines.'),
                  value: _reportReminders,
                  onChanged: (value) => setState(() {
                    _reportReminders = value;
                  }),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Deadline alerts'),
                  subtitle: const Text('Notify about upcoming submissions.'),
                  value: _deadlineAlerts,
                  onChanged: (value) => setState(() {
                    _deadlineAlerts = value;
                  }),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Supervisor updates'),
                  subtitle: const Text('Get updates from your supervisor.'),
                  value: _supervisorUpdates,
                  onChanged: (value) => setState(() {
                    _supervisorUpdates = value;
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Preferences saved.')),
              );
            },
            child: const Text('Save Preferences'),
          ),
        ],
      ),
    );
  }
}
