import 'dart:async';

import 'package:flutter/material.dart';

import '../services/network_service.dart';

class NetworkStatusWidget extends StatefulWidget {
  const NetworkStatusWidget({super.key});

  @override
  State<NetworkStatusWidget> createState() => _NetworkStatusWidgetState();
}

class _NetworkStatusWidgetState extends State<NetworkStatusWidget> {
  final NetworkService _networkService = NetworkService();
  late StreamSubscription<NetworkStatus> _subscription;
  NetworkStatus? _status;

  @override
  void initState() {
    super.initState();
    _status = _networkService.currentStatus;
    _subscription = _networkService.statusStream.listen((status) {
      setState(() {
        _status = status;
      });
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final status = _status;

    if (status == null) {
      return const SizedBox.shrink();
    }

    final isConnected = status.isConnected;
    final isTesting = _networkService.isTestingSpeed;

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
                  isConnected ? Icons.wifi : Icons.wifi_off,
                  size: 28,
                  color: isConnected ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Network Status',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isConnected ? status.connectionType : 'No Connection',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: isTesting
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          ),
                        )
                      : const Icon(Icons.refresh),
                  tooltip: 'Refresh network status',
                  onPressed: isTesting ? null : () => _networkService.refresh(),
                ),
              ],
            ),
            if (isConnected) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _SpeedIndicator(
                      icon: Icons.download,
                      label: 'Download',
                      value: status.formattedDownloadSpeed,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SpeedIndicator(
                      icon: Icons.upload,
                      label: 'Upload',
                      value: status.formattedUploadSpeed,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SpeedIndicator(
                      icon: Icons.speed,
                      label: 'Latency',
                      value: status.formattedLatency,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SpeedQualityBar(status: status),
            ],
          ],
        ),
      ),
    );
  }
}

class _SpeedIndicator extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SpeedIndicator({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SpeedQualityBar extends StatelessWidget {
  final NetworkStatus status;

  const _SpeedQualityBar({required this.status});

  @override
  Widget build(BuildContext context) {
    final speed = status.downloadSpeed ?? 0;

    // Calculate quality percentage (0-100 scale, capped at 100 Mbps)
    final quality = (speed / 100).clamp(0.0, 1.0);

    Color barColor;
    if (quality >= 0.5) {
      barColor = Colors.green;
    } else if (quality >= 0.25) {
      barColor = Colors.lightGreen;
    } else if (quality >= 0.1) {
      barColor = Colors.orange;
    } else {
      barColor = Colors.red;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Connection Quality',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            Text(
              status.speedDescription,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: barColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: status.downloadSpeed == null ? null : quality,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

/// Compact network indicator for app bar
class NetworkIndicator extends StatefulWidget {
  const NetworkIndicator({super.key});

  @override
  State<NetworkIndicator> createState() => _NetworkIndicatorState();
}

class _NetworkIndicatorState extends State<NetworkIndicator> {
  final NetworkService _networkService = NetworkService();
  late StreamSubscription<NetworkStatus> _subscription;
  NetworkStatus? _status;

  @override
  void initState() {
    super.initState();
    _status = _networkService.currentStatus;
    _subscription = _networkService.statusStream.listen((status) {
      setState(() {
        _status = status;
      });
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;
    if (status == null) return const SizedBox.shrink();

    final isConnected = status.isConnected;

    return Tooltip(
      message: isConnected
          ? '${status.connectionType}\n${status.formattedDownloadSpeed}'
          : 'No network connection',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Icon(
          isConnected ? Icons.wifi : Icons.wifi_off,
          color: isConnected ? Colors.white : Colors.red[200],
          size: 20,
        ),
      ),
    );
  }
}
