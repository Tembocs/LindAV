import 'package:flutter/material.dart';

import 'services/network_service.dart';
import 'widgets/network_status_widget.dart';

class NetworkStatusPage extends StatefulWidget {
  const NetworkStatusPage({super.key});

  @override
  State<NetworkStatusPage> createState() => _NetworkStatusPageState();
}

class _NetworkStatusPageState extends State<NetworkStatusPage> {
  final NetworkService _networkService = NetworkService();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final status = _networkService.currentStatus;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Status'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.speed),
            tooltip: 'Run Speed Test',
            onPressed: _networkService.isTestingSpeed ? null : _runSpeedTest,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const NetworkStatusWidget(),
          const SizedBox(height: 24),
          _InfoCard(status: status),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _networkService.isTestingSpeed ? null : _refresh,
            icon: _networkService.isTestingSpeed
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            label: const Text('Refresh Status'),
          ),
        ],
      ),
    );
  }

  Future<void> _refresh() async {
    await _networkService.refresh();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _runSpeedTest() async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Measuring speed...'),
          ],
        ),
      ),
    );

    await _networkService.testNetworkSpeed();

    if (!mounted) return;
    Navigator.of(context).pop();

    final status = _networkService.currentStatus;
    setState(() {});

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Speed Test Result'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ResultRow(label: 'Connection', value: status.connectionType),
            const SizedBox(height: 8),
            _ResultRow(label: 'Download', value: status.formattedDownloadSpeed),
            const SizedBox(height: 8),
            _ResultRow(label: 'Upload', value: status.formattedUploadSpeed),
            const SizedBox(height: 8),
            _ResultRow(label: 'Latency', value: status.formattedLatency),
            const SizedBox(height: 16),
            Text(
              'Quality: ${status.speedDescription}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.status});

  final NetworkStatus status;

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
            Text(
              'Tips for a Stable Connection',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _TipRow(
              icon: Icons.router,
              text: 'Place routers centrally, away from obstructions.',
            ),
            const SizedBox(height: 8),
            _TipRow(
              icon: Icons.system_security_update,
              text: 'Keep firmware and OS patches current for security.',
            ),
            const SizedBox(height: 8),
            _TipRow(
              icon: Icons.security,
              text:
                  'Use WPA2/WPA3 encryption and change default router passwords.',
            ),
            const SizedBox(height: 12),
            Divider(color: colorScheme.surfaceVariant),
            const SizedBox(height: 12),
            Text(
              'Last Checked: ${status.lastChecked}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colorScheme.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textTheme.bodyMedium?.copyWith(color: muted)),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
