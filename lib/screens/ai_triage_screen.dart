import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// Standalone Flutter screen displaying AI Triage decisions,
/// dynamically visualizing raw RGB urine sensor data in a horizontal row,
/// and providing session sync actions with clean header layout.
class AiTriageScreen extends StatefulWidget {
  final Map<String, dynamic> vitals;
  final int r;
  final int g;
  final int b;
  final String triageStatus;
  final VoidCallback? onReturnHome;

  const AiTriageScreen({
    super.key,
    required this.vitals,
    required this.r,
    required this.g,
    required this.b,
    required this.triageStatus,
    this.onReturnHome,
  });

  @override
  State<AiTriageScreen> createState() => _AiTriageScreenState();
}

class _AiTriageScreenState extends State<AiTriageScreen> {
  bool _isSyncing = false;
  final Random _random = Random();

  // Color constants matching Stitch DESIGN.md
  static const Color _bgSurface = Color(0xFFFCF9F8);
  static const Color _surfaceContainerLow = Color(0xFFF6F3F2);
  static const Color _primaryCobalt = Color(0xFF004AC6);
  static const Color _primaryContainer = Color(0xFF2563EB);
  static const Color _onSurface = Color(0xFF1C1B1B);
  static const Color _onSurfaceVariant = Color(0xFF434655);
  static const Color _outlineVariant = Color(0xFFC3C6D7);
  static const Color _outline = Color(0xFF737686);

  /// Helper class to hold resolved dynamic UI configuration
  WidgetDynamicConfig _getDynamicConfig(String status) {
    switch (status.toUpperCase()) {
      case 'GREEN':
        return WidgetDynamicConfig(
          color: const Color(0xFF388E3C),
          statusText: 'TRIAGE STATUS: GREEN (STABLE)',
          subtext: 'All vitals are within safe thresholds. Clear for standard protocol.',
          icon: Icons.check_circle_outline,
        );
      case 'YELLOW':
        return WidgetDynamicConfig(
          color: const Color(0xFFFFA000),
          statusText: 'TRIAGE STATUS: YELLOW (OBSERVATION)',
          subtext: 'Vitals show mild anomalies. Keep patient under observation.',
          icon: Icons.info_outline,
        );
      case 'RED':
      case 'CRITICAL':
      default:
        return WidgetDynamicConfig(
          color: const Color(0xFFD32F2F),
          statusText: 'TRIAGE STATUS: RED (URGENT ATTENTION)',
          subtext: 'One or more vitals are outside safe thresholds. Urgent clinical attention recommended.',
          icon: Icons.warning_amber_rounded,
        );
    }
  }

  /// Clamps values to valid 0-255 RGB range
  int _clampColor(int val) => val.clamp(0, 255);

  /// Safe RGB Color generator with hardware anomaly protection
  Color _getSafeRgbColor() {
    return Color.fromRGBO(
      _clampColor(widget.r),
      _clampColor(widget.g),
      _clampColor(widget.b),
      1.0,
    );
  }

