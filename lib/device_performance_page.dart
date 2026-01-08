import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

// Green color palette
const Color _emerald = Color(0xFF059669);
const Color _green = Color(0xFF10B981);
const Color _teal = Color(0xFF14B8A6);

class DevicePerformancePage extends StatefulWidget {
  const DevicePerformancePage({super.key});

  @override
  State<DevicePerformancePage> createState() => _DevicePerformancePageState();
}

class _DevicePerformancePageState extends State<DevicePerformancePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _refreshTimer;

  // Performance metrics
  double _cpuUsage = 0;
  double _memoryUsage = 0;
  double _memoryUsed = 0;
  double _memoryTotal = 0;
  double _storageUsage = 0;
  double _storageUsed = 0;
  double _storageTotal = 0;
  double _batteryLevel = 100;
  bool _isCharging = false;
  String _networkType = 'Unknown';
  double _networkSpeed = 0;

  // History for graphs (using growable lists with more points for smoother display)
  final List<double> _cpuHistory = List.generate(60, (_) => 0.0);
  final List<double> _memoryHistory = List.generate(60, (_) => 0.0);
  final List<double> _networkHistory = List.generate(60, (_) => 0.0);

  // Target values for smooth interpolation
  double _targetCpuUsage = 30;
  double _targetMemoryUsed = 4.0;
  double _targetNetworkSpeed = 75;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();

    _loadPerformanceData();
    // Faster refresh for smoother graph animation
    _refreshTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _loadPerformanceData();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPerformanceData() async {
    // Simulated performance data with smooth interpolation
    final random = Random();

    setState(() {
      // Occasionally update target values (every ~3 seconds on average)
      if (random.nextDouble() < 0.15) {
        _targetCpuUsage = 15 + random.nextDouble() * 50;
      }
      if (random.nextDouble() < 0.1) {
        _targetMemoryUsed = 3.0 + random.nextDouble() * 2.5;
      }
      if (random.nextDouble() < 0.2) {
        _targetNetworkSpeed = 30 + random.nextDouble() * 120;
      }

      // Smoothly interpolate toward target values (lerp factor 0.15 for smooth transition)
      _cpuUsage =
          _cpuUsage +
          (_targetCpuUsage - _cpuUsage) * 0.15 +
          (random.nextDouble() - 0.5) * 3;
      _cpuUsage = _cpuUsage.clamp(0, 100);
      _cpuHistory.removeAt(0);
      _cpuHistory.add(_cpuUsage);

      // Memory usage with smooth interpolation
      _memoryTotal = 8.0; // GB
      _memoryUsed =
          _memoryUsed +
          (_targetMemoryUsed - _memoryUsed) * 0.1 +
          (random.nextDouble() - 0.5) * 0.05;
      _memoryUsed = _memoryUsed.clamp(2.0, 7.5);
      _memoryUsage = (_memoryUsed / _memoryTotal) * 100;
      _memoryHistory.removeAt(0);
      _memoryHistory.add(_memoryUsage);

      // Storage (changes slowly)
      _storageTotal = 128.0; // GB
      _storageUsed = 78.5 + random.nextDouble() * 0.5;
      _storageUsage = (_storageUsed / _storageTotal) * 100;

      // Battery (changes very slowly)
      _batteryLevel = (_batteryLevel + (random.nextDouble() - 0.5) * 0.2).clamp(
        20,
        100,
      );
      if (random.nextDouble() < 0.02) _isCharging = !_isCharging;

      // Network speed with smooth interpolation
      _networkType = 'WiFi';
      _networkSpeed =
          _networkSpeed +
          (_targetNetworkSpeed - _networkSpeed) * 0.12 +
          (random.nextDouble() - 0.5) * 5;
      _networkSpeed = _networkSpeed.clamp(10, 200);
      _networkHistory.removeAt(0);
      _networkHistory.add(_networkSpeed);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Gradient Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: size.height * 0.28,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_emerald, _green, _teal],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      // Top bar
                      Row(
                        children: [
                          if (Navigator.of(context).canPop())
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          const Spacer(),
                          _HeaderIconButton(
                            icon: Icons.refresh,
                            tooltip: 'Refresh',
                            onPressed: _loadPerformanceData,
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Title row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(30),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.speed,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Device Performance',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Real-time system monitoring',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withAlpha(200),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main content
          Positioned(
            top: size.height * 0.24,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  children: [
                    // Circular Gauges Row
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(10),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [_emerald, _green],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.dashboard,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'System Overview',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _CircularGauge(
                                value: _cpuUsage,
                                maxValue: 100,
                                label: 'CPU',
                                color: _getUsageColor(_cpuUsage),
                                size: 90,
                              ),
                              _CircularGauge(
                                value: _memoryUsage,
                                maxValue: 100,
                                label: 'Memory',
                                color: _getUsageColor(_memoryUsage),
                                size: 90,
                              ),
                              _CircularGauge(
                                value: _batteryLevel,
                                maxValue: 100,
                                label: 'Battery',
                                color: _getBatteryColor(_batteryLevel),
                                size: 90,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Multi-line comparison graph
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(10),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [_emerald, _green],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.show_chart,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Performance History',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _MultiLineGraph(
                            datasets: [_cpuHistory, _memoryHistory],
                            colors: [_emerald, Colors.blue],
                            labels: ['CPU', 'Memory'],
                            height: 140,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // CPU Card
                    _PerformanceCard(
                      title: 'CPU Usage',
                      icon: Icons.memory,
                      value: '${_cpuUsage.toStringAsFixed(1)}%',
                      subtitle: 'ARM Processor',
                      progress: _cpuUsage / 100,
                      progressColor: _getUsageColor(_cpuUsage),
                      history: _cpuHistory,
                      details: [
                        _DetailRow(label: 'Cores', value: '8'),
                        _DetailRow(
                          label: 'Speed',
                          value:
                              '${(1.8 + _cpuUsage / 100).toStringAsFixed(2)} GHz',
                        ),
                        _DetailRow(
                          label: 'Processes',
                          value: '${150 + (_cpuUsage * 2).toInt()}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Memory Card
                    _PerformanceCard(
                      title: 'Memory',
                      icon: Icons.storage,
                      value: '${_memoryUsed.toStringAsFixed(1)} GB',
                      subtitle: '${_memoryTotal.toStringAsFixed(0)} GB Total',
                      progress: _memoryUsage / 100,
                      progressColor: _getUsageColor(_memoryUsage),
                      history: _memoryHistory,
                      details: [
                        _DetailRow(
                          label: 'In Use',
                          value:
                              '${_memoryUsed.toStringAsFixed(1)} GB (${_memoryUsage.toStringAsFixed(0)}%)',
                        ),
                        _DetailRow(
                          label: 'Available',
                          value:
                              '${(_memoryTotal - _memoryUsed).toStringAsFixed(1)} GB',
                        ),
                        _DetailRow(label: 'Cached', value: '1.2 GB'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Storage Card
                    _StorageCard(
                      storageUsed: _storageUsed,
                      storageTotal: _storageTotal,
                      storageUsage: _storageUsage,
                    ),
                    const SizedBox(height: 16),

                    // Network Card
                    _NetworkCard(
                      networkType: _networkType,
                      networkSpeed: _networkSpeed,
                      history: _networkHistory,
                    ),
                    const SizedBox(height: 16),

                    // Battery Card
                    _BatteryCard(
                      batteryLevel: _batteryLevel,
                      isCharging: _isCharging,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getUsageColor(double usage) {
    if (usage < 50) return _emerald;
    if (usage < 75) return Colors.orange;
    return Colors.red;
  }

  Color _getBatteryColor(double level) {
    if (level > 50) return _emerald;
    if (level > 20) return Colors.orange;
    return Colors.red;
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  const _PerformanceCard({
    required this.title,
    required this.icon,
    required this.value,
    required this.subtitle,
    required this.progress,
    required this.progressColor,
    required this.history,
    required this.details,
  });

  final String title;
  final IconData icon;
  final String value;
  final String subtitle;
  final double progress;
  final Color progressColor;
  final List<double> history;
  final List<_DetailRow> details;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [_emerald, _green]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                ),
              ],
            ),
          ),

          // Mini graph with enhanced styling
          Container(
            height: 80,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: progressColor.withAlpha(8),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(8),
            child: CustomPaint(
              size: Size.infinite,
              painter: _GraphPainter(
                data: history,
                color: progressColor,
                showGrid: true,
                showDots: true,
                smoothCurve: true,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Progress bar with enhanced styling
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '0%',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                    Text(
                      '100%',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: progressColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: constraints.maxWidth * progress,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  progressColor.withAlpha(180),
                                  progressColor,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: progressColor.withAlpha(80),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: details),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _StorageCard extends StatelessWidget {
  const _StorageCard({
    required this.storageUsed,
    required this.storageTotal,
    required this.storageUsage,
  });

  final double storageUsed;
  final double storageTotal;
  final double storageUsage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_emerald, _green]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.sd_storage,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Storage',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Internal Storage',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Storage bar visualization
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 24,
              decoration: BoxDecoration(
                color: colorScheme.outline.withAlpha(30),
              ),
              child: Row(
                children: [
                  // Apps
                  Expanded(flex: 35, child: Container(color: Colors.blue)),
                  // Photos
                  Expanded(flex: 25, child: Container(color: Colors.purple)),
                  // Videos
                  Expanded(flex: 15, child: Container(color: Colors.orange)),
                  // Other
                  Expanded(flex: 10, child: Container(color: Colors.teal)),
                  // Free
                  Expanded(
                    flex: 15,
                    child: Container(color: Colors.grey.shade300),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _StorageLegend(color: Colors.blue, label: 'Apps', size: '28 GB'),
              _StorageLegend(
                color: Colors.purple,
                label: 'Photos',
                size: '20 GB',
              ),
              _StorageLegend(
                color: Colors.orange,
                label: 'Videos',
                size: '12 GB',
              ),
              _StorageLegend(color: Colors.teal, label: 'Other', size: '8 GB'),
              _StorageLegend(
                color: Colors.grey.shade300,
                label: 'Free',
                size: '${(storageTotal - storageUsed).toStringAsFixed(0)} GB',
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(color: colorScheme.outline.withAlpha(30)),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Used: ${storageUsed.toStringAsFixed(1)} GB',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                'Total: ${storageTotal.toStringAsFixed(0)} GB',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StorageLegend extends StatelessWidget {
  const _StorageLegend({
    required this.color,
    required this.label,
    required this.size,
  });

  final Color color;
  final String label;
  final String size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text('$label ($size)', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _NetworkCard extends StatelessWidget {
  const _NetworkCard({
    required this.networkType,
    required this.networkSpeed,
    required this.history,
  });

  final String networkType;
  final double networkSpeed;
  final List<double> history;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_emerald, _green]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.wifi, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Network',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        networkType,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.arrow_downward,
                          size: 14,
                          color: _emerald,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${networkSpeed.toStringAsFixed(0)} Mbps',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _emerald,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.arrow_upward, size: 14, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          '${(networkSpeed * 0.3).toStringAsFixed(0)} Mbps',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Network graph with enhanced styling
          Container(
            height: 100,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: _emerald.withAlpha(8),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(8),
            child: CustomPaint(
              size: Size.infinite,
              painter: _GraphPainter(
                data: history,
                color: _emerald,
                maxValue: 200,
                showGrid: true,
                showDots: true,
                smoothCurve: true,
              ),
            ),
          ),
          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NetworkStat(
                  icon: Icons.download,
                  label: 'Download',
                  value: '1.2 GB',
                ),
                _NetworkStat(
                  icon: Icons.upload,
                  label: 'Upload',
                  value: '450 MB',
                ),
                _NetworkStat(
                  icon: Icons.timer,
                  label: 'Latency',
                  value: '24 ms',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NetworkStat extends StatelessWidget {
  const _NetworkStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: _emerald, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ],
    );
  }
}

class _BatteryCard extends StatelessWidget {
  const _BatteryCard({required this.batteryLevel, required this.isCharging});

  final double batteryLevel;
  final bool isCharging;

  Color _getBatteryColor() {
    if (batteryLevel > 50) return _emerald;
    if (batteryLevel > 20) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final batteryColor = _getBatteryColor();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [batteryColor, batteryColor.withAlpha(180)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCharging ? Icons.battery_charging_full : Icons.battery_std,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Battery',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isCharging ? 'Charging' : 'Discharging',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isCharging ? _emerald : colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${batteryLevel.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: batteryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Battery visualization
          Container(
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.outline.withAlpha(50),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: batteryLevel / 100,
                    child: Container(
                      margin: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: batteryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BatteryStat(
                icon: Icons.timer_outlined,
                label: 'Time Remaining',
                value: isCharging ? '45 min to full' : '4h 32m',
              ),
              _BatteryStat(
                icon: Icons.health_and_safety,
                label: 'Health',
                value: '95%',
              ),
              _BatteryStat(
                icon: Icons.thermostat,
                label: 'Temperature',
                value: '32°C',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BatteryStat extends StatelessWidget {
  const _BatteryStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: _emerald, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ],
    );
  }
}

class _GraphPainter extends CustomPainter {
  _GraphPainter({
    required this.data,
    required this.color,
    this.maxValue = 100,
    this.showGrid = true,
    this.showDots = true,
    this.smoothCurve = true,
  });

  final List<double> data;
  final Color color;
  final double maxValue;
  final bool showGrid;
  final bool showDots;
  final bool smoothCurve;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final effectiveGridColor = Colors.grey.withAlpha(30);

    // Draw grid
    if (showGrid) {
      final gridPaint = Paint()
        ..color = effectiveGridColor
        ..strokeWidth = 1;

      // Horizontal grid lines
      for (var i = 0; i <= 4; i++) {
        final y = size.height * (i / 4);
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      }

      // Vertical grid lines
      for (var i = 0; i <= 4; i++) {
        final x = size.width * (i / 4);
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      }
    }

    // Create gradient fill
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withAlpha(100), color.withAlpha(40), color.withAlpha(5)],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Line paint with glow effect
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final glowPaint = Paint()
      ..color = color.withAlpha(60)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final stepX = size.width / (data.length - 1);
    final points = <Offset>[];

    for (var i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - (data[i] / maxValue) * size.height;
      points.add(Offset(x, y.clamp(0, size.height)));
    }

    Path path;
    Path fillPath;

    if (smoothCurve && points.length > 2) {
      // Create smooth bezier curve
      path = _createSmoothPath(points);
      fillPath = Path.from(path);
      fillPath.lineTo(size.width, size.height);
      fillPath.lineTo(0, size.height);
      fillPath.close();
    } else {
      path = Path();
      fillPath = Path();

      for (var i = 0; i < points.length; i++) {
        if (i == 0) {
          path.moveTo(points[i].dx, points[i].dy);
          fillPath.moveTo(0, size.height);
          fillPath.lineTo(points[i].dx, points[i].dy);
        } else {
          path.lineTo(points[i].dx, points[i].dy);
          fillPath.lineTo(points[i].dx, points[i].dy);
        }
      }
      fillPath.lineTo(size.width, size.height);
      fillPath.close();
    }

    // Draw fill
    canvas.drawPath(fillPath, fillPaint);

    // Draw glow
    canvas.drawPath(path, glowPaint);

    // Draw line
    canvas.drawPath(path, linePaint);

    // Draw dots at data points
    if (showDots) {
      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final dotOutlinePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      // Only show last few dots to avoid clutter
      final startIndex = (points.length - 5).clamp(0, points.length);
      for (var i = startIndex; i < points.length; i++) {
        canvas.drawCircle(points[i], 4, dotOutlinePaint);
        canvas.drawCircle(points[i], 3, dotPaint);
      }
    }
  }

  Path _createSmoothPath(List<Offset> points) {
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (var i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];

      final controlX = (p0.dx + p1.dx) / 2;

      path.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
    }

    return path;
  }

  @override
  bool shouldRepaint(covariant _GraphPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.color != color;
  }
}

// Professional circular gauge widget
class _CircularGauge extends StatelessWidget {
  const _CircularGauge({
    required this.value,
    required this.maxValue,
    required this.label,
    required this.color,
    this.size = 100,
  });

  final double value;
  final double maxValue;
  final String label;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final percentage = (value / maxValue).clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CircularGaugePainter(percentage: percentage, color: color),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(percentage * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: size * 0.22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: size * 0.12,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircularGaugePainter extends CustomPainter {
  _CircularGaugePainter({required this.percentage, required this.color});

  final double percentage;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 8;
    const startAngle = -pi / 2;
    const sweepAngle = 2 * pi;

    // Background arc
    final bgPaint = Paint()
      ..color = color.withAlpha(25)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Foreground arc with gradient
    final rect = Rect.fromCircle(center: center, radius: radius);
    final fgPaint = Paint()
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: [color.withAlpha(180), color, color],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle * percentage, false, fgPaint);

    // Glow effect
    final glowPaint = Paint()
      ..color = color.withAlpha(40)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawArc(rect, startAngle, sweepAngle * percentage, false, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _CircularGaugePainter oldDelegate) {
    return oldDelegate.percentage != percentage || oldDelegate.color != color;
  }
}

// Multi-line graph for comparing metrics
class _MultiLineGraph extends StatelessWidget {
  const _MultiLineGraph({
    required this.datasets,
    required this.colors,
    required this.labels,
    this.height = 120,
  });

  final List<List<double>> datasets;
  final List<Color> colors;
  final List<String> labels;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: height,
          child: CustomPaint(
            size: Size.infinite,
            painter: _MultiLineGraphPainter(datasets: datasets, colors: colors),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(labels.length, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[index],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    labels[index],
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _MultiLineGraphPainter extends CustomPainter {
  _MultiLineGraphPainter({required this.datasets, required this.colors});

  final List<List<double>> datasets;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid
    final gridPaint = Paint()
      ..color = Colors.grey.withAlpha(30)
      ..strokeWidth = 1;

    for (var i = 0; i <= 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw each dataset
    for (var d = 0; d < datasets.length; d++) {
      final data = datasets[d];
      final color = colors[d % colors.length];

      if (data.isEmpty) continue;

      final linePaint = Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final stepX = size.width / (data.length - 1);
      final path = Path();

      for (var i = 0; i < data.length; i++) {
        final x = i * stepX;
        final y = size.height - (data[i] / 100) * size.height;

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          final prevX = (i - 1) * stepX;
          final prevY = size.height - (data[i - 1] / 100) * size.height;
          final controlX = (prevX + x) / 2;
          path.cubicTo(controlX, prevY, controlX, y, x, y);
        }
      }

      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MultiLineGraphPainter oldDelegate) {
    return true;
  }
}
