import 'package:flutter/material.dart';

class SubmitProposalScreen extends StatelessWidget {
  const SubmitProposalScreen({super.key});

  static const String routeName = '/student-submit-proposal';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Proposal'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFE6E6E6)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Proposal Details',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Project Title',
                      hintText: 'Enter proposal title',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Summary',
                      hintText: 'Describe your project idea',
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () {},
                    child: const Text('Submit Proposal'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
