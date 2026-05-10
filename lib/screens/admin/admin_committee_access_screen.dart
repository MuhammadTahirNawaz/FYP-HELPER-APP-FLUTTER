import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AdminCommitteeAccessScreen extends StatelessWidget {
  const AdminCommitteeAccessScreen({super.key});

  static const String routeName = '/admin-committee-access';

  @override
  Widget build(BuildContext context) {
    final usersRef = FirebaseDatabase.instance.ref('users');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Committee Access'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: usersRef.orderByChild('role').equalTo('Committee').onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data?.snapshot.value;

          // Fallback: also query Pending with requestedRole=Committee
          return StreamBuilder<DatabaseEvent>(
            stream: usersRef.onValue,
            builder: (context, allSnap) {
              if (allSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final allData = allSnap.data?.snapshot.value;
              if (allData is! Map) {
                return const Center(child: Text('No committee members found.'));
              }

              final all = Map<String, dynamic>.from(allData);
              final committee = all.entries.where((e) {
                if (e.value is! Map) return false;
                final u = Map<String, dynamic>.from(e.value as Map);
                final role = (u['role'] as String?) ?? '';
                final requested = (u['requestedRole'] as String?) ?? '';
                return role == 'Committee' ||
                    (role == 'Pending' && requested == 'Committee');
              }).toList();

              if (committee.isEmpty) {
                return const Center(
                    child: Text('No committee accounts registered.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: committee.length,
                itemBuilder: (context, index) {
                  final uid = committee[index].key;
                  final user =
                      Map<String, dynamic>.from(committee[index].value as Map);
                  final name = (user['displayName'] as String?) ??
                      (user['email'] as String?) ??
                      uid;
                  final role = (user['role'] as String?) ?? '';
                  final status = (user['status'] as String?) ?? 'Active';
                  final isPending = role == 'Pending';

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFEDF1F9),
                        child: const Icon(Icons.group_work,
                            color: Color(0xFF14375E)),
                      ),
                      title: Text(name,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(isPending ? 'Pending Approval' : status,
                          style: TextStyle(
                            fontSize: 12,
                            color: isPending
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFF16A34A),
                            fontWeight: FontWeight.w600,
                          )),
                      trailing: isPending
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Color(0xFFDC2626)),
                                  onPressed: () async {
                                    await usersRef.child(uid).update({
                                      'role': 'Rejected',
                                      'status': 'Rejected',
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.check,
                                      color: Color(0xFF16A34A)),
                                  onPressed: () async {
                                    await usersRef.child(uid).update({
                                      'role': 'Committee',
                                      'status': 'Active',
                                    });
                                  },
                                ),
                              ],
                            )
                          : TextButton(
                              style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFFDC2626)),
                              onPressed: () async {
                                await usersRef.child(uid).update({
                                  'status': 'Deactivated',
                                });
                              },
                              child: const Text('Revoke'),
                            ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
