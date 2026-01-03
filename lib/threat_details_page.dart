import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Represents a detected threat with detailed information
class ThreatInfo {
  final String filePath;
  final String fileName;
  final String threatType;
  final String severity;
  final String description;
  final int fileSize;
  final DateTime detectedAt;

  ThreatInfo({
    required this.filePath,
    required this.fileName,
    required this.threatType,
    required this.severity,
    required this.description,
    required this.fileSize,
    required this.detectedAt,
  });

  Map<String, dynamic> toJson() => {
    'filePath': filePath,
    'fileName': fileName,
    'threatType': threatType,
    'severity': severity,
    'description': description,
    'fileSize': fileSize,
    'detectedAt': detectedAt.toIso8601String(),
  };

  factory ThreatInfo.fromJson(Map<String, dynamic> json) => ThreatInfo(
    filePath: json['filePath'] as String,
    fileName: json['fileName'] as String,
    threatType: json['threatType'] as String,
    severity: json['severity'] as String,
    description: json['description'] as String,
    fileSize: json['fileSize'] as int,
    detectedAt: DateTime.parse(json['detectedAt'] as String),
  );

  static Color severityColorFor(String severity, ColorScheme colorScheme) {
    final normalized = severity.toLowerCase();
    final baseError = colorScheme.error;

    switch (normalized) {
      case 'critical':
        return baseError;
      case 'high':
        return Color.lerp(baseError, colorScheme.primary, 0.35) ?? baseError;
      case 'medium':
        return colorScheme.secondary;
      case 'low':
        return colorScheme.tertiary;
      default:
        return colorScheme.outline;
    }
  }

  Color severityColor(ColorScheme colorScheme) =>
      severityColorFor(severity, colorScheme);

  IconData get threatIcon {
    switch (threatType.toLowerCase()) {
      case 'malware':
        return Icons.bug_report;
      case 'trojan':
        return Icons.pest_control;
      case 'adware':
        return Icons.ad_units;
      case 'spyware':
        return Icons.visibility;
      case 'ransomware':
        return Icons.lock;
      case 'suspicious':
        return Icons.warning;
      default:
        return Icons.error;
    }
  }

  String get formattedFileSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024)
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Page to display detailed threat information
class ThreatDetailsPage extends StatelessWidget {
  final List<ThreatInfo> threats;
  final String scanType;
  final DateTime scanTime;
  final int totalFilesScanned;

  const ThreatDetailsPage({
    super.key,
    required this.threats,
    required this.scanType,
    required this.scanTime,
    required this.totalFilesScanned,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Threat Report'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share Report',
            onPressed: () => _shareReport(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: colorScheme.errorContainer,
            child: Column(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 48,
                  color: colorScheme.error,
                ),
                const SizedBox(height: 8),
                Text(
                  '${threats.length} Threat${threats.length == 1 ? '' : 's'} Detected',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$scanType • $totalFilesScanned files scanned',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(height: 8),
                _buildSeveritySummary(context),
              ],
            ),
          ),
          // Threat List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: threats.length,
              itemBuilder: (context, index) {
                final threat = threats[index];
                return _ThreatCard(
                  threat: threat,
                  onTap: () => _showThreatDetails(context, threat),
                );
              },
            ),
          ),
          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _quarantineAll(context),
                    icon: const Icon(Icons.security),
                    label: const Text('Quarantine All'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _deleteAll(context),
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Delete All'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.error,
                      foregroundColor: colorScheme.onError,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeveritySummary(BuildContext context) {
    final criticalCount = threats.where((t) => t.severity == 'Critical').length;
    final highCount = threats.where((t) => t.severity == 'High').length;
    final mediumCount = threats.where((t) => t.severity == 'Medium').length;
    final lowCount = threats.where((t) => t.severity == 'Low').length;

    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (criticalCount > 0)
          _SeverityChip(
            label: 'Critical: $criticalCount',
            color: ThreatInfo.severityColorFor('Critical', colorScheme),
          ),
        if (highCount > 0)
          _SeverityChip(
            label: 'High: $highCount',
            color: ThreatInfo.severityColorFor('High', colorScheme),
          ),
        if (mediumCount > 0)
          _SeverityChip(
            label: 'Medium: $mediumCount',
            color: ThreatInfo.severityColorFor('Medium', colorScheme),
          ),
        if (lowCount > 0)
          _SeverityChip(
            label: 'Low: $lowCount',
            color: ThreatInfo.severityColorFor('Low', colorScheme),
          ),
      ],
    );
  }

  void _showThreatDetails(BuildContext context, ThreatInfo threat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => _ThreatDetailSheet(
          threat: threat,
          scrollController: scrollController,
        ),
      ),
    );
  }

  void _shareReport(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final report = StringBuffer();
    report.writeln('=== Lindav Security Threat Report ===');
    report.writeln('Scan Type: $scanType');
    report.writeln('Scan Time: $scanTime');
    report.writeln('Files Scanned: $totalFilesScanned');
    report.writeln('Threats Found: ${threats.length}');
    report.writeln('');
    report.writeln('=== Detected Threats ===');
    for (var i = 0; i < threats.length; i++) {
      final t = threats[i];
      report.writeln('');
      report.writeln('${i + 1}. ${t.fileName}');
      report.writeln('   Path: ${t.filePath}');
      report.writeln('   Type: ${t.threatType}');
      report.writeln('   Severity: ${t.severity}');
      report.writeln('   Size: ${t.formattedFileSize}');
    }

    Clipboard.setData(ClipboardData(text: report.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Report copied to clipboard'),
        backgroundColor: colorScheme.primary,
      ),
    );
  }

  void _quarantineAll(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quarantine All Threats?'),
        content: const Text(
          'This will move all detected threats to a secure quarantine folder where they cannot harm your system.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: const Text('Quarantine'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Simulate quarantine action
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${threats.length} threat(s) quarantined successfully'),
          backgroundColor: colorScheme.primary,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  void _deleteAll(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Threats?'),
        content: const Text(
          'This will permanently delete all detected threats. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Simulate delete action
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${threats.length} threat(s) deleted successfully'),
          backgroundColor: colorScheme.primary,
        ),
      );
      Navigator.of(context).pop();
    }
  }
}

