import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'admin_nav_bar.dart';
import 'admin_dashboard_screen.dart';

class AdminGroupRecordsScreen extends StatefulWidget {
  const AdminGroupRecordsScreen({super.key});

  static const String routeName = '/admin-group-records';

  @override
  State<AdminGroupRecordsScreen> createState() => _AdminGroupRecordsScreenState();
}

class _AdminGroupRecordsScreenState extends State<AdminGroupRecordsScreen> {
  final DatabaseReference _groupsRef = FirebaseDatabase.instance.ref('groups');
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref('users');

  bool _isGenerating = false;

  Future<void> _generatePdf(List<_GroupRecord> records) async {
    setState(() => _isGenerating = true);
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('FYP Group Records Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.Text(DateTime.now().toString().split('.')[0]),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headers: ['Group Code', 'Project Title', 'Supervisor', 'Members (Name - ID)'],
                data: records.map((r) => [
                  r.code,
                  r.projectTitle,
                  r.supervisorName,
                  r.memberDetails.join('\n'),
                ]).toList(),
              ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'FYP_Group_Records_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate PDF: $e')));
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pushReplacementNamed(AdminDashboardScreen.routeName);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Group Records'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pushReplacementNamed(AdminDashboardScreen.routeName),
          ),
        ),
        body: StreamBuilder<DatabaseEvent>(
          stream: _groupsRef.onValue,
          builder: (context, groupSnap) {
            if (groupSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final groupData = groupSnap.data?.snapshot.value as Map?;
            if (groupData == null) return const Center(child: Text('No groups found.'));

            return FutureBuilder<DataSnapshot>(
              future: _usersRef.get(),
              builder: (context, userSnap) {
                if (userSnap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final userData = userSnap.data?.value as Map?;
                final records = <_GroupRecord>[];

                groupData.forEach((code, data) {
                  if (data is Map) {
                    final supervisorId = data['supervisorId'] as String?;
                    String supervisorName = 'Not Assigned';
                    if (supervisorId != null && userData != null && userData[supervisorId] != null) {
                      supervisorName = (userData[supervisorId] as Map)['fullName'] ?? 'Unknown';
                    }

                    final membersMap = data['members'] as Map?;
                    final memberDetails = <String>[];
                    if (membersMap != null && userData != null) {
                      membersMap.forEach((uid, _) {
                        if (userData[uid] != null) {
                          final mData = userData[uid] as Map;
                          final name = mData['fullName'] ?? 'Unknown';
                          final id = mData['studentId'] ?? 'No ID';
                          memberDetails.add('$name ($id)');
                        }
                      });
                    }

                    records.add(_GroupRecord(
                      code: code.toString(),
                      projectTitle: data['projectTitle'] ?? 'No Title',
                      supervisorName: supervisorName,
                      memberDetails: memberDetails,
                    ));
                  }
                });

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _isGenerating ? null : () => _generatePdf(records),
                          icon: _isGenerating ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.picture_as_pdf),
                          label: const Text('Export to PDF'),
                          style: FilledButton.styleFrom(backgroundColor: AppColors.navy, padding: const EdgeInsets.symmetric(vertical: 16)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: records.length,
                        itemBuilder: (context, index) {
                          final r = records[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('Code: ${r.code}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy)),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                                        child: Text(r.supervisorName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(r.projectTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navy)),
                                  const Divider(height: 24),
                                  const Text('Members:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                                  const SizedBox(height: 4),
                                  ...r.memberDetails.map((m) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.person, size: 14, color: AppColors.navy),
                                        const SizedBox(width: 8),
                                        Text(m, style: const TextStyle(fontSize: 13)),
                                      ],
                                    ),
                                  )),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
        bottomNavigationBar: const AdminNavBar(selectedIndex: 2),
      ),
    );
  }
}

class _GroupRecord {
  final String code;
  final String projectTitle;
  final String supervisorName;
  final List<String> memberDetails;

  _GroupRecord({
    required this.code,
    required this.projectTitle,
    required this.supervisorName,
    required this.memberDetails,
  });
}
