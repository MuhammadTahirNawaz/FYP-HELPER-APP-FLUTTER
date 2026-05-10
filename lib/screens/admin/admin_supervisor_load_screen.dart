import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AdminSupervisorLoadScreen extends StatelessWidget {
  const AdminSupervisorLoadScreen({super.key});

  static const String routeName = '/admin-supervisor-load';

  @override
  Widget build(BuildContext context) {
    final usersRef = FirebaseDatabase.instance.ref('users');
    final groupsRef = FirebaseDatabase.instance.ref('groups');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supervisor Load'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: FutureBuilder<List<DataSnapshot>>(
        future: Future.wait([usersRef.get(), groupsRef.get()]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final usersSnap = snapshot.data![0];
          final groupsSnap = snapshot.data![1];

          // Build supervisor map: uid -> name
          final supervisors = <String, String>{};
          if (usersSnap.value is Map) {
            final usersMap = Map<String, dynamic>.from(usersSnap.value as Map);
            for (final e in usersMap.entries) {
              if (e.value is! Map) continue;
              final user = Map<String, dynamic>.from(e.value as Map);
              if (user['role'] == 'Supervisor') {
                supervisors[e.key] =
                    (user['displayName'] as String?) ??
                    (user['email'] as String?) ??
                    e.key;
              }
            }
          }

          if (supervisors.isEmpty) {
            return const Center(
              child: Text(
                'No supervisors found.',
                style: TextStyle(color: Color(0xFF6B7A99)),
              ),
            );
          }

          // Count groups per supervisor
          final loadCount = <String, int>{};
          for (final uid in supervisors.keys) {
            loadCount[uid] = 0;
          }
          if (groupsSnap.value is Map) {
            final groupsMap = Map<String, dynamic>.from(groupsSnap.value as Map);
            for (final g in groupsMap.values) {
              if (g is! Map) continue;
              final sid = (Map<String, dynamic>.from(g))['supervisorId'] as String?;
              if (sid != null && loadCount.containsKey(sid)) {
                loadCount[sid] = (loadCount[sid] ?? 0) + 1;
              }
            }
          }

          // Sort by load descending
          final sorted = supervisors.entries.toList()
            ..sort((a, b) =>
                (loadCount[b.key] ?? 0).compareTo(loadCount[a.key] ?? 0));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final uid = sorted[index].key;
              final name = sorted[index].value;
              final count = loadCount[uid] ?? 0;
              final pct = sorted.isEmpty ? 0.0 : count / (loadCount.values.reduce((a, b) => a > b ? a : b).clamp(1, 9999));

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFFEDF1F9),
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'S',
                              style: const TextStyle(
                                color: Color(0xFF14375E),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '$count group${count == 1 ? '' : 's'} assigned',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7A99),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: count > 3
                                  ? const Color(0xFFFEF3C7)
                                  : const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              count > 3 ? 'High load' : 'Normal',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: count > 3
                                    ? const Color(0xFFD97706)
                                    : const Color(0xFF16A34A),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFEDF1F9),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            count > 3
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFF14375E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
