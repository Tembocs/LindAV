import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'main.dart';
import 'settings_page.dart';
import 'splash_page.dart';
import 'threat_details_page.dart';
import 'widgets/network_status_widget.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool _isScanning = false;
  double _progress = 0;
  final List<ScanResult> _history = [];
  bool _autoScanUsb = false;
  bool _deepScan = false;
  bool _realTimeProtection = true;
  bool _notificationsEnabled = true;
  bool _scanOnStartup = false;
  String _scanSchedule = 'Never';

  @override
  void initState() {
    super.initState();
    _loadHistory();
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
    List<ThreatInfo> detectedThreats = [];
    final random = Random();

    const threatTypes = [
      {
        'type': 'Malware',
        'severity': 'Critical',
        'desc':
            'Malicious software designed to damage or gain unauthorized access to your system.',
      },
      {
        'type': 'Trojan',
        'severity': 'High',
        'desc':
            'A program that appears legitimate but contains malicious code to steal data or harm your system.',
      },
      {
        'type': 'Adware',
        'severity': 'Low',
        'desc':
            'Unwanted software that displays advertisements and may track your browsing habits.',
      },
      {
        'type': 'Spyware',
        'severity': 'High',
        'desc':
            'Software that secretly monitors user activity and collects personal information.',
      },
      {
        'type': 'Suspicious',
        'severity': 'Medium',
        'desc':
            'This file exhibits suspicious behavior patterns that may indicate potential threats.',
      },
      {
        'type': 'Ransomware',
        'severity': 'Critical',
        'desc':
            'Dangerous malware that encrypts your files and demands payment for decryption.',
      },
    ];

    final stopwatch = Stopwatch()..start();

    Future<void> simulateScanFiles(List<FileSystemEntity> files) async {
      final total = files.length.clamp(1, 5000);
      for (var i = 0; i < files.length; i++) {
        await Future.delayed(Duration(milliseconds: _deepScan ? 40 : 15));
        scannedFiles++;
        final file = files[i];
        final path = file.path.toLowerCase();
        final isExecutable =
            path.endsWith('.exe') ||
            path.endsWith('.bat') ||
            path.endsWith('.cmd') ||
            path.endsWith('.dll') ||
            path.endsWith('.scr');
        if (isExecutable && random.nextInt(3) == 0) {
          final threatData = threatTypes[random.nextInt(threatTypes.length)];
          final fileName = file.path.split(Platform.pathSeparator).last;
          int fileSize = 0;
          try {
            final fileStat = File(file.path).statSync();
            fileSize = fileStat.size;
          } catch (_) {
            fileSize = random.nextInt(500000) + 1000;
          }

          detectedThreats.add(
            ThreatInfo(
              filePath: file.path,
              fileName: fileName,
              threatType: threatData['type']!,
              severity: threatData['severity']!,
              description: threatData['desc']!,
              fileSize: fileSize,
              detectedAt: DateTime.now(),
            ),
          );
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
          final colorScheme = Theme.of(context).colorScheme;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not scan folder: $e'),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      }
    } else {
      const totalSteps = 30;
      final simulatedPaths = [
        'C:\\Windows\\System32\\malware.exe',
        'C:\\Users\\Public\\Downloads\\trojan.exe',
        'C:\\Program Files\\FakeApp\\suspicious.dll',
        'C:\\Temp\\adware.exe',
        'C:\\Users\\User\\AppData\\Roaming\\spyware.bat',
      ];

      for (var i = 1; i <= totalSteps; i++) {
        await Future.delayed(Duration(milliseconds: _deepScan ? 80 : 40));
        scannedFiles += 20;

        if (random.nextInt(12) == 0 && detectedThreats.length < 5) {
          final threatData = threatTypes[random.nextInt(threatTypes.length)];
          final fakePath =
              simulatedPaths[detectedThreats.length % simulatedPaths.length];
          final fileName = fakePath.split('\\').last;

          detectedThreats.add(
            ThreatInfo(
              filePath: fakePath,
              fileName: fileName,
              threatType: threatData['type']!,
              severity: threatData['severity']!,
              description: threatData['desc']!,
              fileSize: random.nextInt(500000) + 1000,
              detectedAt: DateTime.now(),
            ),
          );
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
      threatsFound: detectedThreats.length,
      targetPath: targetPath,
      durationMs: stopwatch.elapsedMilliseconds,
      detectedThreats: detectedThreats,
    );

    setState(() {
      _isScanning = false;
      _progress = 1;
      _history.insert(0, result);
    });

    await _saveHistory();
    await _logScan(result);

    if (!mounted) return;
    if (detectedThreats.isNotEmpty) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ThreatDetailsPage(
            threats: detectedThreats,
            scanType: type,
            scanTime: result.dateTime,
            totalFilesScanned: scannedFiles,
          ),
        ),
      );
    } else {
      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            icon: Icon(Icons.check_circle, color: Colors.green, size: 48),
            title: const Text('No Threats Found'),
            content: Text('Scanned $scannedFiles files. Your system is clean!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final latest = _history.isNotEmpty ? _history.first : null;

    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).canPop()) {
          return true;
        }
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
          title: const Text('Device Scans'),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          actions: [
            const NetworkIndicator(),
            IconButton(
              icon: const Icon(Icons.restart_alt),
              tooltip: 'Reset App',
              onPressed: _resetApp,
            ),
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
                            trailing: item.threatsFound > 0
                                ? const Icon(Icons.chevron_right)
                                : null,
                            onTap:
                                item.threatsFound > 0 &&
                                    item.detectedThreats.isNotEmpty
                                ? () => _viewThreatDetails(item)
                                : null,
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

  void _viewThreatDetails(ScanResult scanResult) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ThreatDetailsPage(
          threats: scanResult.detectedThreats,
          scanType: scanResult.type,
          scanTime: scanResult.dateTime,
          totalFilesScanned: scanResult.scannedFiles,
        ),
      ),
    );
  }

  Future<void> _startFolderScan() async {
    if (_isScanning) return;
    try {
      final result = await FilePicker.platform.getDirectoryPath();
      if (result == null) {
        return;
      }
      await _startScan('Folder Scan', targetPath: result);
    } catch (e) {
      if (!mounted) return;
      final colorScheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open folder: $e'),
          backgroundColor: colorScheme.error,
        ),
      );
    }
  }

  Future<void> _startUsbScan() async {
    if (_isScanning) return;
    await _startFolderScan();
  }

  Future<void> _openSettings() async {
    final result = await Navigator.of(context).push<SettingsResult>(
      MaterialPageRoute(
        builder: (context) => SettingsPage(
          autoScanUsb: _autoScanUsb,
          deepScan: _deepScan,
          realTimeProtection: _realTimeProtection,
          notificationsEnabled: _notificationsEnabled,
          scanOnStartup: _scanOnStartup,
          scanSchedule: _scanSchedule,
          themeMode: AppTheme.of(context).themeMode,
        ),
      ),
    );

    if (result != null) {
      AppTheme.of(context).setThemeMode(result.themeMode);
      setState(() {
        _autoScanUsb = result.autoScanUsb;
        _deepScan = result.deepScan;
        _realTimeProtection = result.realTimeProtection;
        _notificationsEnabled = result.notificationsEnabled;
        _scanOnStartup = result.scanOnStartup;
        _scanSchedule = result.scanSchedule;
      });

      await _loadHistory();
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

  Future<void> _resetApp() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          title: const Text('Reset App?'),
          content: const Text(
            'This will clear all scan history and reset the app to its initial state. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: colorScheme.error),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (shouldReset == true) {
      try {
        final dir = await _getDataDirectory();
        final historyFile = File(
          '${dir.path}${Platform.pathSeparator}history.json',
        );
        final logFile = File('${dir.path}${Platform.pathSeparator}scan.log');

        if (await historyFile.exists()) {
          await historyFile.delete();
        }
        if (await logFile.exists()) {
          await logFile.delete();
        }
      } catch (_) {
        // Ignore errors during cleanup
      }

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const SplashPage()),
        (route) => false,
      );
    }
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
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
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
    this.detectedThreats = const [],
  });

  final String type;
  final DateTime dateTime;
  final int scannedFiles;
  final int threatsFound;
  final String? targetPath;
  final int? durationMs;
  final List<ThreatInfo> detectedThreats;

  Map<String, dynamic> toJson() => {
    'type': type,
    'dateTime': dateTime.toIso8601String(),
    'scannedFiles': scannedFiles,
    'threatsFound': threatsFound,
    'targetPath': targetPath,
    'durationMs': durationMs,
    'detectedThreats': detectedThreats.map((t) => t.toJson()).toList(),
  };

  factory ScanResult.fromJson(Map<String, dynamic> json) => ScanResult(
    type: json['type'] as String,
    dateTime: DateTime.parse(json['dateTime'] as String),
    scannedFiles: json['scannedFiles'] as int,
    threatsFound: json['threatsFound'] as int,
    targetPath: json['targetPath'] as String?,
    durationMs: json['durationMs'] as int?,
    detectedThreats:
        (json['detectedThreats'] as List<dynamic>?)
            ?.map((e) => ThreatInfo.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
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