  /// Triggers 1.5s mock synchronization and triggers randomized success/failure SnackBar
  Future<void> _handleSync() async {
    if (_isSyncing) return;
    setState(() {
      _isSyncing = true;
    });

    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    setState(() {
      _isSyncing = false;
    });

    final bool isSuccess = _random.nextBool();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isSuccess ? const Color(0xFF388E3C) : const Color(0xFF374151),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        content: Text(
          isSuccess
              ? 'Cloud Sync Successful! Patient data secured. 🚀'
              : 'Network offline. Vote encrypted and locked in secure local vault. ⏳',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = _getDynamicConfig(widget.triageStatus);
    final String hrVal = widget.vitals['hr']?.toString() ?? '--';
    final String bpVal = widget.vitals['bp']?.toString() ?? '--/--';
    final String spo2Val = widget.vitals['spo2']?.toString() ?? '--';
    final String tempVal = widget.vitals['temp']?.toString() ?? '--';
    final String formattedDate = DateTime.now().toIso8601String().substring(0, 10);

    return Scaffold(
      backgroundColor: _bgSurface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── 1. The Header Overhaul (Strict image_d022be.png replication) ──
                Container(
                  color: _bgSurface,
                  child: Column(
                    children: [
                      // Top thin blue horizontal line
                      Container(height: 4, color: _primaryContainer),
                      // Shield Icon & Center "RAKSHA" Centered text
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.shield,
                              color: _primaryCobalt,
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'RAKSHA',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: _primaryCobalt,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Divider: Thin grey horizontal line
                      Container(height: 1.5, color: _outlineVariant),
                    ],
                  ),
                ),

                // Main Header Title Row
                Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Final Triage\n& Summary',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _onSurface,
                          height: 1.2,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _surfaceContainerLow,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _outlineVariant, width: 1.5),
                            ),
                            child: const Text(
                              'ID: PT-27609',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _outline,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Main Content Area ──
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── 2. Vitals Grid (2x2 Layout Card) ──
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: _surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(color: _outlineVariant, width: 2.0),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildVitalCell(
                                      icon: Icons.monitor_heart_outlined,
                                      label: 'HEART RATE',
                                      value: hrVal,
                                      unit: ' BPM',
                                    ),
                                  ),
                                  Container(width: 1.5, height: 48, color: _outlineVariant),
                                  Expanded(
                                    child: _buildVitalCell(
                                      icon: Icons.speed_outlined,
                                      label: 'BLOOD PRESSURE',
                                      value: bpVal,
                                      unit: ' mmHg',
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(color: _outlineVariant, thickness: 1.5, height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildVitalCell(
                                      icon: Icons.air_outlined,
                                      label: 'SPO2',
                                      value: spo2Val,
                                      unit: '%',
                                    ),
                                  ),
                                  Container(width: 1.5, height: 48, color: _outlineVariant),
                                  Expanded(
                                    child: _buildVitalCell(
                                      icon: Icons.device_thermostat_outlined,
                                      label: 'TEMP',
                                      value: tempVal,
                                      unit: '°C',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── 3. Triage Badge Display Box ──
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: config.color.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(color: config.color, width: 2.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(config.icon, color: config.color, size: 24),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      config.statusText,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: config.color,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                config.subtext,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _onSurfaceVariant,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Spacer to push visualizer and actions downwards
                        const Spacer(),

                        // ── 4. The RGB Urinalysis Row (Horizontal Row layout matching image_d022a4.png) ──
                        Row(
                          children: [
                            // Left Side: The Color Circle (60x60)
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: _getSafeRgbColor(),
                                shape: BoxShape.circle,
                                border: Border.all(color: _onSurface, width: 2.0),
                              ),
                              child: const Icon(
                                Icons.water_drop_outlined,
                                color: Colors.black26,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Right Side: The Text (Column wrapped in Expanded)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'URINALYSIS REFLECTANCE',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: _outline,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'SENSOR RGB: [${_clampColor(widget.r)}, ${_clampColor(widget.g)}, ${_clampColor(widget.b)}]',
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: _onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // ── 5. Action Anchors (Stacked Buttons) ──
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isSyncing ? null : _handleSync,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryCobalt,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: _isSyncing
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'SYNC DATA TO CLOUD',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 54,
                          child: OutlinedButton(
                            onPressed: widget.onReturnHome,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _onSurface,
                              side: const BorderSide(color: _onSurface, width: 2.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Text(
                              'FINISH & RETURN TO HOME ->',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Helper to build sleek cell display in the vitals grid
  Widget _buildVitalCell({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _outline, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _onSurface,
                ),
              ),
              Text(
                unit,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Helper data class for state styling configuration
class WidgetDynamicConfig {
  final Color color;
  final String statusText;
  final String subtext;
  final IconData icon;

  WidgetDynamicConfig({
    required this.color,
    required this.statusText,
    required this.subtext,
    required this.icon,
  });
}
