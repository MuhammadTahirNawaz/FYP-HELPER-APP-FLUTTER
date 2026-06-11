import 'package:file_selector/file_selector.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/student_workflow_gate.dart';
import '../../../core/validators.dart';
import '../../../services/cloudinary_service.dart';
import '../../../services/student_workflow_service.dart';
import '../../../theme/app_colors.dart';
import '../utils/student_workflow_ui.dart';
import '../widgets/student_dashboard_banner.dart';

class StudentSubmitProposalSection extends StatefulWidget {
  const StudentSubmitProposalSection({
    super.key,
    required this.groupsRef,
    required this.currentUid,
    this.groupId,
  });

  final DatabaseReference groupsRef;
  final String currentUid;
  final String? groupId;

  @override
  State<StudentSubmitProposalSection> createState() =>
      _StudentSubmitProposalSectionState();
}

class _StudentSubmitProposalSectionState
    extends State<StudentSubmitProposalSection> {
  final _formKey = GlobalKey<FormState>();
  bool _uploading = false;
  double _progress = 0;
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late Future<WorkflowGateResult> _gateFuture;
  String? _gateKey;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _gateFuture = Future.value(
      const WorkflowGateResult(allowed: false, message: 'Checking requirements...'),
    );
    _loadExistingData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final key = '${widget.currentUid}:${widget.groupId}';
    if (_gateKey == key) return;
    _gateKey = key;
    _gateFuture = context
        .read<StudentWorkflowService>()
        .evaluateProposalGate(widget.currentUid, widget.groupId);
  }

  @override
  void didUpdateWidget(covariant StudentSubmitProposalSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.groupId != widget.groupId ||
        oldWidget.currentUid != widget.currentUid) {
      _gateKey = null;
    }
  }

  Future<void> _loadExistingData() async {
    if (widget.groupId == null) return;
    final snap = await widget.groupsRef.child(widget.groupId!).get();
    if (snap.exists && snap.value is Map) {
      final data = Map<String, dynamic>.from(snap.value as Map);
      if (mounted) {
        setState(() {
          _titleController.text = data['projectTitle'] ?? '';
          _descController.text = data['description'] ?? '';
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _uploadProposal(WorkflowGateResult gate) async {
    if (!gate.allowed) {
      await showWorkflowBlockedDialog(context, gate);
      return;
    }
    if (widget.groupId == null) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final typeGroup = XTypeGroup(label: 'PDFs', extensions: ['pdf']);
    final file = await openFile(acceptedTypeGroups: [typeGroup]);

    if (file == null) return;

    setState(() {
      _uploading = true;
      _progress = 0;
    });

    try {
      final bytes = await file.readAsBytes();
      final url = await CloudinaryService.uploadFile(
        fileBytes: bytes,
        fileName: file.name,
        folder: 'proposals/${widget.groupId}',
        onProgress: (p) => setState(() => _progress = p),
      );

      if (url != null) {
        await context.read<StudentWorkflowService>().submitProposal(
              uid: widget.currentUid,
              groupId: widget.groupId!,
              projectTitle: _titleController.text.trim(),
              description: _descController.text.trim(),
              proposalUrl: url,
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Proposal submitted successfully!')),
          );
        }
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
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WorkflowGateResult>(
      future: _gateFuture,
      builder: (context, gateSnapshot) {
        final gate = gateSnapshot.data ??
            const WorkflowGateResult(allowed: false, message: 'Checking requirements...');

        if (widget.groupId == null) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const StudentDashboardBanner(
                  title: 'FYP Proposal',
                  subtitle: 'Submit your project proposal when your group is ready.',
                  icon: Icons.assignment_turned_in,
                ),
                const SizedBox(height: 24),
                StudentWorkflowGateBanner(gate: gate),
              ],
            ),
          );
        }

        return StreamBuilder(
          stream: widget.groupsRef.child(widget.groupId!).onValue,
          builder: (context, snapshot) {
            final groupData = snapshot.data?.snapshot.value is Map
                ? Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map)
                : {};
            final proposalUrl = groupData['proposalUrl'];
            final status = groupData['proposalStatus'] ?? 'Not Submitted';
            final canSubmit = gate.allowed && !_uploading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StudentDashboardBanner(
                    title: 'FYP Proposal',
                    subtitle: 'Current Status: $status',
                    icon: Icons.assignment_turned_in,
                  ),
                  const SizedBox(height: 24),
                  if (!gate.allowed) ...[
                    StudentWorkflowGateBanner(gate: gate),
                    const SizedBox(height: 16),
                  ],
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.borderSoft),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Proposal Details',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _titleController,
                              validator: AppValidators.projectTitle,
                              enabled: gate.allowed,
                              decoration: const InputDecoration(
                                labelText: 'Project Title',
                                hintText: 'Enter your project title',
                                prefixIcon: Icon(Icons.title),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _descController,
                              validator: (v) => AppValidators.description(
                                v,
                                fieldName: 'Project summary',
                              ),
                              maxLines: 3,
                              enabled: gate.allowed,
                              decoration: const InputDecoration(
                                labelText: 'Project Summary',
                                hintText: 'Briefly describe your project',
                                prefixIcon: Icon(Icons.description),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Divider(),
                            const SizedBox(height: 16),
                            const Center(
                              child: Icon(
                                Icons.picture_as_pdf,
                                size: 48,
                                color: Color(0xFF38BDF8),
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (proposalUrl != null)
                              const Center(
                                child: Text(
                                  'Current Document: Submitted',
                                  style: TextStyle(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 20),
                            if (_uploading)
                              Column(
                                children: [
                                  LinearProgressIndicator(value: _progress),
                                  const SizedBox(height: 8),
                                  Text('${(_progress * 100).toInt()}% uploaded'),
                                ],
                              )
                            else
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: canSubmit
                                      ? () => _uploadProposal(gate)
                                      : () => showWorkflowBlockedDialog(context, gate),
                                  icon: const Icon(Icons.cloud_upload),
                                  label: Text(
                                    proposalUrl == null
                                        ? 'Submit Proposal (PDF)'
                                        : 'Update & Resubmit',
                                  ),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.studentTeal,
                                    disabledBackgroundColor:
                                        AppColors.surfaceMuted,
                                    foregroundColor: Colors.white,
                                    disabledForegroundColor:
                                        AppColors.textSecondary,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
