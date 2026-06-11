import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/student_workflow_gate.dart';
import '../../../core/validators.dart';
import '../../../services/student_workflow_service.dart';
import '../../../theme/app_colors.dart';
import '../utils/student_deadline_utils.dart';
import '../utils/student_workflow_ui.dart';
import '../widgets/student_dashboard_banner.dart';

class StudentMeetingRequestsSection extends StatefulWidget {
  const StudentMeetingRequestsSection({
    super.key,
    required this.groupsRef,
    required this.currentUid,
    this.groupId,
  });

  final DatabaseReference groupsRef;
  final String currentUid;
  final String? groupId;

  @override
  State<StudentMeetingRequestsSection> createState() =>
      _StudentMeetingRequestsSectionState();
}

class _StudentMeetingRequestsSectionState
    extends State<StudentMeetingRequestsSection> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  String _selectedDuration = '15 min';
  late Future<WorkflowGateResult> _gateFuture;
  String? _gateKey;

  final List<String> _durations = ['5 min', '10 min', '15 min', '30 min', '60 min'];

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
    _timeController = TextEditingController();
    _gateFuture = Future.value(
      const WorkflowGateResult(allowed: false, message: 'Checking requirements...'),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final key = '${widget.currentUid}:${widget.groupId}';
    if (_gateKey == key) return;
    _gateKey = key;
    _gateFuture = context
        .read<StudentWorkflowService>()
        .evaluateMeetingGate(widget.currentUid, widget.groupId);
  }

  @override
  void didUpdateWidget(covariant StudentMeetingRequestsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.groupId != widget.groupId ||
        oldWidget.currentUid != widget.currentUid) {
      _gateKey = null;
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _requestMeeting(WorkflowGateResult gate) async {
    if (!gate.allowed) {
      await showWorkflowBlockedDialog(context, gate);
      return;
    }
    if (widget.groupId == null) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    try {
      await context.read<StudentWorkflowService>().requestMeeting(
            uid: widget.currentUid,
            groupId: widget.groupId!,
            requestedDate: _dateController.text,
            requestedTime: _timeController.text,
            duration: _selectedDuration,
          );
      _dateController.clear();
      _timeController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meeting request sent!')),
        );
      }
    } on WorkflowGateException catch (e) {
      if (mounted) {
        await showWorkflowBlockedDialog(
          context,
          WorkflowGateResult(allowed: false, message: e.message),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not send meeting request: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WorkflowGateResult>(
      future: _gateFuture,
      builder: (context, gateSnapshot) {
        final gate = gateSnapshot.data ??
            const WorkflowGateResult(allowed: false, message: 'Checking requirements...');
        final canRequest = gate.allowed;

        if (widget.groupId == null) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const StudentDashboardBanner(
                  title: 'Schedule Meeting',
                  subtitle: 'Request an online video session with your supervisor.',
                  icon: Icons.video_call,
                ),
                const SizedBox(height: 24),
                StudentWorkflowGateBanner(gate: gate),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const StudentDashboardBanner(
                title: 'Schedule Meeting',
                subtitle: 'Request an online video session with your supervisor.',
                icon: Icons.video_call,
              ),
              const SizedBox(height: 24),
              if (!gate.allowed) ...[
                StudentWorkflowGateBanner(gate: gate),
                const SizedBox(height: 16),
              ],
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _dateController,
                      validator: (v) => AppValidators.required(v, fieldName: 'Date'),
                      enabled: canRequest,
                      decoration: InputDecoration(
                        labelText: 'Select Date',
                        hintText: 'YYYY-MM-DD',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: canRequest
                          ? () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 30)),
                              );
                              if (date != null) {
                                _dateController.text = date.toString().split(' ')[0];
                              }
                            }
                          : () => showWorkflowBlockedDialog(context, gate),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _timeController,
                      validator: (v) => AppValidators.required(v, fieldName: 'Time'),
                      enabled: canRequest,
                      decoration: InputDecoration(
                        labelText: 'Select Time',
                        hintText: 'HH:MM',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.access_time),
                      ),
                      readOnly: true,
                      onTap: canRequest
                          ? () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (time != null) {
                                _timeController.text = time.format(context);
                              }
                            }
                          : () => showWorkflowBlockedDialog(context, gate),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedDuration,
                decoration: InputDecoration(
                  labelText: 'Duration',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.timer_outlined),
                ),
                items: _durations
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: canRequest
                    ? (val) {
                        if (val != null) setState(() => _selectedDuration = val);
                      }
                    : null,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: canRequest
                    ? () => _requestMeeting(gate)
                    : () => showWorkflowBlockedDialog(context, gate),
                icon: const Icon(Icons.send),
                label: const Text('Request Meeting'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.studentTeal,
                  disabledBackgroundColor: AppColors.surfaceMuted,
                  disabledForegroundColor: AppColors.textSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Your Meeting Requests',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              StreamBuilder(
                stream: widget.groupsRef.child(widget.groupId!).child('meetings').onValue,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('No meeting requests yet.'),
                      ),
                    );
                  }
                  final meetings = Map<String, dynamic>.from(
                    snapshot.data!.snapshot.value as Map,
                  );
                  final sortedMeetings = meetings.entries.toList()
                    ..sort(
                      (a, b) => (b.value['timestamp'] as String).compareTo(
                        a.value['timestamp'] as String,
                      ),
                    );

                  return Column(
                    children: sortedMeetings.map((entry) {
                      final m = entry.value as Map;
                      final status = m['status'] ?? 'Pending';
                      final isApproved = status == 'Approved';

                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: isApproved
                                ? Colors.green.withValues(alpha: 0.3)
                                : AppColors.borderSoft,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isApproved
                                      ? Colors.green[50]
                                      : AppColors.selectedTile,
                                  child: Icon(
                                    Icons.video_call,
                                    color: isApproved ? Colors.green : AppColors.studentTeal,
                                  ),
                                ),
                                title: Text(
                                  '${m['requestedDate']} at ${m['requestedTime'] ?? 'N/A'}',
                                ),
                                subtitle: Text('Duration: ${m['duration'] ?? 'N/A'}'),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isApproved
                                        ? Colors.green[100]
                                        : (status == 'Rejected'
                                            ? Colors.red[50]
                                            : Colors.orange[50]),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isApproved
                                          ? Colors.green[700]
                                          : (status == 'Rejected'
                                              ? Colors.red[700]
                                              : Colors.orange[700]),
                                    ),
                                  ),
                                ),
                              ),
                              if (isApproved) ...[
                                const Divider(height: 24),
                                if (isStudentDeadlinePassed(
                                  m['requestedDate'],
                                  m['requestedTime'],
                                ))
                                  const Text(
                                    'Meeting link expired.',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                else
                                  FilledButton.icon(
                                    onPressed: () async {
                                      final url = Uri.parse(
                                        m['meetingLink'] ?? 'https://meet.google.com/new',
                                      );
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(url);
                                      }
                                    },
                                    icon: const Icon(Icons.play_arrow, size: 18),
                                    label: const Text('Join Video Meeting'),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.green[700],
                                      minimumSize: const Size(double.infinity, 40),
                                    ),
                                  ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
