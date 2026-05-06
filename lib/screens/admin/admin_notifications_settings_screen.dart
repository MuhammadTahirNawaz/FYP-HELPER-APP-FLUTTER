import 'package:flutter/material.dart';

class AdminNotificationsSettingsScreen extends StatefulWidget {
  const AdminNotificationsSettingsScreen({super.key});

  static const String routeName = '/admin-notifications-settings';

  @override
  State<AdminNotificationsSettingsScreen> createState() =>
      _AdminNotificationsSettingsScreenState();
}

class _AdminNotificationsSettingsScreenState
    extends State<AdminNotificationsSettingsScreen> {
  bool _emailAlerts = true;
  bool _supervisorRequests = false;
  bool _weeklySummaries = true;

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
                  title: Text('Email alerts'),
                  subtitle: Text('Receive updates for submissions.'),
                  value: _emailAlerts,
                  onChanged: (value) => setState(() {
                    _emailAlerts = value;
                  }),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Text('Supervisor requests'),
                  subtitle: Text('Notify when new requests arrive.'),
                  value: _supervisorRequests,
                  onChanged: (value) => setState(() {
                    _supervisorRequests = value;
                  }),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Text('Weekly summaries'),
                  subtitle: Text('Email summary every Monday.'),
                  value: _weeklySummaries,
                  onChanged: (value) => setState(() {
                    _weeklySummaries = value;
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
