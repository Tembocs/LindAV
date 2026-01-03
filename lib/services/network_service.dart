import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Represents the current network status and speed information
class NetworkStatus {
  final bool isConnected;
  final String connectionType;
  final double? downloadSpeed; // in Mbps
  final double? uploadSpeed; // in Mbps (estimated)
  final int? latency; // in milliseconds
  final DateTime lastChecked;

  const NetworkStatus({
    required this.isConnected,
    required this.connectionType,
    this.downloadSpeed,
    this.uploadSpeed,
    this.latency,
    required this.lastChecked,
  });

  String get speedDescription {
    if (!isConnected) return 'No connection';
    if (downloadSpeed == null) return 'Measuring...';
    if (downloadSpeed! >= 100) return 'Very Fast';
    if (downloadSpeed! >= 25) return 'Fast';
    if (downloadSpeed! >= 10) return 'Good';
    if (downloadSpeed! >= 1) return 'Moderate';
    return 'Slow';
  }

  String get formattedDownloadSpeed {
    if (downloadSpeed == null) return '--';
    if (downloadSpeed! >= 1) {
      return '${downloadSpeed!.toStringAsFixed(1)} Mbps';
    }
    return '${(downloadSpeed! * 1000).toStringAsFixed(0)} Kbps';
  }

  String get formattedUploadSpeed {
    if (uploadSpeed == null) return '--';
    if (uploadSpeed! >= 1) {
      return '${uploadSpeed!.toStringAsFixed(1)} Mbps';
    }
    return '${(uploadSpeed! * 1000).toStringAsFixed(0)} Kbps';
  }

  String get formattedLatency {
    if (latency == null) return '--';
    return '$latency ms';
  }

  NetworkStatus copyWith({
    bool? isConnected,
    String? connectionType,
    double? downloadSpeed,
    double? uploadSpeed,
    int? latency,
    DateTime? lastChecked,
  }) {
    return NetworkStatus(
      isConnected: isConnected ?? this.isConnected,
      connectionType: connectionType ?? this.connectionType,
      downloadSpeed: downloadSpeed ?? this.downloadSpeed,
      uploadSpeed: uploadSpeed ?? this.uploadSpeed,
      latency: latency ?? this.latency,
      lastChecked: lastChecked ?? this.lastChecked,
    );
  }
}

/// Service to monitor network connectivity and measure network speed
class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  final _statusController = StreamController<NetworkStatus>.broadcast();
  Stream<NetworkStatus> get statusStream => _statusController.stream;

  NetworkStatus _currentStatus = NetworkStatus(
    isConnected: false,
    connectionType: 'Unknown',
    lastChecked: DateTime.now(),
  );
  NetworkStatus get currentStatus => _currentStatus;

  bool _isTestingSpeed = false;
  bool get isTestingSpeed => _isTestingSpeed;
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize the network service and start monitoring
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    // Check initial connectivity
    await _checkConnectivity();

    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      _handleConnectivityChange(results);
    });
  }

  /// Dispose the service
  void dispose() {
    _connectivitySubscription?.cancel();
    _isInitialized = false;
    _statusController.close();
  }

  Future<void> _checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      await _handleConnectivityChange(results);
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
    }
  }

  Future<void> _handleConnectivityChange(
    List<ConnectivityResult> results,
  ) async {
    final connectionType = _getConnectionType(results);
    final isConnected =
        results.isNotEmpty && !results.contains(ConnectivityResult.none);

    _currentStatus = NetworkStatus(
      isConnected: isConnected,
      connectionType: connectionType,
      downloadSpeed: _currentStatus.downloadSpeed,
      uploadSpeed: _currentStatus.uploadSpeed,
      latency: _currentStatus.latency,
      lastChecked: DateTime.now(),
    );

    _statusController.add(_currentStatus);

    // Auto-test speed when connection changes
    if (isConnected) {
      await testNetworkSpeed();
    }
  }

  String _getConnectionType(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return 'No Connection';
    }

    final types = <String>[];
    for (final result in results) {
      switch (result) {
        case ConnectivityResult.wifi:
          types.add('WiFi');
          break;
        case ConnectivityResult.mobile:
          types.add('Mobile Data');
          break;
        case ConnectivityResult.ethernet:
          types.add('Ethernet');
          break;
        case ConnectivityResult.vpn:
          types.add('VPN');
          break;
        case ConnectivityResult.bluetooth:
          types.add('Bluetooth');
          break;
        case ConnectivityResult.other:
          types.add('Other');
          break;
        case ConnectivityResult.none:
          break;
      }
    }

    return types.isEmpty ? 'Unknown' : types.join(' + ');
  }

  /// Test network speed by downloading a small file
  Future<void> testNetworkSpeed() async {
    if (_isTestingSpeed) return;
    if (!_currentStatus.isConnected) return;

    _isTestingSpeed = true;
    _statusController.add(_currentStatus);

    try {
      // Test latency first
      final latency = await _measureLatency();

      // Test download speed
      final downloadSpeed = await _measureDownloadSpeed();

      // Estimate upload speed (typically 10-20% of download for most connections)
      final uploadSpeed = downloadSpeed != null ? downloadSpeed * 0.15 : null;

      _currentStatus = NetworkStatus(
        isConnected: _currentStatus.isConnected,
        connectionType: _currentStatus.connectionType,
        downloadSpeed: downloadSpeed,
        uploadSpeed: uploadSpeed,
        latency: latency,
        lastChecked: DateTime.now(),
      );

      _statusController.add(_currentStatus);
    } catch (e) {
      debugPrint('Error testing network speed: $e');
    } finally {
      _isTestingSpeed = false;
    }
  }

  Future<int?> _measureLatency() async {
    try {
      final stopwatch = Stopwatch()..start();

      // Try to ping a reliable server
      final result = await InternetAddress.lookup('google.com');

      stopwatch.stop();

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return stopwatch.elapsedMilliseconds;
      }
    } catch (e) {
      debugPrint('Latency test failed: $e');
    }
    return null;
  }

  Future<double?> _measureDownloadSpeed() async {
    try {
      // Use a small file for quick speed test
      // Using Google's generate_204 endpoint for quick connectivity check
      // and a larger file from a CDN for actual speed test

      const testUrls = [
        'https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png',
        'https://www.cloudflare.com/cdn-cgi/trace',
      ];

      double totalBytes = 0;
      final stopwatch = Stopwatch()..start();

      for (final url in testUrls) {
        try {
          final response = await http
              .get(Uri.parse(url))
              .timeout(const Duration(seconds: 10));
          if (response.statusCode == 200) {
            totalBytes += response.bodyBytes.length;
          }
        } catch (e) {
          // Continue with other URLs
        }
      }

      stopwatch.stop();

      if (totalBytes > 0 && stopwatch.elapsedMilliseconds > 0) {
        // Calculate speed in Mbps
        // bytes to bits: * 8
        // ms to seconds: / 1000
        // bits to Mbits: / 1000000
        final speedMbps =
            (totalBytes * 8) / (stopwatch.elapsedMilliseconds / 1000) / 1000000;

        // Since we're using small files, multiply by a factor to estimate real speed
        // This is a rough approximation
        return speedMbps * 2;
      }
    } catch (e) {
      debugPrint('Download speed test failed: $e');
    }
    return null;
  }

  /// Refresh network status and speed
  Future<void> refresh() async {
    await _checkConnectivity();
    if (_currentStatus.isConnected) {
      await testNetworkSpeed();
    }
  }
}
