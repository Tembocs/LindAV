import 'package:flutter/material.dart';

class TestsPage extends StatefulWidget {
  const TestsPage({super.key});

  @override
  State<TestsPage> createState() => _TestsPageState();
}

class _TestsPageState extends State<TestsPage> {
  final Map<String, bool> _twoFactorMethods = {
    'SMS': true,
    'Authenticator app': true,
    'Backup codes': true,
  };

  final Map<String, bool> _permissions = {
    'Location': true,
    'Camera': true,
    'Microphone': false,
    'Storage': true,
  };

  final Map<String, String> _permissionDescriptions = {
    'Location': 'Required for nearby device detection and geotagged incidents.',
    'Camera': 'Needed to capture evidence photos or videos securely.',
    'Microphone': 'Only used for voice notes inside incident reports.',
    'Storage': 'Allows encrypted export and offline access to reports.',
  };

  final List<_DeviceSession> _sessions = const [
    _DeviceSession(
      name: 'Pixel 8 Pro',
      location: 'San Francisco, US',
      lastActive: 'Active now',
      isCurrent: true,
    ),
    _DeviceSession(
      name: 'iPad Air',
      location: 'Austin, US',
      lastActive: '1 hour ago',
      isCurrent: false,
    ),
    _DeviceSession(
      name: 'Web Login · Edge',
      location: 'New York, US',
      lastActive: 'Yesterday',
      isCurrent: false,
    ),
  ];

