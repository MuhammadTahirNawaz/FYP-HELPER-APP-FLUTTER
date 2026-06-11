import 'package:file_selector/file_selector.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/validators.dart';
import '../../../services/cloudinary_service.dart';
import '../../../theme/app_colors.dart';

class StudentUploadDocumentsSection extends StatefulWidget {
  const StudentUploadDocumentsSection({
    super.key,
    required this.studentRef,
    required this.currentUid,
    required this.groupsRef,
    this.groupId,
  });

  final DatabaseReference studentRef;
  final String currentUid;
  final DatabaseReference groupsRef;
  final String? groupId;

  @override
  State<StudentUploadDocumentsSection> createState() =>
      _StudentUploadDocumentsSectionState();
}

class _StudentUploadDocumentsSectionState
    extends State<StudentUploadDocumentsSection> {
  bool _uploading = false;
  double _uploadProgress = 0;
  String _uploadLabel = '';

  Future<void> _pickAndUploadFile() async {
    try {
      final file = await openFile();
      if (file == null) return;

      final titleController = TextEditingController(text: file.name);
      final descriptionController = TextEditingController();

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          final dialogFormKey = GlobalKey<FormState>();
          bool isUploading = false;
          double dialogProgress = 0;
          String? dialogError;

          Future<void> startUpload(StateSetter setDialogState) async {
            if (!(dialogFormKey.currentState?.validate() ?? false)) {
              return;
            }
            final title = titleController.text.trim();

            setDialogState(() {
              isUploading = true;
              dialogError = null;
            });

            final success = await _uploadFile(
              file,
              title,
              descriptionController.text.trim(),
              onProgress: (progress) {
                if (!mounted) return;
                setDialogState(() {
                  dialogProgress = progress;
                });
              },
            );

            if (!mounted) {
              return;
            }

            if (success) {
              Navigator.of(dialogContext).pop();
            } else {
              setDialogState(() {
                isUploading = false;
                dialogProgress = 0;
              });
            }
          }

          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Upload Document'),
                content: SingleChildScrollView(
                  child: Form(
                    key: dialogFormKey,
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: titleController,
                        enabled: !isUploading,
                        validator: AppValidators.projectTitle,
                        decoration: const InputDecoration(labelText: 'Title'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descriptionController,
                        enabled: !isUploading,
                        validator: AppValidators.description,
                        decoration: const InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      Text('File: ${file.name}'),
                      const SizedBox(height: 16),
                      if (isUploading) ...[
                        LinearProgressIndicator(value: dialogProgress.toDouble()),
                        const SizedBox(height: 8),
                        Text(
                          'Uploading... ${(dialogProgress * 100).toStringAsFixed(0)}%',
                        ),
                      ],
                      if (dialogError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          dialogError!,
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      ],
                    ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: isUploading ? null : () => Navigator.pop(dialogContext),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: isUploading ? null : () => startUpload(setDialogState),
                    child: Text(isUploading ? 'Uploading' : 'Upload'),
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<bool> _uploadFile(
    XFile file,
    String title,
    String description, {
    required ValueChanged<double> onProgress,
  }) async {
    try {
      setState(() {
        _uploading = true;
        _uploadLabel = file.name;
        _uploadProgress = 0;
      });

      final bytes = await file.readAsBytes();
      final docId = widget.studentRef.child('documents').push().key;
      if (docId == null) throw Exception('Failed to generate document ID');

      final downloadUrl = await CloudinaryService.uploadFile(
        fileBytes: bytes,
        fileName: file.name,
        folder: 'student_documents/${widget.currentUid}/$docId',
        onProgress: (progress) {
          onProgress(progress);
          if (mounted) {
            setState(() {
              _uploadProgress = progress;
            });
          }
        },
      );

      if (downloadUrl == null) {
        throw Exception('Failed to get download URL from Cloudinary');
      }

      await widget.studentRef.child('documents').child(docId).set({
        'title': title,
        'description': description,
        'fileName': file.name,
        'fileSize': bytes.length,
        'downloadUrl': downloadUrl,
        'uploadedAt': DateTime.now().toIso8601String(),
        'uploadedBy': FirebaseAuth.instance.currentUser?.email ?? '',
      });

      if (widget.groupId != null) {
        await widget.groupsRef.child(widget.groupId!).child('documents').child(docId).set({
          'title': title,
          'description': description,
          'fileName': file.name,
          'downloadUrl': downloadUrl,
          'type': 'Group Doc',
          'uploadedAt': DateTime.now().toIso8601String(),
          'uploadedBy': FirebaseAuth.instance.currentUser?.email ?? '',
        });
      }

      if (mounted) {
        setState(() => _uploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document uploaded successfully')),
        );
      }
      return true;
    } catch (e) {
      if (mounted) {
        setState(() => _uploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload error: $e')),
        );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Upload Documents',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: AppColors.studentTeal,
                ),
          ),
          const SizedBox(height: 20),
          if (_uploading) ...[
            Text(
              'Uploading $_uploadLabel',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.studentTeal,
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _uploadProgress.toDouble(),
                minHeight: 8,
                backgroundColor: AppColors.borderSoft,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(_uploadProgress * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),
          ],
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.borderSoft),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.cloud_upload,
                      size: 48,
                      color: Color(0xFF38BDF8),
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Choose Document'),
                    onPressed: _uploading ? null : _pickAndUploadFile,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your Documents',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.studentTeal,
                ),
          ),
          const SizedBox(height: 12),
          StreamBuilder<DatabaseEvent>(
            stream: widget.studentRef.child('documents').onValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.data?.snapshot.value;
              if (data == null) {
                return const Center(child: Text('No documents uploaded yet'));
              }

              if (data is! Map) {
                return const Center(child: Text('No documents uploaded yet'));
              }

              final docs = data.entries.toList();
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = Map<String, dynamic>.from(docs[index].value as Map);
                  final title = doc['title'] ?? 'Untitled';
                  final fileName = doc['fileName'] ?? 'File';

                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.borderSoft),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFEEF2FF),
                        child: Icon(Icons.description, color: Color(0xFF38BDF8)),
                      ),
                      title: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.studentTeal,
                        ),
                      ),
                      subtitle: Text(
                        fileName,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.open_in_new, color: Color(0xFF38BDF8)),
                        onPressed: () async {
                          final downloadUrl = doc['downloadUrl'];
                          if (downloadUrl != null) {
                            final uri = Uri.parse(downloadUrl);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            } else {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Could not open document'),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
