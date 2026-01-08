import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TestsPage extends StatefulWidget {
  const TestsPage({super.key});

  @override
  State<TestsPage> createState() => _TestsPageState();
}

class _TestsPageState extends State<TestsPage> with TickerProviderStateMixin {
  // Loading states
  bool _isLoggingOutDevices = false;
  bool _isExportingData = false;
  bool _isDeletingAccount = false;
  bool _isSavingSettings = false;

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

  List<_DeviceSession> _sessions = [
    const _DeviceSession(
      id: '1',
      name: 'Pixel 8 Pro',
      location: 'San Francisco, US',
      lastActive: 'Active now',
      isCurrent: true,
    ),
    const _DeviceSession(
      id: '2',
      name: 'iPad Air',
      location: 'Austin, US',
      lastActive: '1 hour ago',
      isCurrent: false,
    ),
    const _DeviceSession(
      id: '3',
      name: 'Web Login · Edge',
      location: 'New York, US',
      lastActive: 'Yesterday',
      isCurrent: false,
    ),
  ];

  // Emergency contacts
  final List<_EmergencyContact> _emergencyContacts = [
    const _EmergencyContact(name: 'Security Desk', phone: '+1 555-0100'),
    const _EmergencyContact(name: 'On-Call Supervisor', phone: '+1 555-0101'),
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

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: isDestructive
                ? TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  )
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _saveSettingWithFeedback(String settingName) async {
    setState(() => _isSavingSettings = true);
    // Simulate save delay
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isSavingSettings = false);
    _showSnackBar('$settingName updated');
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => const _ChangePasswordDialog(),
    ).then((success) {
      if (success == true) {
        _showSnackBar('Password changed successfully');
      }
    });
  }

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
                          if (_isSavingSettings)
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
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
                              Icons.security_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Security Center',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Manage your security settings',
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
                    _SectionCard(
                      title: 'Account Security',
                      subtitle: 'Keep accounts protected and recoverable.',
                      icon: Icons.shield_outlined,
                      children: [
                        _buildChangePasswordTile(),
                        _buildTwoFactorTile(),
                        _buildRecoveryOptionsTile(),
                        _buildLoginAlertsTile(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Devices & Sessions',
                      subtitle: 'Control where you are signed in.',
                      icon: Icons.devices_outlined,
                      children: [
                        _buildActiveSessionsTile(),
                        _buildLogoutOtherDevicesTile(),
                        _buildRememberedDevicesTile(),
                        _buildSessionTimeoutTile(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Privacy & App Lock',
                      subtitle: 'Protect data on this device.',
                      icon: Icons.lock_outline,
                      children: [
                        _buildAppLockTile(),
                        _buildHideNotificationsTile(),
                        _buildScreenshotProtectionTile(),
                        _buildClipboardProtectionTile(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Permissions',
                      subtitle: 'Grant only what is necessary.',
                      icon: Icons.tune_outlined,
                      children: [
                        _buildPermissionsDashboardTile(),
                        _buildPermissionToggles(),
                        _buildDataAccessLogTile(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Data & Recovery',
                      subtitle: 'Secure, backup, and manage your data.',
                      icon: Icons.backup_outlined,
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
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Help / Legal',
                      subtitle: 'Guidance, concerns, and policies.',
                      icon: Icons.help_outline,
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
              ),
            ),
          ),
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
            onPressed: _showChangePasswordDialog,
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
          subtitle: Text('${_sessions.length} device(s) currently signed in.'),
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Column(
            key: ValueKey(_sessions.length),
            children: _sessions
                .map(
                  (session) => _SessionTile(
                    session: session,
                    onTap: () => _showSessionOptions(session),
                    onRemove: session.isCurrent
                        ? null
                        : () => _removeSession(session),
                    theme: theme,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Future<void> _removeSession(_DeviceSession session) async {
    final confirmed = await _showConfirmDialog(
      title: 'End session?',
      message: 'This will sign out "${session.name}" immediately.',
      confirmText: 'Sign out',
      isDestructive: true,
    );
    if (!confirmed) return;

    setState(() {
      _sessions = _sessions.where((s) => s.id != session.id).toList();
    });
    _showSnackBar('Session ended for ${session.name}');
  }

  void _showSessionOptions(_DeviceSession session) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  session.isCurrent ? Icons.phone_android : Icons.devices_other,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(session.location),
                    ],
                  ),
                ),
                if (session.isCurrent)
                  Chip(
                    label: const Text('Current'),
                    backgroundColor: _tintColor(
                      Theme.of(context).colorScheme.primary,
                      0.12,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Last active'),
              subtitle: Text(session.lastActive),
            ),
            ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: const Text('Location'),
              subtitle: Text(session.location),
            ),
            if (!session.isCurrent) ...[
              const Divider(),
              ListTile(
                leading: Icon(
                  Icons.logout,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  'End this session',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _removeSession(session);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutOtherDevicesTile() {
    final otherSessionsCount = _sessions.where((s) => !s.isCurrent).length;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const _IconBadge(icon: Icons.logout),
      title: const Text('Log out of other devices'),
      subtitle: Text(
        otherSessionsCount > 0
            ? 'Force sign-out from $otherSessionsCount other device(s).'
            : 'No other active sessions.',
      ),
      trailing: _isLoggingOutDevices
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : ElevatedButton(
              onPressed: otherSessionsCount > 0 ? _logoutOtherDevices : null,
              child: const Text('Log out'),
            ),
    );
  }

  Future<void> _logoutOtherDevices() async {
    final confirmed = await _showConfirmDialog(
      title: 'Log out other devices?',
      message:
          'All sessions except the current one will be terminated. Use this after losing a device or noticing unfamiliar activity.',
      confirmText: 'Log out all',
      isDestructive: true,
    );
    if (!confirmed) return;

    setState(() => _isLoggingOutDevices = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _sessions = _sessions.where((s) => s.isCurrent).toList();
      _isLoggingOutDevices = false;
    });
    _showSnackBar('All other sessions have been terminated');
  }

  Widget _buildRememberedDevicesTile() {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      value: _rememberDevices,
      onChanged: (value) async {
        setState(() => _rememberDevices = value);
        await _saveSettingWithFeedback('Remembered devices');
      },
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
          onChanged: (value) async {
            if (value == null) return;
            setState(() => _sessionTimeout = value);
            await _saveSettingWithFeedback('Session timeout');
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
          onChanged: (value) async {
            setState(() => _appLockEnabled = value);
            await _saveSettingWithFeedback('App lock');
          },
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
                      onChanged: (value) async {
                        if (value == null) return;
                        setState(() => _appLockMethod = value);
                        await _saveSettingWithFeedback('Lock method');
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
      onChanged: (value) async {
        setState(() => _hideNotificationContent = value);
        await _saveSettingWithFeedback('Notification privacy');
      },
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
      onChanged: (value) async {
        setState(() => _screenshotProtection = value);
        await _saveSettingWithFeedback('Screenshot protection');
      },
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
      onChanged: (value) async {
        setState(() => _clipboardProtection = value);
        await _saveSettingWithFeedback('Clipboard protection');
      },
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
        onPressed: _openAppSettings,
        child: const Text('Open'),
      ),
    );
  }

  void _openAppSettings() {
    _showSnackBar('Opening system app settings...');
    // In production, use: AppSettings.openAppSettings() from app_settings package
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
            onChanged: (value) async {
              setState(() {
                _permissions[entry.key] = value;
              });
              await _saveSettingWithFeedback('${entry.key} permission');
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
      onChanged: (value) async {
        setState(() => _dataAccessLogEnabled = value);
        await _saveSettingWithFeedback('Data access log');
      },
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
      onChanged: (value) async {
        setState(() => _secureBackupEnabled = value);
        await _saveSettingWithFeedback('Secure backup');
      },
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
      trailing: _isExportingData
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : OutlinedButton(onPressed: _exportData, child: const Text('Export')),
    );
  }

  Future<void> _exportData() async {
    final confirmed = await _showConfirmDialog(
      title: 'Export your data?',
      message:
          'A secure ZIP will be prepared. You will receive a download link that expires after 24 hours.',
      confirmText: 'Export',
    );
    if (!confirmed) return;

    setState(() => _isExportingData = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isExportingData = false);
    _showSnackBar(
      'Export started. You will receive a notification when ready.',
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
      trailing: _isDeletingAccount
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : TextButton(
              onPressed: _requestAccountDeletion,
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Request'),
            ),
    );
  }

  Future<void> _requestAccountDeletion() async {
    final confirmed = await _showConfirmDialog(
      title: 'Delete your account?',
      message:
          'This action is irreversible after 30 days. All your data will be permanently deleted. Evidence linked to legal cases may be retained per policy.',
      confirmText: 'Delete Account',
      isDestructive: true,
    );
    if (!confirmed) return;

    // Second confirmation
    final doubleConfirmed = await _showConfirmDialog(
      title: 'Are you absolutely sure?',
      message: 'Type "DELETE" to confirm. This cannot be undone.',
      confirmText: 'Yes, delete my account',
      isDestructive: true,
    );
    if (!doubleConfirmed) return;

    setState(() => _isDeletingAccount = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isDeletingAccount = false);
    _showSnackBar(
      'Account deletion requested. Check your email for confirmation.',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const _IconBadge(icon: Icons.sos_outlined),
          title: const Text('Emergency contacts / SOS'),
          subtitle: const Text(
            'Configure direct lines, escalation paths, and panic alerts.',
          ),
          trailing: OutlinedButton(
            onPressed: _showEmergencyContactsSheet,
            child: const Text('Manage'),
          ),
        ),
        const SizedBox(height: 12),
        if (_emergencyContacts.isNotEmpty)
          ...(_emergencyContacts.map(
            (contact) => Padding(
              padding: const EdgeInsets.only(left: 56, bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.phone, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contact.name,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          contact.phone,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.call, size: 20),
                    onPressed: () =>
                        _showSnackBar('Calling ${contact.name}...'),
                  ),
                ],
              ),
            ),
          )),
      ],
    );
  }

  void _showEmergencyContactsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Emergency Contacts',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Add on-call supervisors and emergency services. SOS alerts share location and recent incident context.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ..._emergencyContacts.map(
              (contact) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(contact.name),
                subtitle: Text(contact.phone),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.call),
                      onPressed: () {
                        Navigator.pop(context);
                        _showSnackBar('Calling ${contact.name}...');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () {
                        Navigator.pop(context);
                        _showSnackBar('Edit contact (not implemented)');
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showSnackBar('Add contact (not implemented)');
                },
                icon: const Icon(Icons.add),
                label: const Text('Add emergency contact'),
              ),
            ),
          ],
        ),
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
        onPressed: _showSecurityTipsSheet,
        child: const Text('View'),
      ),
    );
  }

  void _showSecurityTipsSheet() {
    final tips = [
      _SecurityTip(
        icon: Icons.verified_user,
        title: 'Verify identities',
        description: 'Always confirm who you are sharing sensitive data with.',
      ),
      _SecurityTip(
        icon: Icons.lock,
        title: 'Lock devices',
        description: 'Never leave devices unattended without locking them.',
      ),
      _SecurityTip(
        icon: Icons.report_problem,
        title: 'Report suspicious activity',
        description: 'If something seems off, report it immediately.',
      ),
      _SecurityTip(
        icon: Icons.system_update,
        title: 'Keep software updated',
        description: 'Install security patches as soon as they are available.',
      ),
      _SecurityTip(
        icon: Icons.wifi_lock,
        title: 'Use secure networks',
        description: 'Avoid public Wi-Fi for sensitive operations.',
      ),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Security Tips',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: tips.length,
                separatorBuilder: (context, index) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  final tip = tips[index];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        tip.icon,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tip.title,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tip.description,
                              style: Theme.of(context).textTheme.bodyMedium,
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
        onPressed: _showReportIssueSheet,
        child: const Text('Contact'),
      ),
    );
  }

  void _showReportIssueSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report a Security Issue',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.email_outlined),
              title: const Text('Email'),
              subtitle: const Text('security@lindav.app'),
              onTap: () {
                Navigator.pop(context);
                Clipboard.setData(
                  const ClipboardData(text: 'security@lindav.app'),
                );
                _showSnackBar('Email copied to clipboard');
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.description_outlined),
              title: const Text('In-app form'),
              subtitle: const Text('Submit with reproduction steps'),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('Opening report form...');
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Please include reproduction steps and screenshots if possible.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
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
    required this.icon,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final IconData icon;

  static const Color _emerald = Color(0xFF059669);
  static const Color _green = Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _emerald.withAlpha(30)),
        boxShadow: [
          BoxShadow(
            color: _emerald.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_emerald, _green],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _emerald.withAlpha(100),
                    _green.withAlpha(50),
                    Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            const SizedBox(height: 12),
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
        result.add(Divider(height: 24, color: Colors.grey.shade200));
      }
    }
    return result;
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon});

  final IconData icon;

  static const Color _emerald = Color(0xFF059669);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _emerald.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: _emerald, size: 22),
    );
  }
}

