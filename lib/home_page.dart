import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'services/network_service.dart';
import 'widgets/network_status_widget.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isScanning = false;
  double _progress = 0;
  final List<ScanResult> _history = [];
  bool _autoScanUsb = false;
  bool _deepScan = false;
  final NetworkService _networkService = NetworkService();

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _networkService.initialize();
  }

  @override
  void dispose() {
    _networkService.dispose();
    super.dispose();
  }

  Future<Directory> _getDataDirectory() async {
    final dir = await getApplicationSupportDirectory();
    final appDir = Directory('${dir.path}${Platform.pathSeparator}lindav');
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    return appDir;
  }

  Future<void> _loadHistory() async {
    try {
      final dir = await _getDataDirectory();
      final file = File('${dir.path}${Platform.pathSeparator}history.json');
      if (!await file.exists()) return;
      final content = await file.readAsString();
      if (content.isEmpty) return;
      final List<dynamic> raw = jsonDecode(content) as List<dynamic>;
      setState(() {
        _history
          ..clear()
          ..addAll(
            raw.map((e) => ScanResult.fromJson(e as Map<String, dynamic>)),
          );
      });
    } catch (_) {
      // ignore history load errors but keep app working
    }
  }

  Future<void> _saveHistory() async {
    try {
      final dir = await _getDataDirectory();
      final file = File('${dir.path}${Platform.pathSeparator}history.json');
      final data = _history.map((e) => e.toJson()).toList();
      await file.writeAsString(jsonEncode(data));
    } catch (_) {
      // ignore errors
    }
  }

  Future<void> _logScan(ScanResult result) async {
    try {
      final dir = await _getDataDirectory();
      final file = File('${dir.path}${Platform.pathSeparator}scan.log');
      final line =
          '[${result.dateTime.toIso8601String()}] ${result.type} on ${result.targetPath ?? '-'}: '
          '${result.scannedFiles} files, ${result.threatsFound} threats\n';
      await file.writeAsString(line, mode: FileMode.append, flush: true);
    } catch (_) {
      // ignore errors
    }
  }

  Future<void> _startScan(String type, {String? targetPath}) async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _progress = 0;
    });

    int scannedFiles = 0;
    int threats = 0;

    final stopwatch = Stopwatch()..start();

    // Very simple demo "scanner": counts files and
    // flags some as "threats" based on extension / randomness.
    Future<void> simulateScanFiles(List<FileSystemEntity> files) async {
      final total = files.length.clamp(1, 5000);
      for (var i = 0; i < files.length; i++) {
        await Future.delayed(Duration(milliseconds: _deepScan ? 40 : 15));
        scannedFiles++;
        final path = files[i].path.toLowerCase();
        final isExecutable =
            path.endsWith('.exe') ||
            path.endsWith('.bat') ||
            path.endsWith('.cmd');
        if (isExecutable && Random().nextBool()) {
          threats++;
        }
        setState(() {
          _progress = (i + 1) / total;
        });
      }
    }

    if (targetPath != null) {
      try {
        final dir = Directory(targetPath);
        if (await dir.exists()) {
          final files = await dir
              .list(recursive: _deepScan, followLinks: false)
              .where((e) => e is File)
              .toList();
          await simulateScanFiles(files);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Could not scan folder: $e')));
        }
      }
    } else {
      // Quick scan: purely simulated
      const totalSteps = 30;
      for (var i = 1; i <= totalSteps; i++) {
        await Future.delayed(Duration(milliseconds: _deepScan ? 80 : 40));
        scannedFiles += 20;
        if (Random().nextInt(40) == 0) {
          threats++;
        }
        setState(() {
          _progress = i / totalSteps;
        });
      }
    }

    stopwatch.stop();

    final result = ScanResult(
      type: type,
      dateTime: DateTime.now(),
      scannedFiles: scannedFiles,
      threatsFound: threats,
      targetPath: targetPath,
      durationMs: stopwatch.elapsedMilliseconds,
    );

    setState(() {
      _isScanning = false;
      _progress = 1;
      _history.insert(0, result);
    });

    await _saveHistory();
    await _logScan(result);

    if (!mounted) return;
    if (threats > 0) {
      // Show alert for detected threats
      // In a real app you would list individual files here.
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Threats detected'),
          content: Text('Scan found $threats suspicious item(s).'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final latest = _history.isNotEmpty ? _history.first : null;

    return WillPopScope(
      onWillPop: () async {
        final shouldExit =
            await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Exit Lindav Security?'),
                content: const Text('Are you sure you want to close the app?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Exit'),
                  ),
                ],
              ),
            ) ??
            false;
        return shouldExit;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lindav Security'),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          actions: [
            const NetworkIndicator(),
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Settings',
              onPressed: _openSettings,
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              tooltip: 'About',
              onPressed: _openAbout,
            ),
          ],
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
              const NetworkStatusWidget(),
              const SizedBox(height: 16),
              _ScanActions(
                onQuickScan: () => _startScan('Quick Scan'),
                onFullScan: _startFolderScan,
                onUsbScan: _startUsbScan,
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
      ),
    );
  }

  Future<void> _startFolderScan() async {
    if (_isScanning) return;
    try {
      final result = await FilePicker.platform.getDirectoryPath();
      if (result == null) {
        return; // user cancelled
      }
      await _startScan('Folder Scan', targetPath: result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open folder: $e')));
    }
  }

  Future<void> _startUsbScan() async {
    if (_isScanning) return;
    // Simple placeholder: let user pick a folder that represents USB.
    await _startFolderScan();
  }

  Future<void> _openSettings() async {
    final result = await showModalBottomSheet<(bool, bool)>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        bool autoScanUsb = _autoScanUsb;
        bool deepScan = _deepScan;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Settings', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              SwitchListTile(
                value: autoScanUsb,
                title: const Text('Enable USB auto-scan (placeholder)'),
                subtitle: const Text(
                  'In this demo, USB auto-scan is simulated using folder scan.',
                ),
                onChanged: (v) {
                  autoScanUsb = v;
                },
              ),
              SwitchListTile(
                value: deepScan,
                title: const Text('Deep scan (slower, more thorough)'),
                onChanged: (v) {
                  deepScan = v;
                },
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).pop((autoScanUsb, deepScan)),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _autoScanUsb = result.$1;
        _deepScan = result.$2;
      });
    }
  }

  Future<void> _openAbout() async {
    showAboutDialog(
      context: context,
      applicationName: 'Lindav Security',
      applicationVersion: '1.0.0',
      applicationLegalese: 'We don\'t collect user data. Demo scanner only.',
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
    this.targetPath,
    this.durationMs,
  });

  final String type;
  final DateTime dateTime;
  final int scannedFiles;
  final int threatsFound;
  final String? targetPath;
  final int? durationMs;

  Map<String, dynamic> toJson() => {
    'type': type,
    'dateTime': dateTime.toIso8601String(),
    'scannedFiles': scannedFiles,
    'threatsFound': threatsFound,
    'targetPath': targetPath,
    'durationMs': durationMs,
  };

  factory ScanResult.fromJson(Map<String, dynamic> json) => ScanResult(
    type: json['type'] as String,
    dateTime: DateTime.parse(json['dateTime'] as String),
    scannedFiles: json['scannedFiles'] as int,
    threatsFound: json['threatsFound'] as int,
    targetPath: json['targetPath'] as String?,
    durationMs: json['durationMs'] as int?,
  );
}

String _formatDateTime(DateTime dateTime) {
  final time = TimeOfDay.fromDateTime(dateTime);
  final hours = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final suffix = time.period == DayPeriod.am ? 'AM' : 'PM';
  final minute = time.minute.toString().padLeft(2, '0');
  return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
      '$hours:$minute $suffix';
}
