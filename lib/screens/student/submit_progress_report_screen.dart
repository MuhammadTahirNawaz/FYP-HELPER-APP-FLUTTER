import 'package:flutter/material.dart';

class SubmitProgressReportScreen extends StatelessWidget {
  const SubmitProgressReportScreen({super.key});

  static const String routeName = '/student-submit-progress';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Progress Report'),
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
                    'Progress Update',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Week Range',
                      hintText: 'e.g., Week 3-4',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Summary',
                      hintText: 'Describe your progress',
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () {},
                    child: const Text('Submit Report'),
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
