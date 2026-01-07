import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'services/network_service.dart';
import 'widgets/network_status_widget.dart';

class NetworkStatusPage extends StatefulWidget {
  const NetworkStatusPage({super.key});

  @override
  State<NetworkStatusPage> createState() => _NetworkStatusPageState();
}

class _NetworkStatusPageState extends State<NetworkStatusPage>
    with SingleTickerProviderStateMixin {
  final NetworkService _networkService = NetworkService();
  late TabController _tabController;

  bool _isScanning = false;
  List<WiFiNetwork> _availableNetworks = [];
  List<SavedWiFiNetwork> _savedNetworks = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSavedNetworks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadSavedNetworks() {
    // Simulated saved networks (in production, use platform channels)
    _savedNetworks = [
      SavedWiFiNetwork(
        ssid: 'Home_Network_5G',
        password: 'MySecurePass123!',
        security: 'WPA3',
        frequency: '5 GHz',
        savedDate: DateTime.now().subtract(const Duration(days: 30)),
        autoConnect: true,
      ),
      SavedWiFiNetwork(
        ssid: 'Office_WiFi',
        password: 'WorkPass2024#',
        security: 'WPA2-Enterprise',
        frequency: '2.4 GHz',
        savedDate: DateTime.now().subtract(const Duration(days: 90)),
        autoConnect: true,
      ),
      SavedWiFiNetwork(
        ssid: 'CoffeeShop_Guest',
        password: 'coffee2024',
        security: 'WPA2',
        frequency: '2.4 GHz',
        savedDate: DateTime.now().subtract(const Duration(days: 7)),
        autoConnect: false,
      ),
    ];
  }

  Future<void> _scanForNetworks() async {
    setState(() => _isScanning = true);

    // Simulate network scanning delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulated available networks (in production, use wifi_scan package)
    _availableNetworks = [
      WiFiNetwork(
        ssid: 'Home_Network_5G',
        bssid: 'AA:BB:CC:DD:EE:01',
        signalStrength: -45,
        frequency: 5180,
        security: 'WPA3',
        isConnected: true,
        channel: 36,
      ),
      WiFiNetwork(
        ssid: 'Neighbor_WiFi',
        bssid: 'AA:BB:CC:DD:EE:02',
        signalStrength: -65,
        frequency: 2437,
        security: 'WPA2',
        isConnected: false,
        channel: 6,
      ),
      WiFiNetwork(
        ssid: 'Office_WiFi',
        bssid: 'AA:BB:CC:DD:EE:03',
        signalStrength: -72,
        frequency: 2412,
        security: 'WPA2-Enterprise',
        isConnected: false,
        channel: 1,
      ),
      WiFiNetwork(
        ssid: 'Guest_Network',
        bssid: 'AA:BB:CC:DD:EE:04',
        signalStrength: -78,
        frequency: 5240,
        security: 'Open',
        isConnected: false,
        channel: 48,
      ),
      WiFiNetwork(
        ssid: 'IoT_Devices',
        bssid: 'AA:BB:CC:DD:EE:05',
        signalStrength: -55,
        frequency: 2462,
        security: 'WPA2',
        isConnected: false,
        channel: 11,
      ),
      WiFiNetwork(
        ssid: 'Hidden_Network',
        bssid: 'AA:BB:CC:DD:EE:06',
        signalStrength: -82,
        frequency: 5745,
        security: 'WPA3',
        isConnected: false,
        channel: 149,
        isHidden: true,
      ),
    ];

    setState(() => _isScanning = false);
    _showSnackBar('Found ${_availableNetworks.length} networks');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final status = _networkService.currentStatus;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Status'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.speed),
            tooltip: 'Run Speed Test',
            onPressed: _networkService.isTestingSpeed ? null : _runSpeedTest,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colorScheme.onPrimary,
          labelColor: colorScheme.onPrimary,
          unselectedLabelColor: colorScheme.onPrimary.withAlpha(180),
          tabs: const [
            Tab(icon: Icon(Icons.network_check), text: 'Status'),
            Tab(icon: Icon(Icons.wifi_find), text: 'Scan'),
            Tab(icon: Icon(Icons.save), text: 'Saved'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatusTab(status),
          _buildScanTab(),
          _buildSavedNetworksTab(),
        ],
      ),
    );
  }

  Widget _buildStatusTab(NetworkStatus status) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const NetworkStatusWidget(),
        const SizedBox(height: 24),
        _InfoCard(status: status),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _networkService.isTestingSpeed ? null : _refresh,
          icon: _networkService.isTestingSpeed
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh),
          label: const Text('Refresh Status'),
        ),
      ],
    );
  }

  Widget _buildScanTab() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _availableNetworks.isEmpty
                      ? 'Tap scan to discover nearby WiFi networks'
                      : '${_availableNetworks.length} networks found',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _isScanning ? null : _scanForNetworks,
                icon: _isScanning
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.radar),
                label: Text(_isScanning ? 'Scanning...' : 'Scan'),
              ),
            ],
          ),
        ),
        if (_availableNetworks.isEmpty && !_isScanning)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi_find, size: 64, color: colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    'No networks scanned yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Scan to discover nearby WiFi networks',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _availableNetworks.length,
              itemBuilder: (context, index) {
                final network = _availableNetworks[index];
                return _WiFiNetworkTile(
                  network: network,
                  onTap: () => _showNetworkDetails(network),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSavedNetworksTab() {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        if (_savedNetworks.isEmpty)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wifi_off, size: 64, color: colorScheme.outline),
                const SizedBox(height: 16),
                Text(
                  'No saved networks',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: colorScheme.outline),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap + to add a network manually',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: _savedNetworks.length,
            itemBuilder: (context, index) {
              final network = _savedNetworks[index];
              return _SavedNetworkTile(
                network: network,
                onTap: () => _showSavedNetworkDetails(network),
                onDelete: () => _deleteSavedNetwork(index),
              );
            },
          ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            onPressed: _showAddNetworkDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Network'),
          ),
        ),
      ],
    );
  }

  void _showAddNetworkDialog() {
    final formKey = GlobalKey<FormState>();
    String ssid = '';
    String password = '';
    String security = 'WPA2';
    String frequency = '2.4 GHz';
    bool autoConnect = true;
    bool showPassword = false;

    final securityOptions = [
      'Open',
      'WEP',
      'WPA',
      'WPA2',
      'WPA3',
      'WPA2-Enterprise',
    ];
    final frequencyOptions = ['2.4 GHz', '5 GHz', 'Auto'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;

        return StatefulBuilder(
          builder: (context, setSheetState) => Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colorScheme.outline,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Row(
                      children: [
                        Icon(Icons.add_circle, color: colorScheme.primary),
                        const SizedBox(width: 12),
                        Text(
                          'Add WiFi Network',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // SSID Field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Network Name (SSID)',
                        hintText: 'Enter WiFi network name',
                        prefixIcon: const Icon(Icons.wifi),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter network name';
                        }
                        if (_savedNetworks.any((n) => n.ssid == value.trim())) {
                          return 'Network already exists';
                        }
                        return null;
                      },
                      onSaved: (value) => ssid = value?.trim() ?? '',
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter WiFi password',
                        prefixIcon: const Icon(Icons.key),
                        suffixIcon: IconButton(
                          icon: Icon(
                            showPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setSheetState(() => showPassword = !showPassword);
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      obscureText: !showPassword,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (security != 'Open' &&
                            (value == null || value.isEmpty)) {
                          return 'Password required for secured networks';
                        }
                        if (value != null &&
                            value.isNotEmpty &&
                            value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        return null;
                      },
                      onSaved: (value) => password = value ?? '',
                    ),
                    const SizedBox(height: 16),

                    // Security Type
                    DropdownButtonFormField<String>(
                      initialValue: security,
                      decoration: InputDecoration(
                        labelText: 'Security Type',
                        prefixIcon: const Icon(Icons.security),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: securityOptions.map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (value) {
                        setSheetState(() => security = value ?? 'WPA2');
                      },
                    ),
                    const SizedBox(height: 16),

                    // Frequency Band
                    DropdownButtonFormField<String>(
                      initialValue: frequency,
                      decoration: InputDecoration(
                        labelText: 'Frequency Band',
                        prefixIcon: const Icon(Icons.radio),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: frequencyOptions.map((freq) {
                        return DropdownMenuItem(value: freq, child: Text(freq));
                      }).toList(),
                      onChanged: (value) {
                        setSheetState(() => frequency = value ?? '2.4 GHz');
                      },
                    ),
                    const SizedBox(height: 16),

                    // Auto-connect toggle
                    SwitchListTile(
                      title: const Text('Auto-connect'),
                      subtitle: const Text(
                        'Connect automatically when in range',
                      ),
                      value: autoConnect,
                      onChanged: (value) {
                        setSheetState(() => autoConnect = value);
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (formKey.currentState?.validate() ?? false) {
                                formKey.currentState?.save();
                                _addNetwork(
                                  ssid: ssid,
                                  password: password,
                                  security: security,
                                  frequency: frequency,
                                  autoConnect: autoConnect,
                                );
                                Navigator.pop(context);
                              }
                            },
                            icon: const Icon(Icons.save),
                            label: const Text('Save Network'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _addNetwork({
    required String ssid,
    required String password,
    required String security,
    required String frequency,
    required bool autoConnect,
  }) {
    setState(() {
      _savedNetworks.add(
        SavedWiFiNetwork(
          ssid: ssid,
          password: password,
          security: security,
          frequency: frequency,
          savedDate: DateTime.now(),
          autoConnect: autoConnect,
        ),
      );
    });
    _showSnackBar('Network "$ssid" added successfully');
  }

  void _showNetworkDetails(WiFiNetwork network) {
    final colorScheme = Theme.of(context).colorScheme;
    final savedNetwork = _savedNetworks.firstWhere(
      (s) => s.ssid == network.ssid,
      orElse: () => SavedWiFiNetwork(
        ssid: '',
        password: '',
        security: '',
        frequency: '',
        savedDate: DateTime.now(),
        autoConnect: false,
      ),
    );
    final hasSavedPassword = savedNetwork.ssid.isNotEmpty;

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
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _SignalIcon(signalStrength: network.signalStrength, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                network.isHidden
                                    ? '[Hidden Network]'
                                    : network.ssid,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (network.isConnected)
                              Chip(
                                label: const Text('Connected'),
                                backgroundColor: Colors.green.withAlpha(30),
                                side: BorderSide.none,
                              ),
                          ],
                        ),
                        Text(
                          network.security,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _DetailSection(
                title: 'Network Details',
                items: [
                  _DetailItem(
                    icon: Icons.router,
                    label: 'BSSID (MAC)',
                    value: network.bssid,
                  ),
                  _DetailItem(
                    icon: Icons.signal_cellular_alt,
                    label: 'Signal Strength',
                    value:
                        '${network.signalStrength} dBm (${network.signalQuality})',
                  ),
                  _DetailItem(
                    icon: Icons.radio,
                    label: 'Frequency',
                    value:
                        '${network.frequency} MHz (${network.frequencyBand})',
                  ),
                  _DetailItem(
                    icon: Icons.tune,
                    label: 'Channel',
                    value: '${network.channel}',
                  ),
                  _DetailItem(
                    icon: Icons.lock,
                    label: 'Security',
                    value: network.security,
                  ),
                  if (network.isHidden)
                    const _DetailItem(
                      icon: Icons.visibility_off,
                      label: 'Hidden',
                      value: 'Yes (SSID not broadcast)',
                    ),
                ],
              ),
              if (hasSavedPassword) ...[
                const SizedBox(height: 24),
                _DetailSection(
                  title: 'Saved Credentials',
                  items: [
                    _DetailItem(
                      icon: Icons.key,
                      label: 'Password',
                      value: savedNetwork.password,
                      isPassword: true,
                    ),
                    _DetailItem(
                      icon: Icons.calendar_today,
                      label: 'Saved On',
                      value: _formatDate(savedNetwork.savedDate),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showSnackBar(
                          network.isConnected
                              ? 'Already connected'
                              : 'Connecting to ${network.ssid}...',
                        );
                      },
                      icon: const Icon(Icons.wifi),
                      label: Text(
                        network.isConnected ? 'Connected' : 'Connect',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(
                            text:
                                'SSID: ${network.ssid}\nBSSID: ${network.bssid}\nSecurity: ${network.security}\nChannel: ${network.channel}',
                          ),
                        );
                        Navigator.pop(context);
                        _showSnackBar('Network details copied');
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy Info'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSavedNetworkDetails(SavedWiFiNetwork network) {
    final colorScheme = Theme.of(context).colorScheme;
    bool showPassword = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
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
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(Icons.wifi, size: 32, color: colorScheme.primary),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      network.ssid,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _DetailSection(
                title: 'Network Information',
                items: [
                  _DetailItem(
                    icon: Icons.security,
                    label: 'Security',
                    value: network.security,
                  ),
                  _DetailItem(
                    icon: Icons.radio,
                    label: 'Frequency',
                    value: network.frequency,
                  ),
                  _DetailItem(
                    icon: Icons.calendar_today,
                    label: 'Saved On',
                    value: _formatDate(network.savedDate),
                  ),
                  _DetailItem(
                    icon: Icons.autorenew,
                    label: 'Auto-Connect',
                    value: network.autoConnect ? 'Enabled' : 'Disabled',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                color: colorScheme.primaryContainer.withAlpha(50),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.key, color: colorScheme.primary),
                          const SizedBox(width: 12),
                          const Text('Password'),
                          const Spacer(),
                          IconButton(
                            icon: Icon(
                              showPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setSheetState(() => showPassword = !showPassword);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: network.password),
                              );
                              _showSnackBar('Password copied to clipboard');
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        showPassword
                            ? network.password
                            : '•' * network.password.length,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontFamily: 'monospace',
                              letterSpacing: showPassword ? 0 : 2,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showSnackBar('Connecting to ${network.ssid}...');
                      },
                      icon: const Icon(Icons.wifi),
                      label: const Text('Connect'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showSnackBar('QR Code generation (not implemented)');
                      },
                      icon: const Icon(Icons.qr_code),
                      label: const Text('Share QR'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteSavedNetwork(int index) async {
    final network = _savedNetworks[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forget Network?'),
        content: Text(
          'Remove "${network.ssid}" from saved networks? You will need to enter the password again to reconnect.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Forget'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _savedNetworks.removeAt(index);
      });
      _showSnackBar('Network forgotten');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _runSpeedTest() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text('Speed Test'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Testing network speed...'),
          ],
        ),
      ),
    );

    await _networkService.testNetworkSpeed();

    if (mounted) {
      Navigator.pop(context);
      setState(() {});

      final status = _networkService.currentStatus;
      final speed = status.downloadSpeed?.toStringAsFixed(1) ?? '--';
      final latency = status.latency?.toStringAsFixed(0) ?? '--';
      _showSnackBar('Speed: $speed Mbps | Latency: $latency ms');
    }
  }

  Future<void> _refresh() async {
    await _networkService.testNetworkSpeed();
    if (mounted) {
      setState(() {});
      _showSnackBar('Network status refreshed');
    }
  }
}

// Data Models
class WiFiNetwork {
  final String ssid;
  final String bssid;
  final int signalStrength; // dBm
  final int frequency; // MHz
  final String security;
  final bool isConnected;
  final int channel;
  final bool isHidden;

  WiFiNetwork({
    required this.ssid,
    required this.bssid,
    required this.signalStrength,
    required this.frequency,
    required this.security,
    required this.isConnected,
    required this.channel,
    this.isHidden = false,
  });

  String get signalQuality {
    if (signalStrength >= -50) return 'Excellent';
    if (signalStrength >= -60) return 'Good';
    if (signalStrength >= -70) return 'Fair';
    if (signalStrength >= -80) return 'Weak';
    return 'Very Weak';
  }

  String get frequencyBand {
    return frequency >= 5000 ? '5 GHz' : '2.4 GHz';
  }

  int get signalBars {
    if (signalStrength >= -50) return 4;
    if (signalStrength >= -60) return 3;
    if (signalStrength >= -70) return 2;
    if (signalStrength >= -80) return 1;
    return 0;
  }
}

class SavedWiFiNetwork {
  final String ssid;
  final String password;
  final String security;
  final String frequency;
  final DateTime savedDate;
  final bool autoConnect;

  SavedWiFiNetwork({
    required this.ssid,
    required this.password,
    required this.security,
    required this.frequency,
    required this.savedDate,
    required this.autoConnect,
  });
}

// Widgets
class _WiFiNetworkTile extends StatelessWidget {
  final WiFiNetwork network;
  final VoidCallback onTap;

  const _WiFiNetworkTile({required this.network, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _SignalIcon(signalStrength: network.signalStrength),
        title: Row(
          children: [
            Expanded(
              child: Text(
                network.isHidden ? '[Hidden]' : network.ssid,
                style: TextStyle(
                  fontWeight: network.isConnected
                      ? FontWeight.bold
                      : FontWeight.normal,
                  fontStyle: network.isHidden
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (network.isConnected)
              Icon(Icons.check_circle, size: 18, color: Colors.green),
            if (network.security != 'Open') ...[
              const SizedBox(width: 4),
              Icon(Icons.lock, size: 16, color: colorScheme.outline),
            ],
          ],
        ),
        subtitle: Row(
          children: [
            Text(network.security),
            const SizedBox(width: 8),
            Text('•'),
            const SizedBox(width: 8),
            Text(network.frequencyBand),
            const SizedBox(width: 8),
            Text('•'),
            const SizedBox(width: 8),
            Text('Ch ${network.channel}'),
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: colorScheme.outline),
        onTap: onTap,
      ),
    );
  }
}

class _SignalIcon extends StatelessWidget {
  final int signalStrength;
  final double size;

  const _SignalIcon({required this.signalStrength, this.size = 24});

  @override
  Widget build(BuildContext context) {
    final bars = _getBars();

    Color color;
    if (bars >= 3) {
      color = Colors.green;
    } else if (bars == 2) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    IconData icon;
    if (bars >= 3) {
      icon = Icons.signal_wifi_4_bar;
    } else if (bars == 2) {
      icon = Icons.network_wifi_3_bar;
    } else if (bars == 1) {
      icon = Icons.network_wifi_2_bar;
    } else {
      icon = Icons.signal_wifi_0_bar;
    }

    return Icon(icon, size: size, color: color);
  }

  int _getBars() {
    if (signalStrength >= -50) return 4;
    if (signalStrength >= -60) return 3;
    if (signalStrength >= -70) return 2;
    if (signalStrength >= -80) return 1;
    return 0;
  }
}

class _SavedNetworkTile extends StatelessWidget {
  final SavedWiFiNetwork network;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SavedNetworkTile({
    required this.network,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(Icons.wifi, color: colorScheme.primary),
        ),
        title: Text(network.ssid),
        subtitle: Row(
          children: [
            Text(network.security),
            const SizedBox(width: 8),
            Text('•'),
            const SizedBox(width: 8),
            Text(network.frequency),
            if (network.autoConnect) ...[
              const SizedBox(width: 8),
              Icon(Icons.autorenew, size: 14, color: colorScheme.primary),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'details') {
              onTap();
            } else if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'details',
              child: ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('View Details'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete_outline, color: colorScheme.error),
                title: Text(
                  'Forget',
                  style: TextStyle(color: colorScheme.error),
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final List<_DetailItem> items;

  const _DetailSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => item.build(context)),
      ],
    );
  }
}

class _DetailItem {
  final IconData icon;
  final String label;
  final String value;
  final bool isPassword;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    this.isPassword = false,
  });

  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.outline),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              isPassword ? '••••••••' : value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.status});

  final NetworkStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.speed, color: colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Current Network Stats',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ResultRow(
              label: 'Connection Type',
              value: status.connectionType,
              icon: Icons.wifi,
            ),
            const SizedBox(height: 8),
            _ResultRow(
              label: 'Download Speed',
              value: status.formattedDownloadSpeed,
              icon: Icons.download,
            ),
            const SizedBox(height: 8),
            _ResultRow(
              label: 'Latency',
              value: status.formattedLatency,
              icon: Icons.timer,
            ),
            const SizedBox(height: 16),
            Divider(color: colorScheme.outline.withAlpha(50)),
            const SizedBox(height: 16),
            Text(
              'Tips for a Stable Connection',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _TipRow(
              icon: Icons.router,
              text: 'Place routers centrally, away from obstructions.',
            ),
            const SizedBox(height: 8),
            _TipRow(
              icon: Icons.system_security_update,
              text: 'Keep firmware and OS patches current.',
            ),
            const SizedBox(height: 8),
            _TipRow(
              icon: Icons.security,
              text: 'Use WPA3 encryption for best security.',
            ),
            const SizedBox(height: 12),
            Divider(color: colorScheme.outline.withAlpha(50)),
            const SizedBox(height: 12),
            Text(
              'Last Checked: ${status.lastChecked}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colorScheme.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.label, required this.value, this.icon});

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: colorScheme.outline),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
        ),
        const Spacer(),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
