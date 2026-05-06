import 'package:flutter/material.dart';

class SupervisorNotificationsSettingsScreen extends StatefulWidget {
  const SupervisorNotificationsSettingsScreen({super.key});

  static const String routeName = '/supervisor-notifications-settings';

  @override
  State<SupervisorNotificationsSettingsScreen> createState() =>
      _SupervisorNotificationsSettingsScreenState();
}

class _SupervisorNotificationsSettingsScreenState
    extends State<SupervisorNotificationsSettingsScreen> {
  bool _studentRequests = true;
  bool _reportUpdates = true;
  bool _vivaAlerts = false;

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
                  title: const Text('Student requests'),
                  subtitle: const Text('Notify when new groups request you.'),
                  value: _studentRequests,
                  onChanged: (value) => setState(() {
                    _studentRequests = value;
                  }),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Progress report updates'),
                  subtitle: const Text('Alert when reports are submitted.'),
                  value: _reportUpdates,
                  onChanged: (value) => setState(() {
                    _reportUpdates = value;
                  }),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Viva schedule alerts'),
                  subtitle: const Text(
                    'Get notified about viva schedule changes.',
                  ),
                  value: _vivaAlerts,
                  onChanged: (value) => setState(() {
                    _vivaAlerts = value;
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
