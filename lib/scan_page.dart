import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'settings_page.dart';
import 'threat_details_page.dart';
import 'widgets/network_status_widget.dart';
import 'theme_controller.dart';

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

  // Green color palette
  static const Color _emerald = Color(0xFF059669);
  static const Color _green = Color(0xFF10B981);
  static const Color _teal = Color(0xFF14B8A6);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
                            // Back button
                            if (Navigator.of(context).canPop())
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            const Spacer(),
                            // Action buttons
                            const NetworkIndicator(),
                            _HeaderIconButton(
                              icon: Icons.settings,
                              tooltip: 'Settings',
                              onPressed: _openSettings,
                            ),
                            _HeaderIconButton(
                              icon: Icons.info_outline,
                              tooltip: 'About',
                              onPressed: _openAbout,
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
                                Icons.shield_moon,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Device Scans',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  _isScanning
                                      ? 'Scanning in progress...'
                                      : 'Keep your device protected',
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
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
                      Row(
                        children: [
                          Icon(Icons.history, size: 20, color: _emerald),
                          const SizedBox(width: 8),
                          Text(
                            'Scan History',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          if (_history.isNotEmpty)
                            TextButton.icon(
                              onPressed: _clearHistory,
                              icon: Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: Colors.red.shade400,
                              ),
                              label: Text(
                                'Clear',
                                style: TextStyle(color: Colors.red.shade400),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_history.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: _emerald.withAlpha(15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _emerald.withAlpha(40)),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 48,
                                color: _emerald.withAlpha(100),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No scans yet',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap Quick Scan to start protecting your device',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      else
                        ...List.generate(_history.length, (index) {
                          final item = _history[index];
                          return _HistoryTile(
                            result: item,
                            onTap: () {
                              if (item.threatsFound > 0 &&
                                  item.detectedThreats.isNotEmpty) {
                                _viewThreatDetails(item);
                              }
                            },
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ),
          ],
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

  Future<void> _clearHistory() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear Scan History?'),
        content: const Text(
          'This will delete all scan history records. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (shouldClear == true) {
      try {
        final dir = await _getDataDirectory();
        final historyFile = File(
          '${dir.path}${Platform.pathSeparator}history.json',
        );
        if (await historyFile.exists()) {
          await historyFile.delete();
        }
      } catch (_) {
        // Ignore errors during cleanup
      }

      setState(() {
        _history.clear();
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scan history cleared'),
          backgroundColor: Color(0xFF059669),
        ),
      );
    }
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

// Header icon button widget
class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  const _HeaderIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: Colors.white),
      onPressed: onPressed,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withAlpha(25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// History tile widget for scan history
class _HistoryTile extends StatelessWidget {
  final ScanResult result;
  final VoidCallback onTap;

  const _HistoryTile({required this.result, required this.onTap});

  static const Color _emerald = Color(0xFF059669);
  static const Color _green = Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    final hasThreats = result.threatsFound > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: hasThreats
              ? [Colors.red.shade50, Colors.orange.shade50]
              : [_emerald.withAlpha(20), _green.withAlpha(20)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasThreats ? Colors.red.withAlpha(50) : _emerald.withAlpha(50),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: hasThreats
                          ? [Colors.red, Colors.orange]
                          : [_emerald, _green],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    hasThreats
                        ? Icons.warning_rounded
                        : Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.type,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${result.scannedFiles} files scanned',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDateTime(result.dateTime),
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: hasThreats
                            ? Colors.red.withAlpha(25)
                            : _emerald.withAlpha(25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        hasThreats
                            ? '${result.threatsFound} threat${result.threatsFound > 1 ? 's' : ''}'
                            : 'Clean',
                        style: TextStyle(
                          color: hasThreats ? Colors.red : _emerald,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
