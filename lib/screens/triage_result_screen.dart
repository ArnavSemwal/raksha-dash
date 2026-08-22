import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vitals_model.dart';
import '../providers/triage_provider.dart';
import '../providers/triage_state.dart';
import '../widgets/app_header.dart';
import 'base.dart';

/// Native Flutter implementation of AI Triage Result Screen (from result HTML spec).
/// Mobile-constrained layout matching original HTML/CSS design specification.
class TriageResultScreen extends StatefulWidget {
  final VitalsModel? vitals;

  const TriageResultScreen({
    super.key,
    this.vitals,
  });

  @override
  State<TriageResultScreen> createState() => _TriageResultScreenState();
}

class _TriageResultScreenState extends State<TriageResultScreen> {
  bool _isSyncing = false;

  static const Color _onSurface = Color(0xFF1C1B1B);
  static const Color _outline = Color(0xFF737686);
  static const Color _cardBorder = Color(0xFFE5E7EB);
  static const Color _primaryCobalt = Color(0xFF004AC6);

  // Verdict green constants (#F0FDF4 & #22C55E)
  static const Color _verdictBg = Color(0xFFF0FDF4);
  static const Color _verdictGreen = Color(0xFF22C55E);

  Future<void> _handleSyncToCloud() async {
    setState(() {
      _isSyncing = true;
    });

    try {
      final triageProvider = Provider.of<TriageProvider>(context, listen: false);
      final success = await triageProvider.syncDataToCloud();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '✅ Telemetry successfully synced to Cloud backend!'
                : '💾 Network unavailable — Telemetry cached offline safely.',
            style: const TextStyle(fontFamily: 'Space Mono'),
          ),
          backgroundColor: success ? const Color(0xFF22C55E) : const Color(0xFF004AC6),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sync error: $e',
            style: const TextStyle(fontFamily: 'Space Mono'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  void _handleFinishAndReturn() {
    // Reset state for new patient
    Provider.of<TriageState>(context, listen: false).reset();
    Provider.of<TriageProvider>(context, listen: false).resetAll();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const BaseScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vitals = widget.vitals;
    final String triageText = vitals?.triage ?? 'LOW RISK (STABLE)';
    final String confidenceText = 'AI Confidence: ${((vitals?.confidence ?? 0.94) * 100).toStringAsFixed(0)}%';
    final String patientIdText = 'Patient ID: ${vitals?.patientId ?? "RX-2049"}';

    final String spo2Text = '${vitals?.spo2.toStringAsFixed(0) ?? "98"}%';
    final String hrText = '${vitals?.ecgHr.toStringAsFixed(0) ?? "72"} BPM';
    final String tempText = '${vitals?.temperature.toStringAsFixed(1) ?? "98.6"}°F';
    const String urineText = 'NORMAL';
    final String lungsText = (vitals?.stethoscopeStatus ?? 'CLEAR').toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF0EDEC), // Neutral desktop backdrop
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Container(
              color: const Color(0xFFF9FAFB),
              child: Column(
                children: [
                  // TOP APP BAR HEADER
                  const AppHeader(),

                  // MAIN CONTENT AREA
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 14.0,
                      ),
                      child: Column(
                        children: [
                          // VERDICT BANNER
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: _verdictBg,
                              border: Border.all(color: _verdictGreen, width: 2.0),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 48.0,
                                  height: 48.0,
                                  decoration: const BoxDecoration(
                                    color: _verdictGreen,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        triageText,
                                        style: const TextStyle(
                                          fontFamily: 'Space Mono',
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: _onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        confidenceText,
                                        style: const TextStyle(
                                          fontFamily: 'Space Mono',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: _outline,
                                        ),
                                      ),
                                      Text(
                                        patientIdText,
                                        style: const TextStyle(
                                          fontFamily: 'Space Mono',
                                          fontSize: 13,
                                          color: _outline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // VITALS LIST (5 Rows)
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  child: _buildResultRow(
                                    icon: Icons.air,
                                    label: 'SPO2',
                                    value: spo2Text,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Expanded(
                                  child: _buildResultRow(
                                    icon: Icons.favorite,
                                    label: 'HR',
                                    value: hrText,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Expanded(
                                  child: _buildResultRow(
                                    icon: Icons.thermostat,
                                    label: 'TEMP',
                                    value: tempText,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Expanded(
                                  child: _buildResultRow(
                                    icon: Icons.water_drop,
                                    label: 'URINE',
                                    value: urineText,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Expanded(
                                  child: _buildResultRow(
                                    icon: Icons.medical_services,
                                    label: 'LUNGS',
                                    value: lungsText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // FOOTER ACTIONS
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20.0,
                      right: 20.0,
                      bottom: 20.0,
                      top: 4.0,
                    ),
                    child: Column(
                      children: [
                        // Button 1: Sync Data to Cloud
                        SizedBox(
                          width: double.infinity,
                          height: 52.0,
                          child: ElevatedButton.icon(
                            onPressed: _isSyncing ? null : _handleSyncToCloud,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryCobalt,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: const StadiumBorder(),
                            ),
                            icon: _isSyncing
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.cloud_sync, size: 20),
                            label: Text(
                              _isSyncing ? 'Syncing...' : 'Sync Data to Cloud',
                              style: const TextStyle(
                                fontFamily: 'Space Mono',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Button 2: Finish & Return to Home
                        SizedBox(
                          width: double.infinity,
                          height: 52.0,
                          child: OutlinedButton(
                            onPressed: _handleFinishAndReturn,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: _primaryCobalt,
                              side: const BorderSide(color: _primaryCobalt, width: 2.0),
                              shape: const StadiumBorder(),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'Finish & Return to Home',
                                  style: TextStyle(
                                    fontFamily: 'Space Mono',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: _primaryCobalt,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward,
                                  color: _primaryCobalt,
                                  size: 20,
                                ),
                              ],
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
        ),
      ),
    );
  }

  /// Helper to build Vital Result Row matching HTML spec
  Widget _buildResultRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _cardBorder, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: _outline, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Space Mono',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _onSurface,
                    ),
                  ),
                ],
              ),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Space Mono',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _onSurface,
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 10.0,
              height: 10.0,
              decoration: const BoxDecoration(
                color: _verdictGreen,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
