import 'package:flutter/material.dart';

class AdminAccessControlScreen extends StatefulWidget {
  const AdminAccessControlScreen({super.key});

  static const String routeName = '/admin-access-control';

  @override
  State<AdminAccessControlScreen> createState() =>
      _AdminAccessControlScreenState();
}

class _AdminAccessControlScreenState extends State<AdminAccessControlScreen> {
  bool _allowSupervisorSelfAssign = false;
  bool _studentDocumentUploads = true;
  bool _committeeApprovalsRequired = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Control'),
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
                  title: Text('Allow supervisor self-assign'),
                  subtitle: Text('Supervisors can claim open projects.'),
                  value: _allowSupervisorSelfAssign,
                  onChanged: (value) => setState(() {
                    _allowSupervisorSelfAssign = value;
                  }),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Text('Student document uploads'),
                  subtitle: Text('Enable project document submissions.'),
                  value: _studentDocumentUploads,
                  onChanged: (value) => setState(() {
                    _studentDocumentUploads = value;
                  }),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Text('Committee approvals required'),
                  subtitle: Text(
                    'Require committee review before final submit.',
                  ),
                  value: _committeeApprovalsRequired,
                  onChanged: (value) => setState(() {
                    _committeeApprovalsRequired = value;
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Access rules saved.')),
              );
            },
            child: const Text('Save Access Rules'),
          ),
        ],
      ),
    );
  }
}
