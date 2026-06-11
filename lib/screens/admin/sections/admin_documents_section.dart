import 'package:file_selector/file_selector.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../../core/validators.dart';
import '../../../models/admin_document.dart';
import '../../../services/cloudinary_service.dart';
import '../utils/admin_format_utils.dart';

class AdminDocumentsSection extends StatefulWidget {
  const AdminDocumentsSection({
    super.key,
    required this.documentsRef,
    this.university,
  });

  final DatabaseReference documentsRef;
  final String? university;

  @override
  State<AdminDocumentsSection> createState() => _AdminDocumentsSectionState();
}

class _AdminDocumentsSectionState extends State<AdminDocumentsSection> {
  bool _uploading = false;
  double _uploadProgress = 0;
  String _uploadLabel = '';

  Future<void> _showDocumentEditor(
    BuildContext context, {
    AdminDocument? existing,
  }) async {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final descriptionController =
        TextEditingController(text: existing?.description ?? '');
    final roles = <String>['Admin', 'Supervisor', 'Committee', 'Student'];
    final selectedRoles = <String>{
      ...?existing?.roles,
      if (existing == null) ...roles,
    };
    XFile? selectedFile;
    var saving = false;
    final dialogFormKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(existing == null ? 'Upload Document' : 'Edit Document'),
              content: SingleChildScrollView(
                child: Form(
                  key: dialogFormKey,
                  child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleController,
                      validator: AppValidators.projectTitle,
                      style: const TextStyle(fontWeight: FontWeight.normal),
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descriptionController,
                      validator: AppValidators.description,
                      style: const TextStyle(fontWeight: FontWeight.normal),
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Access Roles',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: roles
                          .map(
                            (role) => FilterChip(
                              label: Text(role),
                              selected: selectedRoles.contains(role),
                              onSelected: (selected) {
                                setDialogState(() {
                                  if (selected) {
                                    selectedRoles.add(role);
                                  } else {
                                    selectedRoles.remove(role);
                                  }
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    if (existing != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('File: ${existing.fileName}'),
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: () async {
                          final file = await openFile();
                          if (file == null) return;
                          setDialogState(() => selectedFile = file);
                        },
                        icon: const Icon(Icons.attach_file),
                        label: Text(
                          selectedFile == null ? 'Pick file' : selectedFile!.name,
                        ),
                      ),
                  ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: saving
                      ? null
                      : () async {
                          if (!(dialogFormKey.currentState?.validate() ?? false)) return;
                          final title = titleController.text.trim();
                          if (existing == null && selectedFile == null) return;

                          setDialogState(() => saving = true);
                          try {
                            final rolesMap = {
                              for (final role in selectedRoles) role: true,
                            };
                            final rootRef = FirebaseDatabase.instance.ref();
                            if (existing == null) {
                              final docId = widget.documentsRef.push().key;
                              if (docId == null) return;

                              final file = selectedFile!;
                              final storagePath = 'documents/$docId/${file.name}';
                              final bytes = await file.readAsBytes();

                              final downloadUrl = await CloudinaryService.uploadFile(
                                fileBytes: bytes,
                                fileName: file.name,
                                folder: 'documents/$docId',
                                onProgress: (progress) {
                                  if (!mounted) return;
                                  setState(() {
                                    _uploading = true;
                                    _uploadLabel = file.name;
                                    _uploadProgress = progress;
                                  });
                                },
                              );

                              if (downloadUrl == null) {
                                throw Exception('Failed to upload to Cloudinary');
                              }

                              final sizeBytes = await file.length();
                              final uploaderEmail =
                                  FirebaseAuth.instance.currentUser?.email ?? '';
                              final payload = <String, Object?>{
                                'title': title,
                                'description': descriptionController.text.trim(),
                                'fileName': file.name,
                                'fileUrl': downloadUrl,
                                'storagePath': storagePath,
                                'sizeBytes': sizeBytes,
                                'roles': rolesMap,
                                'uploadedBy': uploaderEmail,
                                'createdAt': ServerValue.timestamp,
                                'updatedAt': ServerValue.timestamp,
                                'university': widget.university,
                              };
                              final uniPath = widget.university ?? 'default';
                              final updates = <String, Object?>{
                                'admin/universities/$uniPath/documents/$docId': payload,
                              };
                              for (final role in selectedRoles) {
                                updates[
                                    'admin/universities/$uniPath/documents_by_role/$role/$docId'] = payload;
                              }
                              await rootRef.update(updates);
                              if (mounted) {
                                setState(() {
                                  _uploading = false;
                                  _uploadProgress = 0;
                                  _uploadLabel = '';
                                });
                              }
                            } else {
                              final payload = <String, Object?>{
                                'title': title,
                                'description': descriptionController.text.trim(),
                                'fileName': existing.fileName,
                                'fileUrl': existing.fileUrl,
                                'storagePath': existing.storagePath,
                                'sizeBytes': existing.sizeBytes,
                                'roles': rolesMap,
                                'uploadedBy': existing.uploadedBy,
                                'createdAt':
                                    existing.createdAt ?? ServerValue.timestamp,
                                'updatedAt': ServerValue.timestamp,
                                'university': widget.university,
                              };
                              final uniPath = widget.university ?? 'default';
                              final updates = <String, Object?>{
                                'admin/universities/$uniPath/documents/${existing.id}':
                                    payload,
                              };
                              final existingRoles = existing.roles.toSet();
                              for (final role in existingRoles) {
                                if (!selectedRoles.contains(role)) {
                                  updates[
                                      'admin/universities/$uniPath/documents_by_role/$role/${existing.id}'] = null;
                                }
                              }
                              for (final role in selectedRoles) {
                                updates[
                                    'admin/universities/$uniPath/documents_by_role/$role/${existing.id}'] = payload;
                              }
                              await rootRef.update(updates);
                            }
                            if (mounted) {
                              Navigator.of(dialogContext).pop();
                            }
                          } catch (error) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Upload failed: $error')),
                              );
                              setState(() {
                                _uploading = false;
                                _uploadProgress = 0;
                                _uploadLabel = '';
                              });
                            }
                          } finally {
                            if (mounted) {
                              setDialogState(() => saving = false);
                            }
                          }
                        },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteDocument(AdminDocument doc) async {
    final rootRef = FirebaseDatabase.instance.ref();
    final uniPath = widget.university ?? 'default';
    final updates = <String, Object?>{
      'admin/universities/$uniPath/documents/${doc.id}': null,
    };
    for (final role in doc.roles) {
      updates['admin/universities/$uniPath/documents_by_role/$role/${doc.id}'] =
          null;
    }
    await rootRef.update(updates);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: widget.documentsRef.onValue,
      builder: (context, snapshot) {
        final documents = AdminDocument.listFromSnapshot(
          snapshot.data?.snapshot.value,
        )..sort(
            (a, b) => adminTimestampToInt(b.createdAt)
                .compareTo(adminTimestampToInt(a.createdAt)),
          );

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Documents', style: Theme.of(context).textTheme.titleMedium),
                FilledButton.icon(
                  onPressed: () => _showDocumentEditor(context),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload'),
                ),
              ],
            ),
            if (_uploading) ...[
              const SizedBox(height: 12),
              Text('Uploading $_uploadLabel'),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: _uploadProgress),
            ],
            const SizedBox(height: 12),
            if (documents.isEmpty)
              const Center(child: Text('No documents yet.'))
            else
              ...documents.map(
                (doc) => Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE6E6E6)),
                  ),
                  child: ListTile(
                    title: Text(doc.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          doc.description.isEmpty
                              ? 'No description'
                              : doc.description,
                        ),
                        const SizedBox(height: 6),
                        Text('File: ${doc.fileName}'),
                        Text('Size: ${formatAdminBytes(doc.sizeBytes)}'),
                        if (doc.roles.isNotEmpty)
                          Text('Roles: ${doc.roles.join(', ')}'),
                        if (doc.createdAt != null)
                          Text(
                            'Uploaded: ${formatAdminTimestamp(doc.createdAt)}',
                          ),
                      ],
                    ),
                    trailing: Wrap(
                      spacing: 4,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.open_in_new),
                          tooltip: 'Open',
                          onPressed: doc.fileUrl.isEmpty
                              ? null
                              : () => openAdminDocumentUrl(doc.fileUrl),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: 'Edit',
                          onPressed: () =>
                              _showDocumentEditor(context, existing: doc),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Delete',
                          onPressed: () => _deleteDocument(doc),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
