import 'package:flutter/material.dart';

import 'committee_nav_bar.dart';

class CommitteeVivaSchedulingScreen extends StatefulWidget {
  const CommitteeVivaSchedulingScreen({super.key});

  static const String routeName = '/committee-viva-scheduling';

  @override
  State<CommitteeVivaSchedulingScreen> createState() =>
      _CommitteeVivaSchedulingScreenState();
}

class _CommitteeVivaSchedulingScreenState
    extends State<CommitteeVivaSchedulingScreen> {
  final List<_VivaItem> _items = [
    _VivaItem('Group A', 'Project Title: mmmm', 4, true),
    _VivaItem('Group B', 'Project Title: mmmm', 4, true),
    _VivaItem('Group C', 'Project Title: mmmm', 4, false),
  ];

  Future<void> _scheduleViva(_VivaItem item) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: item.scheduledDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      item.scheduledDate = picked;
      item.isNew = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Scheduled ${item.group} for ${item.dateLabel}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('[LOGO]'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
            tooltip: 'Notifications',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                'VIVA SCHEDULING MENU',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return _ScheduleCard(
                    item: item,
                    onSchedule: () => _scheduleViva(item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CommitteeNavBar(selectedIndex: 2),
    );
  }
}

class _VivaItem {
  _VivaItem(this.group, this.projectTitle, this.memberCount, this.isNew);

  final String group;
  final String projectTitle;
  final int memberCount;
  bool isNew;
  DateTime? scheduledDate;

  String get dateLabel {
    if (scheduledDate == null) {
      return 'DATE';
    }
    final month = scheduledDate!.month.toString().padLeft(2, '0');
    final day = scheduledDate!.day.toString().padLeft(2, '0');
    return '${scheduledDate!.year}-$month-$day';
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.item, required this.onSchedule});

  final _VivaItem item;
  final VoidCallback onSchedule;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE6E6E6)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  item.group.toUpperCase(),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  item.dateLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF5F6C7B),
                  ),
                ),
                const SizedBox(width: 8),
                if (item.isNew)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EEF6),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text('NEW', style: TextStyle(fontSize: 11)),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.projectTitle),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 16),
                          const SizedBox(width: 6),
                          Text(item.memberCount.toString()),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '----------------',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFFB0B6BE),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: onSchedule,
                  child: Text(
                    item.scheduledDate == null ? 'SCHEDULE VIVA' : 'RESCHEDULE',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