  bool _loginAlertsEnabled = true;
  bool _rememberDevices = false;
  bool _appLockEnabled = true;
  String _appLockMethod = 'Fingerprint / Face';
  bool _hideNotificationContent = true;
  bool _screenshotProtection = true;
  bool _clipboardProtection = true;
  String _sessionTimeout = '5 min';
  bool _dataAccessLogEnabled = false;
  bool _secureBackupEnabled = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Center'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _SectionCard(
            title: 'Account Security',
            subtitle: 'Keep accounts protected and recoverable.',
            children: [
              _buildChangePasswordTile(),
              _buildTwoFactorTile(),
              _buildRecoveryOptionsTile(),
              _buildLoginAlertsTile(),
            ],
          ),
          const SizedBox(height: 24),
          _SectionCard(
            title: 'Devices & Sessions',
            subtitle:
                'Control where you are signed in and how long sessions last.',
            children: [
              _buildActiveSessionsTile(),
              _buildLogoutOtherDevicesTile(),
              _buildRememberedDevicesTile(),
              _buildSessionTimeoutTile(),
            ],
          ),
          const SizedBox(height: 24),
          _SectionCard(
            title: 'Privacy & App Lock',
            subtitle:
                'Protect data on this device even when the app is running.',
            children: [
              _buildAppLockTile(),
              _buildHideNotificationsTile(),
              _buildScreenshotProtectionTile(),
              _buildClipboardProtectionTile(),
            ],
          ),
          const SizedBox(height: 24),
          _SectionCard(
            title: 'Permissions',
            subtitle: 'Grant only what is necessary and monitor access.',
            children: [
              _buildPermissionsDashboardTile(),
              _buildPermissionToggles(),
              _buildDataAccessLogTile(),
            ],
          ),
          const SizedBox(height: 24),
          _SectionCard(
            title: 'Data & Recovery',
            subtitle:
                'Understand how your information is secured, backed up, and retained.',
            children: [
              _buildEncryptionStatusTile(),
              _buildBackupRestoreTile(),
              _buildDownloadDataTile(),
              _buildDeleteAccountTile(),
              _buildIncidentReportingTile(),
              _buildEvidenceHandlingTile(),
              _buildAuditTrailTile(),
              _buildEmergencyContactsTile(),
            ],
          ),
          const SizedBox(height: 24),
          _SectionCard(
            title: 'Help / Legal',
            subtitle: 'Find guidance, report concerns, and review policies.',
            children: [
              _buildSecurityTipsTile(),
              _buildReportIssueTile(),
              _buildPolicyLinksTile(),
              _buildVersionInfoTile(),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildChangePasswordTile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const _IconBadge(icon: Icons.lock_reset),
          title: const Text('Change password'),
          subtitle: const Text(
            'Update regularly and use unique passphrases with numbers, symbols, and mixed case.',
          ),
          trailing: OutlinedButton(
            onPressed: () => _showInfoDialog(
              'Password guidance',
              'Use at least 12 characters, include numbers and symbols, avoid dictionary words, and never reuse credentials across services.',
            ),
            child: const Text('Update'),
          ),
        ),
        const SizedBox(height: 8),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _GuidanceChip(label: '12+ characters'),
            _GuidanceChip(label: 'Numbers & symbols'),
            _GuidanceChip(label: 'Unique per account'),
            _GuidanceChip(label: 'Password manager ready'),
          ],
        ),
      ],
    );
  }

  Widget _buildTwoFactorTile() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const _IconBadge(icon: Icons.verified_user_outlined),
          title: const Text('Two-factor authentication'),
          subtitle: const Text(
            'Enable at least two methods to keep access resilient.',
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _twoFactorMethods.entries.map((entry) {
            return FilterChip(
              label: Text(entry.key),
              selectedColor: _tintColor(theme.colorScheme.primary, 0.16),
              selected: entry.value,
              onSelected: (value) {
                setState(() {
                  _twoFactorMethods[entry.key] = value;
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Text(
          'Authenticator apps provide the strongest second factor. Keep backup codes offline for emergencies.',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildRecoveryOptionsTile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const _IconBadge(icon: Icons.settings_backup_restore),
          title: const Text('Recovery options'),
          subtitle: const Text(
            'Verify details so you can regain access quickly if locked out.',
          ),
        ),
        const SizedBox(height: 8),
        _buildChecklist([
          'Confirm a dedicated recovery email that only you can access.',
          'Add a recovery phone capable of receiving SMS in your region.',
          'Review security questions and avoid public answers.',
        ]),
      ],
    );
  }

  Widget _buildLoginAlertsTile() {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      value: _loginAlertsEnabled,
      onChanged: (value) => setState(() => _loginAlertsEnabled = value),
      title: const Text('Login alerts'),
      subtitle: const Text(
        'Notify on new device sign-ins and suspicious attempts.',
      ),
      secondary: const _IconBadge(icon: Icons.notifications_active_outlined),
    );
  }

  Widget _buildActiveSessionsTile() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const _IconBadge(icon: Icons.devices_outlined),
          title: const Text('Active sessions'),
          subtitle: const Text('Review devices currently signed in.'),
        ),
        const SizedBox(height: 12),
        Column(
          children: _sessions
              .map(
                (session) => _SessionTile(
                  session: session,
                  onTap: () {
                    if (!session.isCurrent) {
                      _showInfoDialog(
                        'Session details',
                        '${session.name}\nLocation: ${session.location}\nLast active: ${session.lastActive}',
                      );
                    }
                  },
                  theme: theme,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildLogoutOtherDevicesTile() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const _IconBadge(icon: Icons.logout),
      title: const Text('Log out of other devices'),
      subtitle: const Text('Force sign-out everywhere except this device.'),
      trailing: ElevatedButton(
        onPressed: () => _showInfoDialog(
          'Log out other devices',
          'All sessions except the current one will be terminated. Use this after losing a device or noticing unfamiliar activity.',
        ),
        child: const Text('Log out'),
      ),
    );
  }

  Widget _buildRememberedDevicesTile() {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      value: _rememberDevices,
      onChanged: (value) => setState(() => _rememberDevices = value),
      title: const Text('Remembered devices'),
      subtitle: const Text('Manage trusted devices that bypass MFA prompts.'),
      secondary: const _IconBadge(icon: Icons.verified_outlined),
    );
  }

  Widget _buildSessionTimeoutTile() {
    const options = ['1 min', '5 min', '15 min', '30 min'];
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const _IconBadge(icon: Icons.schedule),
      title: const Text('Auto-lock / session timeout'),
      subtitle: const Text(
        'End idle sessions automatically after the selected duration.',
      ),
      trailing: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _sessionTimeout,
          items: options
              .map(
                (option) => DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _sessionTimeout = value);
          },
        ),
      ),
    );
  }

  Widget _buildAppLockTile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: _appLockEnabled,
          onChanged: (value) => setState(() => _appLockEnabled = value),
          title: const Text('App lock'),
          subtitle: const Text(
            'Require local authentication when opening the app.',
          ),
          secondary: const _IconBadge(icon: Icons.security),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _appLockEnabled
              ? Padding(
                  padding: const EdgeInsets.only(left: 56),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _appLockMethod,
                      items: const ['PIN', 'Pattern', 'Fingerprint / Face']
                          .map(
                            (method) => DropdownMenuItem<String>(
                              value: method,
                              child: Text(method),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _appLockMethod = value);
                      },
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildHideNotificationsTile() {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      value: _hideNotificationContent,
      onChanged: (value) => setState(() => _hideNotificationContent = value),
      title: const Text('Hide sensitive notification content'),
      subtitle: const Text(
        'Show generic alerts only; reveal details after unlocking.',
      ),
      secondary: const _IconBadge(icon: Icons.visibility_off_outlined),
    );
  }

  Widget _buildScreenshotProtectionTile() {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      value: _screenshotProtection,
      onChanged: (value) => setState(() => _screenshotProtection = value),
      title: const Text('Screenshot protection'),
      subtitle: const Text(
        'Block screenshots on sensitive views where supported.',
      ),
      secondary: const _IconBadge(icon: Icons.no_photography_outlined),
    );
  }

  Widget _buildClipboardProtectionTile() {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      value: _clipboardProtection,
      onChanged: (value) => setState(() => _clipboardProtection = value),
      title: const Text('Clipboard protection'),
      subtitle: const Text(
        'Automatically clear copied secrets after a short delay.',
      ),
      secondary: const _IconBadge(icon: Icons.content_paste_off_outlined),
    );
  }

  Widget _buildPermissionsDashboardTile() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const _IconBadge(icon: Icons.security_outlined),
      title: const Text('Permissions dashboard'),
      subtitle: const Text(
        'Review why each permission is requested and revoke unused ones.',
      ),
      trailing: OutlinedButton(
        onPressed: () => _showInfoDialog(
          'Permissions dashboard',
          'Opening the dashboard lists every permission with usage frequency and shortcuts to revoke access.',
        ),
        child: const Text('Open'),
      ),
    );
  }

  Widget _buildPermissionToggles() {
    return Column(
      children: _permissions.entries.map((entry) {
        final description = _permissionDescriptions[entry.key] ?? '';
        return ListTile(
          contentPadding: const EdgeInsets.only(left: 56, right: 0),
          title: Text(entry.key),
          subtitle: Text(description),
          trailing: Switch.adaptive(
            value: entry.value,
            onChanged: (value) {
              setState(() {
                _permissions[entry.key] = value;
              });
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDataAccessLogTile() {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      value: _dataAccessLogEnabled,
      onChanged: (value) => setState(() => _dataAccessLogEnabled = value),
      title: const Text('Data access log'),
      subtitle: const Text(
        'Keep a detailed log of camera, location, and microphone usage (advanced).',
      ),
      secondary: const _IconBadge(icon: Icons.list_alt_outlined),
    );
  }

  Widget _buildEncryptionStatusTile() {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const _IconBadge(icon: Icons.lock_outline),
      title: const Text('Encryption status'),
      subtitle: const Text(
        'Data is encrypted at rest (AES-256) and in transit (TLS 1.3).',
      ),
      trailing: Chip(
        label: const Text('Verified'),
        backgroundColor: _tintColor(theme.colorScheme.primary, 0.12),
      ),
    );
  }

  Widget _buildBackupRestoreTile() {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      value: _secureBackupEnabled,
      onChanged: (value) => setState(() => _secureBackupEnabled = value),
      title: const Text('Secure backup & restore'),
      subtitle: const Text(
        'Store encrypted backups; warn if exporting to an unencrypted location.',
      ),
      secondary: const _IconBadge(icon: Icons.cloud),
    );
  }

  Widget _buildDownloadDataTile() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const _IconBadge(icon: Icons.download_outlined),
      title: const Text('Download my data'),
      subtitle: const Text('Export an encrypted archive of your account data.'),
      trailing: OutlinedButton(
        onPressed: () => _showInfoDialog(
          'Download data',
          'A secure ZIP will be prepared. You will receive a download link that expires after 24 hours.',
        ),
        child: const Text('Export'),
      ),
    );
  }

  Widget _buildDeleteAccountTile() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const _IconBadge(icon: Icons.delete_forever_outlined),
      title: const Text('Delete account'),
      subtitle: const Text(
        'Request permanent deletion of your data in accordance with policy.',
      ),
      trailing: TextButton(
        onPressed: () => _showInfoDialog(
          'Delete account',
          'Deletion is irreversible after 30 days. Evidence linked to legal cases may be retained per policy.',
        ),
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.error,
        ),
        child: const Text('Request'),
      ),
    );
  }

  Widget _buildIncidentReportingTile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const _IconBadge(icon: Icons.report_gmailerrorred_outlined),
          title: const Text('Incident reporting privacy'),
          subtitle: const Text(
            'Only assigned supervisors can view report details unless escalated.',
          ),
        ),
        const SizedBox(height: 8),
        _buildChecklist([
          'Reporter identity hidden from general staff.',
          'Access is logged and limited by role-based controls.',
        ]),
      ],
    );
  }

  Widget _buildEvidenceHandlingTile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const _IconBadge(icon: Icons.photo_library_outlined),
          title: const Text('Evidence handling'),
          subtitle: const Text(
            'Manage media retention and access control for photos and video.',
          ),
        ),
        const SizedBox(height: 8),
        _buildChecklist([
          'Evidence retained for 90 days by default before secure purge.',
          'Only investigators with elevated clearance can download originals.',
        ]),
      ],
    );
  }

  Widget _buildAuditTrailTile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const _IconBadge(icon: Icons.receipt_long_outlined),
          title: const Text('Audit trail'),
          subtitle: const Text(
            'Track who viewed or modified each incident record.',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Every view, edit, and export is time-stamped and attributed to a verified operator.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildEmergencyContactsTile() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const _IconBadge(icon: Icons.sos_outlined),
      title: const Text('Emergency contacts / SOS'),
      subtitle: const Text(
        'Configure direct lines, escalation paths, and panic alerts.',
      ),
      trailing: OutlinedButton(
        onPressed: () => _showInfoDialog(
          'Emergency contacts',
          'Add on-call supervisors and emergency services. SOS alerts share location and recent incident context.',
        ),
        child: const Text('Manage'),
      ),
    );
  }

  Widget _buildSecurityTipsTile() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const _IconBadge(icon: Icons.lightbulb_outline),
      title: const Text('Security tips'),
      subtitle: const Text('Short, practical guidance for daily operations.'),
      trailing: OutlinedButton(
        onPressed: () => _showInfoDialog(
          'Security tips',
          '• Verify identities before sharing sensitive data.\n• Lock devices when unattended.\n• Report suspicious activity immediately.\n• Update software as soon as patches are available.',
        ),
        child: const Text('View'),
      ),
    );
  }

  Widget _buildReportIssueTile() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const _IconBadge(icon: Icons.bug_report_outlined),
      title: const Text('Report a security issue'),
      subtitle: const Text(
        'Contact the security team with vulnerabilities or concerns.',
      ),
      trailing: OutlinedButton(
        onPressed: () => _showInfoDialog(
          'Report a security issue',
          'Email security@lindav.app or submit via the in-app incident form. Include reproduction steps and screenshots if possible.',
        ),
        child: const Text('Contact'),
      ),
    );
  }

  Widget _buildPolicyLinksTile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const _IconBadge(icon: Icons.article_outlined),
          title: const Text('Privacy Policy & Terms'),
          subtitle: const Text(
            'Review how we protect your data and the responsibilities you accept.',
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            TextButton(
              onPressed: () => _showInfoDialog(
                'Privacy Policy',
                'Opens the latest privacy policy in your browser.',
              ),
              child: const Text('Privacy Policy'),
            ),
            TextButton(
              onPressed: () => _showInfoDialog(
                'Terms of Service',
                'Opens the latest terms of service in your browser.',
              ),
              child: const Text('Terms of Service'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVersionInfoTile() {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const _IconBadge(icon: Icons.info_outline),
      title: const Text('App version & security baseline'),
      subtitle: Text(
        'Version 2.4.1 (421) · Security baseline updated Dec 18, 2025',
        style: theme.textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildChecklist(List<String> items) {
    final accent = Theme.of(context).colorScheme.secondary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle, size: 16, color: accent),
              const SizedBox(width: 8),
              Expanded(child: Text(item)),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showInfoDialog(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
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

Color _tintColor(Color color, double opacity) {
  final scaled = (color.a * 255 * opacity).round();
  final safeAlpha = scaled < 0 ? 0 : (scaled > 255 ? 255 : scaled);
  return color.withAlpha(safeAlpha);
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ..._insertDividers(children),
          ],
        ),
      ),
    );
  }

  List<Widget> _insertDividers(List<Widget> input) {
    if (input.isEmpty) return const <Widget>[];
    final result = <Widget>[];
    for (var i = 0; i < input.length; i++) {
      result.add(input[i]);
      if (i != input.length - 1) {
        result.add(const Divider(height: 32));
      }
    }
    return result;
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _tintColor(colorScheme.primary, 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: colorScheme.primary),
    );
  }
}

class _GuidanceChip extends StatelessWidget {
  const _GuidanceChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label));
  }
}

class _DeviceSession {
  const _DeviceSession({
    required this.name,
    required this.location,
    required this.lastActive,
    required this.isCurrent,
  });

  final String name;
  final String location;
  final String lastActive;
  final bool isCurrent;
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({
    required this.session,
    required this.onTap,
    required this.theme,
  });

  final _DeviceSession session;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final borderColor = _tintColor(theme.colorScheme.outlineVariant, 0.6);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: session.isCurrent
            ? _tintColor(theme.colorScheme.primary, 0.08)
            : _tintColor(theme.colorScheme.surface, 0.35),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: session.isCurrent ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  session.isCurrent ? Icons.device_hub : Icons.devices_other,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(session.location, style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 2),
                      Text(
                        session.lastActive,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (session.isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: borderColor),
                    ),
                    child: Text('Current', style: theme.textTheme.bodySmall),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