class _GuidanceChip extends StatelessWidget {
  const _GuidanceChip({required this.label});

  final String label;

  static const Color _emerald = Color(0xFF059669);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _emerald.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _emerald.withAlpha(50)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: _emerald,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _DeviceSession {
  const _DeviceSession({
    required this.id,
    required this.name,
    required this.location,
    required this.lastActive,
    required this.isCurrent,
  });

  final String id;
  final String name;
  final String location;
  final String lastActive;
  final bool isCurrent;
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({
    required this.session,
    required this.onTap,
    required this.onRemove,
    required this.theme,
  });

  final _DeviceSession session;
  final VoidCallback onTap;
  final VoidCallback? onRemove;
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  session.isCurrent ? Icons.phone_android : Icons.devices_other,
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
                if (!session.isCurrent && onRemove != null)
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 20,
                      color: theme.colorScheme.error,
                    ),
                    onPressed: onRemove,
                    tooltip: 'End session',
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmergencyContact {
  const _EmergencyContact({required this.name, required this.phone});

  final String name;
  final String phone;
}

class _SecurityTip {
  const _SecurityTip({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isChanging = false;

  double get _passwordStrength {
    final password = _newPasswordController.text;
    if (password.isEmpty) return 0;

    double strength = 0;
    if (password.length >= 8) strength += 0.2;
    if (password.length >= 12) strength += 0.2;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.15;
    if (RegExp(r'[a-z]').hasMatch(password)) strength += 0.15;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.15;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.15;

    return strength.clamp(0.0, 1.0);
  }

  String get _strengthLabel {
    final strength = _passwordStrength;
    if (strength < 0.3) return 'Weak';
    if (strength < 0.6) return 'Fair';
    if (strength < 0.8) return 'Good';
    return 'Strong';
  }

  Color get _strengthColor {
    final strength = _passwordStrength;
    if (strength < 0.3) return Colors.red;
    if (strength < 0.6) return Colors.orange;
    if (strength < 0.8) return Colors.yellow.shade700;
    return Colors.green;
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_currentPasswordController.text.isEmpty) {
      _showError('Please enter your current password');
      return;
    }
    if (_newPasswordController.text.length < 8) {
      _showError('New password must be at least 8 characters');
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }
    if (_passwordStrength < 0.5) {
      _showError('Please choose a stronger password');
      return;
    }

    setState(() => _isChanging = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Change Password'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _currentPasswordController,
              obscureText: _obscureCurrent,
              decoration: InputDecoration(
                labelText: 'Current password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCurrent ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      setState(() => _obscureCurrent = !_obscureCurrent),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              obscureText: _obscureNew,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'New password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNew ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
              ),
            ),
            if (_newPasswordController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _passwordStrength,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(_strengthColor),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _strengthLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _strengthColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _RequirementChip(
                    label: '12+ chars',
                    met: _newPasswordController.text.length >= 12,
                  ),
                  _RequirementChip(
                    label: 'Uppercase',
                    met: RegExp(r'[A-Z]').hasMatch(_newPasswordController.text),
                  ),
                  _RequirementChip(
                    label: 'Number',
                    met: RegExp(r'[0-9]').hasMatch(_newPasswordController.text),
                  ),
                  _RequirementChip(
                    label: 'Symbol',
                    met: RegExp(
                      r'[!@#$%^&*(),.?":{}|<>]',
                    ).hasMatch(_newPasswordController.text),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                labelText: 'Confirm new password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isChanging ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isChanging ? null : _changePassword,
          child: _isChanging
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Change Password'),
        ),
      ],
    );
  }
}

class _RequirementChip extends StatelessWidget {
  const _RequirementChip({required this.label, required this.met});

  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: met
            ? Colors.green.withAlpha(30)
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: met ? Colors.green : Colors.transparent),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            met ? Icons.check : Icons.circle_outlined,
            size: 14,
            color: met ? Colors.green : Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: met
                  ? Colors.green
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
