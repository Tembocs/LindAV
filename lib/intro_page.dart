import 'package:flutter/material.dart';

import 'home_page.dart';
import 'network_status_page.dart';
import 'scan_page.dart';
import 'tests_page.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton.icon(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const HomePage()),
                  ),
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text('Skip to Home'),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Meet Lindav Security',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose how you want to begin. You can run a scan, take security readiness tests, or inspect your network connection.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView(
                  children: [
                    // _BrandHero(colorScheme: colorScheme),
                    const SizedBox(height: 24),
                    _IntroTile(
                      icon: Icons.shield,
                      title: 'Start Scanning',
                      description:
                          'Perform quick, full, or USB scans to check for suspicious files on your device.',
                      color: colorScheme.primary,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ScanPage()),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _IntroTile(
                      icon: Icons.quiz_outlined,
                      title: 'Take Security Tests',
                      description:
                          'Practice phishing recognition, verify backup procedures, and review password policies.',
                      color: colorScheme.secondary,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const TestsPage()),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _IntroTile(
                      icon: Icons.wifi,
                      title: 'Check Network Health',
                      description:
                          'Measure your connectivity quality, speed, and latency for safer browsing.',
                      color: colorScheme.tertiary,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NetworkStatusPage(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _IntroTile(
                      icon: Icons.home_outlined,
                      title: 'Go to Dashboard',
                      description:
                          'View quick actions and manage your protection experience from the central hub.',
                      color: colorScheme.primaryContainer,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const HomePage()),
                      ),
                      foregroundOverride: colorScheme.onPrimaryContainer,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroTile extends StatelessWidget {
  const _IntroTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
    this.foregroundOverride,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;
  final Color? foregroundOverride;

  @override
  Widget build(BuildContext context) {
    final foreground = foregroundOverride ?? Colors.white;

    return Material(
      borderRadius: BorderRadius.circular(20),
      color: color,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: foreground.withOpacity(0.1),
                ),
                child: Icon(icon, color: foreground),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: foreground.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: foreground),
            ],
          ),
        ),
      ),
    );
  }
}

// class _BrandHero extends StatelessWidget {
//   const _BrandHero({required this.colorScheme});

//   final ColorScheme colorScheme;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: colorScheme.surfaceVariant,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(16),
//             child: Image.asset(
//               'assets/logo.png',
//               height: 140,
//               fit: BoxFit.cover,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'JERMAN TECHNOLOGY',
//             style: Theme.of(
//               context,
//             ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 6),
//           Text(
//             'Technology with purpose, powering secure experiences.',
//             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//               color: colorScheme.onSurfaceVariant,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
// }
