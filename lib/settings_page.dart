import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'main.dart';
import 'services/network_service.dart';
import 'services/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  final bool autoScanUsb;
  final bool deepScan;
  final bool realTimeProtection;
  final bool notificationsEnabled;
  final bool scanOnStartup;
  final String scanSchedule;

  const SettingsPage({
    super.key,
    required this.autoScanUsb,
    required this.deepScan,
    this.realTimeProtection = true,
    this.notificationsEnabled = true,
    this.scanOnStartup = false,
    this.scanSchedule = 'Never',
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _autoScanUsb;
  late bool _deepScan;
  late bool _realTimeProtection;
  late bool _notificationsEnabled;
  late bool _scanOnStartup;
  late String _scanSchedule;

  final List<String> _scheduleOptions = ['Never', 'Daily', 'Weekly', 'Monthly'];

  @override
  void initState() {
    super.initState();
    _autoScanUsb = widget.autoScanUsb;
    _deepScan = widget.deepScan;
    _realTimeProtection = widget.realTimeProtection;
    _notificationsEnabled = widget.notificationsEnabled;
    _scanOnStartup = widget.scanOnStartup;
    _scanSchedule = widget.scanSchedule;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: Text('Save', style: TextStyle(color: colorScheme.onPrimary)),
          ),
        ],
      ),
      body: ListView(
        children: [
          // Protection Settings Section
          _buildSectionHeader('Protection Settings'),
          SwitchListTile(
            value: _realTimeProtection,
            title: const Text('Real-time Protection'),
            subtitle: const Text('Monitor system for threats in real-time'),
            secondary: Icon(
              Icons.shield,
              color: _realTimeProtection ? Colors.green : Colors.grey,
            ),
            onChanged: (value) {
              setState(() {
                _realTimeProtection = value;
              });
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            value: _autoScanUsb,
            title: const Text('Auto-scan USB Devices'),
            subtitle: const Text('Automatically scan when USB is connected'),
            secondary: Icon(
              Icons.usb,
              color: _autoScanUsb ? Colors.green : Colors.grey,
            ),
            onChanged: (value) {
              setState(() {
                _autoScanUsb = value;
              });
            },
          ),
          const Divider(height: 1),

          // Scan Settings Section
          _buildSectionHeader('Scan Settings'),
          SwitchListTile(
            value: _deepScan,
            title: const Text('Deep Scan Mode'),
            subtitle: const Text('More thorough scanning (slower)'),
            secondary: Icon(
              Icons.search,
              color: _deepScan ? Colors.green : Colors.grey,
            ),
            onChanged: (value) {
              setState(() {
                _deepScan = value;
              });
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            value: _scanOnStartup,
            title: const Text('Scan on Startup'),
            subtitle: const Text('Run quick scan when app starts'),
            secondary: Icon(
              Icons.play_circle_outline,
              color: _scanOnStartup ? Colors.green : Colors.grey,
            ),
            onChanged: (value) {
              setState(() {
                _scanOnStartup = value;
              });
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Scheduled Scan'),
            subtitle: Text(_scanSchedule),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showScheduleDialog,
          ),
          const Divider(height: 1),

          // Notification Settings Section
          _buildSectionHeader('Notifications'),
          SwitchListTile(
            value: _notificationsEnabled,
            title: const Text('Enable Notifications'),
            subtitle: const Text('Get alerts for threats and scan results'),
            secondary: Icon(
              Icons.notifications,
              color: _notificationsEnabled ? Colors.green : Colors.grey,
            ),
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          const Divider(height: 1),

          // Appearance Settings Section
          _buildSectionHeader('Appearance'),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Theme Mode'),
            subtitle: Text(_getThemeModeText()),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showThemeModeDialog,
          ),
          const Divider(height: 1),
          ListTile(
            leading: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: themeProvider.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
            title: const Text('Accent Color'),
            subtitle: Text(availableColors[themeProvider.colorIndex].name),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showColorPickerDialog,
          ),
          const Divider(height: 1),

          // Network Settings Section
          _buildSectionHeader('Network'),
          ListTile(
            leading: const Icon(Icons.wifi),
            title: const Text('Test Network Speed'),
            subtitle: const Text('Check your current connection speed'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _testNetworkSpeed,
          ),
          const Divider(height: 1),

          // Storage Section
          _buildSectionHeader('Storage & Data'),
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text('View Scan Logs'),
            subtitle: const Text('View history of all scans'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _viewScanLogs,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Clear Scan History'),
            subtitle: const Text('Remove all scan records'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _confirmClearHistory,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Clear Cache'),
            subtitle: const Text('Free up storage space'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _clearCache,
          ),
          const Divider(height: 1),

          // About Section
          _buildSectionHeader('About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('App Version'),
            subtitle: const Text('1.0.0'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showPrivacyPolicy,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showTermsOfService,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  String _getThemeModeText() {
    switch (themeProvider.themeMode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System Default';
    }
  }

  Future<void> _showThemeModeDialog() async {
    final currentMode = themeProvider.themeMode;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Theme Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<AppThemeMode>(
              value: AppThemeMode.system,
              groupValue: currentMode,
              title: const Text('System Default'),
              subtitle: const Text('Follow device settings'),
              onChanged: (value) {
                themeProvider.setThemeMode(AppThemeMode.system);
                Navigator.of(context).pop();
                setState(() {});
              },
            ),
            RadioListTile<AppThemeMode>(
              value: AppThemeMode.light,
              groupValue: currentMode,
              title: const Text('Light'),
              subtitle: const Text('Always use light theme'),
              onChanged: (value) {
                themeProvider.setThemeMode(AppThemeMode.light);
                Navigator.of(context).pop();
                setState(() {});
              },
            ),
            RadioListTile<AppThemeMode>(
              value: AppThemeMode.dark,
              groupValue: currentMode,
              title: const Text('Dark'),
              subtitle: const Text('Always use dark theme'),
              onChanged: (value) {
                themeProvider.setThemeMode(AppThemeMode.dark);
                Navigator.of(context).pop();
                setState(() {});
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _showColorPickerDialog() async {
    final currentIndex = themeProvider.colorIndex;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accent Color'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: availableColors.length,
            itemBuilder: (context, index) {
              final colorOption = availableColors[index];
              final isSelected = index == currentIndex;

              return GestureDetector(
                onTap: () {
                  themeProvider.setColorIndex(index);
                  Navigator.of(context).pop();
                  setState(() {});
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: colorOption.color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: colorOption.color.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : null,
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    Navigator.of(context).pop(
      SettingsResult(
        autoScanUsb: _autoScanUsb,
        deepScan: _deepScan,
        realTimeProtection: _realTimeProtection,
        notificationsEnabled: _notificationsEnabled,
        scanOnStartup: _scanOnStartup,
        scanSchedule: _scanSchedule,
      ),
    );
  }

  Future<void> _showScheduleDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scheduled Scan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _scheduleOptions.map((option) {
            return RadioListTile<String>(
              value: option,
              groupValue: _scanSchedule,
              title: Text(option),
              onChanged: (value) {
                Navigator.of(context).pop(value);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _scanSchedule = result;
      });
    }
  }

  Future<void> _testNetworkSpeed() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Testing network speed...'),
          ],
        ),
      ),
    );

    final networkService = NetworkService();
    await networkService.testNetworkSpeed();

    if (!mounted) return;
    Navigator.of(context).pop();

    final status = networkService.currentStatus;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Network Speed Test'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSpeedRow('Connection', status.connectionType),
            const SizedBox(height: 8),
            _buildSpeedRow('Download', status.formattedDownloadSpeed),
            const SizedBox(height: 8),
            _buildSpeedRow('Upload', status.formattedUploadSpeed),
            const SizedBox(height: 8),
            _buildSpeedRow('Latency', status.formattedLatency),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getSpeedColor(status.downloadSpeed).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.speed,
                    color: _getSpeedColor(status.downloadSpeed),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Quality: ${status.speedDescription}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getSpeedColor(status.downloadSpeed),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Color _getSpeedColor(double? speed) {
    if (speed == null) return Colors.grey;
    if (speed >= 25) return Colors.green;
    if (speed >= 10) return Colors.lightGreen;
    if (speed >= 1) return Colors.orange;
    return Colors.red;
  }

  Future<void> _viewScanLogs() async {
    try {
      final dir = await getApplicationSupportDirectory();
      final appDir = Directory('${dir.path}${Platform.pathSeparator}lindav');
      final logFile = File('${appDir.path}${Platform.pathSeparator}scan.log');

      String content = 'No scan logs found.';
      if (await logFile.exists()) {
        content = await logFile.readAsString();
        if (content.isEmpty) {
          content = 'No scan logs found.';
        }
      }

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Scan Logs'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: SingleChildScrollView(
              child: Text(
                content,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not read logs: $e')));
    }
  }

  Future<void> _confirmClearHistory() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Scan History?'),
        content: const Text(
          'This will permanently delete all scan history and logs. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (shouldClear == true) {
      try {
        final dir = await getApplicationSupportDirectory();
        final appDir = Directory('${dir.path}${Platform.pathSeparator}lindav');
        final historyFile = File(
          '${appDir.path}${Platform.pathSeparator}history.json',
        );
        final logFile = File('${appDir.path}${Platform.pathSeparator}scan.log');

        if (await historyFile.exists()) {
          await historyFile.delete();
        }
        if (await logFile.exists()) {
          await logFile.delete();
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Scan history cleared'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error clearing history: $e')));
      }
    }
  }

  Future<void> _clearCache() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache?'),
        content: const Text(
          'This will clear temporary files to free up storage space.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (shouldClear == true) {
      try {
        final cacheDir = await getTemporaryDirectory();
        if (await cacheDir.exists()) {
          await for (final entity in cacheDir.list()) {
            try {
              await entity.delete(recursive: true);
            } catch (_) {
              // Ignore individual file deletion errors
            }
          }
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cache cleared successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error clearing cache: $e')));
      }
    }
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Lindav Security Privacy Policy\n\n'
            '1. Data Collection\n'
            'We do not collect any personal data. All scan data is stored locally on your device.\n\n'
            '2. Network Access\n'
            'The app accesses the network only to check connectivity status and measure network speed.\n\n'
            '3. File Access\n'
            'The app only accesses files you explicitly choose to scan. We do not upload or share your files.\n\n'
            '4. Storage\n'
            'Scan history and logs are stored locally on your device and can be deleted at any time.\n\n'
            '5. Third Parties\n'
            'We do not share any information with third parties.\n\n'
            'Last updated: December 2025',
          ),
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

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'Lindav Security Terms of Service\n\n'
            '1. Acceptance of Terms\n'
            'By using this app, you agree to these terms of service.\n\n'
            '2. Demo Application\n'
            'This is a demonstration application. The scanning functionality is simulated and should not be relied upon for actual security purposes.\n\n'
            '3. No Warranty\n'
            'This app is provided "as is" without any warranties.\n\n'
            '4. Limitation of Liability\n'
            'We are not liable for any damages arising from the use of this app.\n\n'
            '5. Changes to Terms\n'
            'We reserve the right to modify these terms at any time.\n\n'
            'Last updated: December 2025',
          ),
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

class SettingsResult {
  final bool autoScanUsb;
  final bool deepScan;
  final bool realTimeProtection;
  final bool notificationsEnabled;
  final bool scanOnStartup;
  final String scanSchedule;

  SettingsResult({
    required this.autoScanUsb,
    required this.deepScan,
    required this.realTimeProtection,
    required this.notificationsEnabled,
    required this.scanOnStartup,
    required this.scanSchedule,
  });
}
