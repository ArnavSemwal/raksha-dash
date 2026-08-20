import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/triage_provider.dart';

/// Native Flutter implementation of the Stitch "RAW VITALS" hardware interface design.
class RakshaHardwareVitalsScreen extends StatelessWidget {
  final VoidCallback? onExecuteTriage;

  const RakshaHardwareVitalsScreen({
    super.key,
    this.onExecuteTriage,
  });

  // Color constants matching Stitch DESIGN.md
  static const Color _bgSurface = Color(0xFFFCF9F8);
  static const Color _surfaceContainerLow = Color(0xFFF6F3F2);
  static const Color _primaryCobalt = Color(0xFF004AC6);
  static const Color _primaryContainer = Color(0xFF2563EB);
  static const Color _onSurface = Color(0xFF1C1B1B);
  static const Color _onSurfaceVariant = Color(0xFF434655);
  static const Color _outlineVariant = Color(0xFFC3C6D7);
  static const Color _outline = Color(0xFF737686);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TriageProvider>();

    // Live readings from TriageProvider with Stitch fallback defaults
    final String spo2Val = provider.spo2TempResult != null
        ? '${provider.spo2TempResult!.spo2}'
        : '98';
    final String hrVal = provider.ecgResult != null
        ? provider.ecgResult!.heartRate.toStringAsFixed(0)
        : (provider.stethResult != null
            ? provider.stethResult!.heartRate.toStringAsFixed(0)
            : '72');
    final String tempVal = provider.spo2TempResult != null
        ? provider.spo2TempResult!.temperature.toStringAsFixed(1)
        : '36.6';
    final String stethRpmVal = '16';

    return Scaffold(
      backgroundColor: _bgSurface,
      body: SafeArea(
        child: Column(
          children: [
            // ── TopAppBar Header with Progress Bar ──────────────────────
            Container(
              decoration: const BoxDecoration(
                color: _bgSurface,
                border: Border(
                  bottom: BorderSide(color: _onSurface, width: 2.0),
                ),
              ),
              child: Column(
                children: [
                  // Progress Bar (Linear Navigation 50%)
                  Container(
                    height: 4,
                    width: double.infinity,
                    color: _outlineVariant.withValues(alpha: 0.3),
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: 0.5,
                      child: Container(color: _primaryContainer),
                    ),
                  ),
                  // App Title Row
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.shield,
                          color: _primaryCobalt,
                          size: 28,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'RAKSHA',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: _primaryCobalt,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Main Content Area ───────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Text
                    const Text(
                      'RAW VITALS',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: _onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Asymmetrical Grid Layout
                    Expanded(
                      child: Column(
                        children: [
                          // Row 1: SpO2 Card (50%) & Heart Rate Card (50%)
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildVitalCard(
                                    icon: Icons.air,
                                    label: 'SPO2',
                                    value: spo2Val,
                                    unit: '%',
                                    sensor: 'SENSOR: MAX30102',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildVitalCard(
                                    icon: Icons.monitor_heart_outlined,
                                    label: 'HR',
                                    value: hrVal,
                                    unit: 'BPM',
                                    sensor: 'SENSOR: ECG module',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Row 2: Temperature Card (100%)
                          Expanded(
                            flex: 1,
                            child: _buildWideVitalCard(
                              icon: Icons.device_thermostat_outlined,
                              label: 'TEMP (CORE)',
                              value: tempVal,
                              unit: '°C',
                              sensor: 'SENSOR: MLX90614',
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Row 3: Stethoscope Rate Card (100%)
                          Expanded(
                            flex: 1,
                            child: _buildWideVitalCard(
                              icon: Icons.medical_services_outlined,
                              label: 'STETHOSCOPE',
                              value: stethRpmVal,
                              unit: 'RPM',
                              sensor: 'SENSOR: MAX4466',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom Action Anchor ────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: _bgSurface,
                border: Border(
                  top: BorderSide(color: _onSurface, width: 2.0),
                ),
              ),
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: onExecuteTriage ?? () => provider.goToNextStep(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryCobalt,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  icon: const Icon(Icons.memory, size: 24),
                  label: const Text(
                    'EXECUTE AI TRIAGE',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper to build standard 50% grid vital card
  Widget _buildVitalCard({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required String sensor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: _surfaceContainerLow,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: _outlineVariant, width: 2.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: _outline, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _onSurfaceVariant,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  color: _onSurface,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: _onSurfaceVariant,
                ),
              ),
            ],
          ),
          Text(
            sensor,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _outline,
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to build 100% full-width grid vital card
  Widget _buildWideVitalCard({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required String sensor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: _surfaceContainerLow,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: _outlineVariant, width: 2.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: _outline, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _onSurfaceVariant,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                      color: _onSurface,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: _onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            sensor,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _outline,
            ),
          ),
        ],
      ),
    );
  }
}
