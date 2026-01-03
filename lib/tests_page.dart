import 'dart:async';

import 'package:flutter/material.dart';

class TestsPage extends StatefulWidget {
  const TestsPage({super.key});

  @override
  State<TestsPage> createState() => _TestsPageState();
}

class _TestsPageState extends State<TestsPage> {
  final List<_SecurityTest> _tests = [
    const _SecurityTest(
      title: 'Password Strength Check',
      description:
          'Review your password policy and verify that strong, unique passwords are used for critical accounts.',
      guidance:
          'Ensure passwords contain at least 12 characters, include numbers and symbols, and avoid reuse across services.',
    ),
    const _SecurityTest(
      title: 'Phishing Awareness Drill',
      description:
          'Walk through realistic phishing scenarios to improve recognition of suspicious emails or links.',
      guidance:
          'Hover over links before clicking, confirm sender identity, and report suspicious messages to your IT team.',
    ),
    const _SecurityTest(
      title: 'Device Hardening Review',
      description:
          'Confirm that OS patches, firewall rules, and antivirus signatures are up to date on all devices.',
      guidance:
          'Schedule automatic updates, disable unused services, and enforce full-disk encryption where available.',
    ),
    const _SecurityTest(
      title: 'Backup and Recovery Test',
      description:
          'Validate that recent backups exist and ensure you can restore critical files on short notice.',
      guidance:
          'Document recovery steps, test them quarterly, and store backups in at least two separate locations.',
    ),
  ];

  final Map<String, _TestStatus> _statusByTest = {};
  final Map<String, Timer> _activeTimers = {};

  @override
  void dispose() {
    for (final timer in _activeTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Tests'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemBuilder: (context, index) {
          final test = _tests[index];
          final status = _statusByTest[test.title] ?? _TestStatus.idle;
          return _TestCard(
            test: test,
            status: status,
            onRun: () => _runTest(test),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemCount: _tests.length,
      ),
    );
  }

  void _runTest(_SecurityTest test) {
    if (_statusByTest[test.title] == _TestStatus.running) {
      return;
    }

    setState(() {
      _statusByTest[test.title] = _TestStatus.running;
    });

    final timer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _statusByTest[test.title] = _TestStatus.completed;
      });

      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('${test.title} Complete'),
          content: Text(test.guidance),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it'),
            ),
          ],
        ),
      );
    });

    _activeTimers[test.title]?.cancel();
    _activeTimers[test.title] = timer;
  }
}

enum _TestStatus { idle, running, completed }

class _SecurityTest {
  const _SecurityTest({
    required this.title,
    required this.description,
    required this.guidance,
  });

  final String title;
  final String description;
  final String guidance;
}

class _TestCard extends StatelessWidget {
  const _TestCard({
    required this.test,
    required this.status,
    required this.onRun,
  });

  final _SecurityTest test;
  final _TestStatus status;
  final VoidCallback onRun;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.task_alt, color: colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    test.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _StatusChip(status: status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              test.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: status == _TestStatus.running ? null : onRun,
                icon: status == _TestStatus.completed
                    ? const Icon(Icons.refresh)
                    : const Icon(Icons.play_arrow),
                label: Text(
                  status == _TestStatus.completed ? 'Run Again' : 'Start Test',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final _TestStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Color background;
    String text;

    switch (status) {
      case _TestStatus.running:
        background = colorScheme.primaryContainer;
        text = 'Running';
        break;
      case _TestStatus.completed:
        background = Colors.green.withOpacity(0.18);
        text = 'Complete';
        break;
      case _TestStatus.idle:
        background = colorScheme.surfaceVariant;
        text = 'Idle';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
