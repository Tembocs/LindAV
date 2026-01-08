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

  // Green color palette
  static const Color _emerald = Color(0xFF059669);
  static const Color _green = Color(0xFF10B981);
  static const Color _teal = Color(0xFF14B8A6);

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
              height: size.height * 0.38,
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
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const Spacer(),
                          _HeaderIconButton(
                            icon: Icons.share,
                            tooltip: 'Share Report',
                            onPressed: () => _shareReport(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Alert Icon
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(30),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Threat count
                      Text(
                        '${threats.length} Threat${threats.length == 1 ? '' : 's'} Detected',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$scanType • $totalFilesScanned files scanned',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withAlpha(200),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Severity summary
                      _buildSeveritySummary(context),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main content
          Positioned(
            top: size.height * 0.34,
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
              child: Column(
                children: [
                  // Threat List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(10),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _quarantineAll(context),
                            icon: const Icon(Icons.security),
                            label: const Text('Quarantine All'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _emerald,
                              side: const BorderSide(color: _emerald),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _deleteAll(context),
                            icon: const Icon(Icons.delete_forever),
                            label: const Text('Delete All'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 6,
      children: [
        if (criticalCount > 0)
          _SeverityChip(
            label: 'Critical: $criticalCount',
            color: Colors.red.shade600,
          ),
        if (highCount > 0)
          _SeverityChip(
            label: 'High: $highCount',
            color: Colors.orange.shade600,
          ),
        if (mediumCount > 0)
          _SeverityChip(
            label: 'Medium: $mediumCount',
            color: Colors.amber.shade600,
          ),
        if (lowCount > 0) _SeverityChip(label: 'Low: $lowCount', color: _teal),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThreatCard extends StatelessWidget {
  final ThreatInfo threat;
  final VoidCallback onTap;

  const _ThreatCard({required this.threat, required this.onTap});

  static const Color _emerald = Color(0xFF059669);

  Color _getSeverityColor() {
    switch (threat.severity.toLowerCase()) {
      case 'critical':
        return Colors.red.shade600;
      case 'high':
        return Colors.orange.shade600;
      case 'medium':
        return Colors.amber.shade600;
      case 'low':
        return _emerald;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final severityColor = _getSeverityColor();
    final mutedColor = Colors.grey.shade600;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: severityColor.withAlpha(60)),
        boxShadow: [
          BoxShadow(
            color: severityColor.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [severityColor, severityColor.withAlpha(180)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(threat.threatIcon, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        threat.fileName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: severityColor.withAlpha(25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              threat.threatType,
                              style: TextStyle(
                                color: severityColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: severityColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              threat.severity,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        threat.filePath,
                        style: TextStyle(color: mutedColor, fontSize: 12),
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
                    Text(
                      threat.formattedFileSize,
                      style: TextStyle(color: mutedColor, fontSize: 12),
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

class _ThreatDetailSheet extends StatelessWidget {
  final ThreatInfo threat;
  final ScrollController scrollController;

  const _ThreatDetailSheet({
    required this.threat,
    required this.scrollController,
  });

  static const Color _emerald = Color(0xFF059669);
  static const Color _green = Color(0xFF10B981);

  Color _getSeverityColor() {
    switch (threat.severity.toLowerCase()) {
      case 'critical':
        return Colors.red.shade600;
      case 'high':
        return Colors.orange.shade600;
      case 'medium':
        return Colors.amber.shade600;
      case 'low':
        return _emerald;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final severityColor = _getSeverityColor();

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Threat icon and name
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [severityColor, severityColor.withAlpha(180)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(threat.threatIcon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
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
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: severityColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${threat.severity} Severity',
                        style: const TextStyle(
                          color: Colors.white,
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
          _SectionHeader(title: 'Description', icon: Icons.info_outline),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _emerald.withAlpha(15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _emerald.withAlpha(40)),
            ),
            child: Text(
              threat.description,
              style: TextStyle(color: Colors.grey.shade700, height: 1.5),
            ),
          ),
          const SizedBox(height: 24),

          // File Information
          _SectionHeader(
            title: 'File Information',
            icon: Icons.folder_outlined,
          ),
          const SizedBox(height: 10),
          _DetailRow(label: 'File Name', value: threat.fileName),
          _DetailRow(label: 'File Path', value: threat.filePath),
          _DetailRow(label: 'File Size', value: threat.formattedFileSize),
          _DetailRow(
            label: 'Detected At',
            value: _formatDateTime(threat.detectedAt),
          ),
          const SizedBox(height: 24),

          // Actions
          _SectionHeader(title: 'Actions', icon: Icons.flash_on_outlined),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openFileLocation(context),
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Open Location'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _emerald,
                    side: const BorderSide(color: _emerald),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _quarantine(context),
                  icon: const Icon(Icons.security),
                  label: const Text('Quarantine'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _green,
                    side: const BorderSide(color: _green),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _delete(context),
              icon: const Icon(Icons.delete_forever),
              label: const Text('Delete This Threat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _openFileLocation(BuildContext context) {
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
        backgroundColor: _emerald,
      ),
    );
  }

  void _quarantine(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('File quarantined successfully'),
        backgroundColor: _emerald,
      ),
    );
    Navigator.of(context).pop();
  }

  void _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
          backgroundColor: _emerald,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// Section header widget
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  static const Color _emerald = Color(0xFF059669);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: _emerald),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
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