class _SeverityChip extends StatelessWidget {
  final String label;
  final Color color;

  const _SeverityChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final onChipColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black87;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: onChipColor,
        ),
      ),
    );
  }
}

class _ThreatCard extends StatelessWidget {
  final ThreatInfo threat;
  final VoidCallback onTap;

  const _ThreatCard({required this.threat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final severityColor = threat.severityColor(colorScheme);
    final mutedColor = colorScheme.onSurfaceVariant;
    final onSeverityColor =
        ThemeData.estimateBrightnessForColor(severityColor) == Brightness.dark
        ? Colors.white
        : Colors.black87;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: severityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(threat.threatIcon, color: severityColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      threat.fileName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      threat.threatType,
                      style: TextStyle(
                        color: severityColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      threat.filePath,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: mutedColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: severityColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      threat.severity,
                      style: TextStyle(
                        color: onSeverityColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    threat.formattedFileSize,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: mutedColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThreatDetailSheet extends StatelessWidget {
  final ThreatInfo threat;
  final ScrollController scrollController;

  const _ThreatDetailSheet({
    required this.threat,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final severityColor = threat.severityColor(colorScheme);
    // final mutedColor = colorScheme.onSurfaceVariant;
    final onSeverityColor =
        ThemeData.estimateBrightnessForColor(severityColor) == Brightness.dark
        ? Colors.white
        : Colors.black87;

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Threat icon and name
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: severityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(threat.threatIcon, color: severityColor, size: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      threat.threatType,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: severityColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${threat.severity} Severity',
                        style: TextStyle(
                          color: onSeverityColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Description
          Text(
            'Description',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(threat.description),
          const SizedBox(height: 24),

          // File Information
          Text(
            'File Information',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _DetailRow(label: 'File Name', value: threat.fileName),
          _DetailRow(label: 'File Path', value: threat.filePath),
          _DetailRow(label: 'File Size', value: threat.formattedFileSize),
          _DetailRow(
            label: 'Detected At',
            value: _formatDateTime(threat.detectedAt),
          ),
          const SizedBox(height: 24),

          // Actions
          Text(
            'Actions',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openFileLocation(context),
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Open Location'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _quarantine(context),
                  icon: const Icon(Icons.security),
                  label: const Text('Quarantine'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _delete(context),
              icon: const Icon(Icons.delete_forever),
              label: const Text('Delete This Threat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _openFileLocation(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Get the directory path
    final directory = threat.filePath.substring(
      0,
      threat.filePath.lastIndexOf(Platform.pathSeparator),
    );

    // Copy path to clipboard since we can't directly open file explorer on all platforms
    Clipboard.setData(ClipboardData(text: directory));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Path copied: $directory'),
        backgroundColor: colorScheme.primary,
      ),
    );
  }

  void _quarantine(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('File quarantined successfully'),
        backgroundColor: colorScheme.primary,
      ),
    );
    Navigator.of(context).pop();
  }

  void _delete(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete This Threat?'),
        content: Text(
          'This will permanently delete "${threat.fileName}". This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('File deleted successfully'),
          backgroundColor: colorScheme.primary,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final mutedColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(color: mutedColor)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
