import 'dart:async';
import 'package:flutter/material.dart';

/// Data model representing each state in the Telemetry Sync sequence with multiple facts.
class TelemetrySyncStep {
  final String status;
  final List<String> facts;
  final IconData icon;

  const TelemetrySyncStep({
    required this.status,
    required this.facts,
    required this.icon,
  });
}

/// Standalone StatefulWidget for the "Telemetry Sync" Loading Screen.
class TelemetrySyncScreen extends StatefulWidget {
  const TelemetrySyncScreen({super.key});

  @override
  State<TelemetrySyncScreen> createState() => _TelemetrySyncScreenState();
}

class _TelemetrySyncScreenState extends State<TelemetrySyncScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;
  Timer? _stepTimer;
  int _currentStepIndex = 0;
  int _loopCycleCounter = 0;

  // The 4 sequential telemetry sync states with 3 facts per sensor
  static const List<TelemetrySyncStep> _syncSteps = [
    TelemetrySyncStep(
      status: 'ESTABLISHING ECG HANDSHAKE...',
      facts: [
        'Resting HR above 100 BPM triggers immediate Tachycardia alerts.',
        'Analyzing P-QRS-T waveforms for ventricular anomalies.',
        'Mapping atrial fibrillation markers via real-time telemetry.',
      ],
      icon: Icons.monitor_heart_outlined,
    ),
    TelemetrySyncStep(
      status: 'CALIBRATING MLX90614 SENSOR...',
      facts: [
        'Core body temp indexed against the normal 36.5°C–37.5°C clinical range.',
        'Scanning peripheral infrared emissions for pyrexia indicators.',
        'Calibrating thermal gradients against ambient room fluctuations.',
      ],
      icon: Icons.device_thermostat_outlined,
    ),
    TelemetrySyncStep(
      status: 'SYNCING MAX30102 OXIMETER...',
      facts: [
        'Clinical SpO2 drops below 92% require high-priority triage.',
        'Measuring arterial pulse propagation and peripheral saturation.',
        'Detecting hypoxemia trends via red and IR light absorption.',
      ],
      icon: Icons.air,
    ),
    TelemetrySyncStep(
      status: 'ANALYZING TCRT3200 STRIP...',
      facts: [
        'Colorimetric analysis detects micro-level ketone & glucose anomalies.',
        'Quantifying pH balance and leukocyte esterase for infection triage.',
        'Mapping specific gravity parameters via optical reflectance.',
      ],
      icon: Icons.science_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Continuous popping/breathing animation setup
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.18).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseController.repeat(reverse: true);

    // 2.5-second interval timer cycling through the 4 states with cycle counter
    _stepTimer = Timer.periodic(const Duration(milliseconds: 2500), (timer) {
      if (mounted) {
        setState(() {
          _currentStepIndex++;
          if (_currentStepIndex >= _syncSteps.length) {
            _currentStepIndex = 0;
            _loopCycleCounter++;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = _syncSteps[_currentStepIndex];
    final String currentFact =
        currentStep.facts[_loopCycleCounter % currentStep.facts.length];
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor != Colors.blue
        ? theme.primaryColor
        : const Color(0xFF004AC6);

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F8),
      body: SafeArea(
        child: Column(
          children: [
            // ── 1. Header (Reference header matching image, NO top progress bar) ──
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFFCF9F8),
                border: Border(
                  bottom: BorderSide(color: Color(0xFF1C1B1B), width: 2.0),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shield,
                    color: primaryColor,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'RAKSHA',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: primaryColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            // ── 2. Dynamic Content Engine (Middle Section with Generous Spacing) ──
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Continuous Popping/Breathing Icon
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: primaryColor.withValues(alpha: 0.3),
                              width: 2.0,
                            ),
                          ),
                          child: Icon(
                            currentStep.icon,
                            size: 48,
                            color: primaryColor,
                          ),
                        ),
                      ),

                      // Generous Breathing Room Spacer 1
                      const SizedBox(height: 48),

                      // Status Message
                      Text(
                        currentStep.status,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1C1B1B),
                          letterSpacing: 0.5,
                          height: 1.3,
                        ),
                      ),

                      // Generous Breathing Room Spacer 2
                      const SizedBox(height: 40),

                      // Clinical Fact / Tip Box
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F3F2),
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: const Color(0xFFC3C6D7),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          currentFact,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF434655),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
