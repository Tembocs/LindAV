import 'dart:math';

import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isScanning = false;
  double _progress = 0;
  final List<ScanResult> _history = [];

  Future<void> _startScan(String type) async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _progress = 0;
    });

    const totalSteps = 20;
    for (var i = 1; i <= totalSteps; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      setState(() {
        _progress = i / totalSteps;
      });
    }

    final random = Random();
    final threats = random.nextInt(3); // 0, 1 or 2
    final scannedFiles = 500 + random.nextInt(1500);

    setState(() {
      _isScanning = false;
      _progress = 1;
      _history.insert(
        0,
        ScanResult(
          type: type,
          dateTime: DateTime.now(),
          scannedFiles: scannedFiles,
          threatsFound: threats,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final latest = _history.isNotEmpty ? _history.first : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lindav Security'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SecurityStatusCard(
              isScanning: _isScanning,
              latest: latest,
              progress: _progress,
            ),
            const SizedBox(height: 16),
            _ScanActions(
              onQuickScan: () => _startScan('Quick Scan'),
              onFullScan: () => _startScan('Full Scan'),
              onUsbScan: () => _startScan('USB Scan'),
              isScanning: _isScanning,
            ),
            const SizedBox(height: 24),
            Text(
              'Scan history',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _history.isEmpty
                  ? const Center(
                      child: Text('No scans yet. Tap Quick Scan to start.'),
                    )
                  : ListView.separated(
                      itemCount: _history.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = _history[index];
                        return ListTile(
                          leading: Icon(
                            item.threatsFound == 0
                                ? Icons.check_circle
                                : Icons.warning_amber_rounded,
                            color: item.threatsFound == 0
                                ? Colors.green
                                : Colors.orange,
                          ),
                          title: Text(item.type),
                          subtitle: Text(
                            '${item.scannedFiles} files • ${item.threatsFound} threats • '
                            '${_formatDateTime(item.dateTime)}',
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecurityStatusCard extends StatelessWidget {
  const _SecurityStatusCard({
    required this.isScanning,
    required this.latest,
    required this.progress,
  });

  final bool isScanning;
  final ScanResult? latest;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isClean = latest == null || latest!.threatsFound == 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isScanning
                      ? Icons.shield
                      : (isClean
                            ? Icons.verified_user
                            : Icons.shield_moon_rounded),
                  size: 32,
                  color: isScanning
                      ? colorScheme.primary
                      : (isClean ? Colors.green : Colors.orange),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isScanning
                          ? 'Scanning in progress...'
                          : (isClean
                                ? 'Your device looks protected'
                                : 'Threats detected in last scan'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      latest == null
                          ? 'No scans run yet'
                          : '${latest!.type} • ${_formatDateTime(latest!.dateTime)}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isScanning) ...[
              LinearProgressIndicator(value: progress == 0 ? null : progress),
              const SizedBox(height: 8),
              Text(
                '${(progress * 100).toStringAsFixed(0)}% complete',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ] else if (latest != null) ...[
              Text(
                latest!.threatsFound == 0
                    ? 'Last scan found no threats.'
                    : 'Last scan found ${latest!.threatsFound} threats.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScanActions extends StatelessWidget {
  const _ScanActions({
    required this.onQuickScan,
    required this.onFullScan,
    required this.onUsbScan,
    required this.isScanning,
  });

  final VoidCallback onQuickScan;
  final VoidCallback onFullScan;
  final VoidCallback onUsbScan;
  final bool isScanning;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isScanning ? null : onQuickScan,
                icon: const Icon(Icons.bolt),
                label: const Text('Quick Scan'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isScanning ? null : onFullScan,
                icon: const Icon(Icons.all_inclusive),
                label: const Text('Full Scan'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: isScanning ? null : onUsbScan,
          icon: const Icon(Icons.usb),
          label: const Text('USB Scan'),
        ),
      ],
    );
  }
}

class ScanResult {
  ScanResult({
    required this.type,
    required this.dateTime,
    required this.scannedFiles,
    required this.threatsFound,
  });

  final String type;
  final DateTime dateTime;
  final int scannedFiles;
  final int threatsFound;
}

String _formatDateTime(DateTime dateTime) {
  final time = TimeOfDay.fromDateTime(dateTime);
  final hours = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final suffix = time.period == DayPeriod.am ? 'AM' : 'PM';
  final minute = time.minute.toString().padLeft(2, '0');
  return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
      '$hours:$minute $suffix';
}
