import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class StudentAnnouncementsSection extends StatelessWidget {
  const StudentAnnouncementsSection({
    super.key,
    required this.adminRef,
  });

  final DatabaseReference adminRef;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: adminRef.child('announcements').onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const Center(child: Text('No announcements'));
        }

        final announcements = Map<String, dynamic>.from(
          snapshot.data!.snapshot.value as Map,
        );
        final announcementsList = announcements.entries.toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: announcementsList.length,
          itemBuilder: (context, index) {
            final announcement = Map<String, dynamic>.from(
              announcementsList[index].value,
            );
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.borderSoft),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFEEF2FF),
                  child: const Icon(Icons.notifications, color: Color(0xFF38BDF8)),
                ),
                title: Text(
                  announcement['title'] ?? 'Announcement',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.studentTeal,
                  ),
                ),
                subtitle: Text(
                  announcement['content'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
