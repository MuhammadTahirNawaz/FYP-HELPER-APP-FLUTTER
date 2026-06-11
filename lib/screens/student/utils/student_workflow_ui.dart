import 'package:flutter/material.dart';

import '../../../core/student_workflow_gate.dart';
import '../../../widgets/app_feedback.dart';

Future<void> showWorkflowBlockedDialog(
  BuildContext context,
  WorkflowGateResult gate,
) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Complete these steps first'),
      content: Text(gate.message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

class StudentWorkflowGateBanner extends StatelessWidget {
  const StudentWorkflowGateBanner({super.key, required this.gate});

  final WorkflowGateResult gate;

  @override
  Widget build(BuildContext context) {
    if (gate.allowed) return const SizedBox.shrink();
    return FeedbackBanner(
      message: gate.message,
      kind: FeedbackKind.info,
    );
  }
}
