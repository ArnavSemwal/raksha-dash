import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Provider Import
import '../providers/triage_provider.dart';

// Screen Imports (Mapped strictly to your VS Code sidebar structure)
import 'base.dart';
import 'register.dart';
import 'stethoscope_screen.dart';
import '../ecg.dart';
import '../bp.dart';
import '../spo2temp.dart';
import '../urine.dart';
import '../final.dart';

/// Master wrapper hosting all 8 triage steps inside a PageView.
class TriageMaster extends StatelessWidget {
  const TriageMaster({super.key});

  /// Helper to trigger non-dismissible CircularProgressIndicator dialog,
  /// simulate 3-second AI processing delay, safely pop dialog, and execute action.
  Future<void> _runWithAiDelay(BuildContext context, VoidCallback action) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    await Future.delayed(const Duration(seconds: 3));

    if (context.mounted) {
      Navigator.of(context).pop();
      action();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TriageProvider>();

    return PageView(
      controller: provider.pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Page 0: Base / Home Landing Screen
        RakshaTriageHomeScreen(
          onStartCheck: () => provider.goToNextStep(),
        ),

        // ── Page 1: Patient Registration ──────────────
        RakshaPatientRegistrationScreen(
          patientId: provider.patientInfo.id,
          progressFraction: 0.125,
          selectedGender: provider.patientInfo.gender.isEmpty
              ? null
              : provider.patientInfo.gender,
          onGenderChanged: (gender) {
            provider.setGender(gender);
          },
          onProceedPressed: () => _runWithAiDelay(context, () => provider.goToNextStep()),
        ),

        // Page 2: Stethoscope Step
        StethoscopeScanStep(
          status: provider.stethStatus,
          patientId: provider.patientInfo.id,
          currentStep: 2,
          totalSteps: TriageProvider.totalPages,
          onPrimaryPressed: provider.stethStatus == ScanStatus.initial
              ? () => _runWithAiDelay(context, () => provider.runStethScan())
              : () => _runWithAiDelay(context, () => provider.goToNextStep()),
        ),

        // Page 3: ECG Step
        RakshaEcgScreen(
          status: provider.ecgStatus,
          patientId: provider.patientInfo.id,
          currentStep: 3,
          totalSteps: TriageProvider.totalPages,
          heartRateReading: provider.ecgResult != null
              ? '${provider.ecgResult!.heartRate.toStringAsFixed(0)} BPM'
              : '-- BPM',
          onStartRecordingPressed: () => _runWithAiDelay(context, () => provider.runEcgScan()),
          onRetakePressed: () => provider.resetEcgScan(),
          onProceedPressed: () => _runWithAiDelay(context, () => provider.goToNextStep()),
        ),

        // Page 4: Blood Pressure Step
        RakshaBloodPressureScreen(
          status: provider.bpStatus,
          patientId: provider.patientInfo.id,
          currentStep: 4,
          totalSteps: TriageProvider.totalPages,
          bpReading: provider.bpResult != null
              ? '${provider.bpResult!.formatted} mmHg'
              : '-- mmHg',
          onStartMeasurementPressed: () => _runWithAiDelay(context, () => provider.runBpScan()),
          onRetakePressed: () => provider.resetBpScan(),
          onProceedPressed: () => _runWithAiDelay(context, () => provider.goToNextStep()),
        ),

        // Page 5: SpO2 + Temperature Step
        RakshaSpo2TempScreen(
          status: provider.spo2TempStatus,
          patientId: provider.patientInfo.id,
          currentStep: 5,
          totalSteps: TriageProvider.totalPages,
          spo2Reading: provider.spo2TempResult != null
              ? '${provider.spo2TempResult!.spo2}%'
              : '--%',
          tempReading: provider.spo2TempResult != null
              ? '${provider.spo2TempResult!.temperature}°C'
              : '--°C',
          onStartMeasurementPressed: () => _runWithAiDelay(context, () => provider.runSpo2TempScan()),
          onRetakePressed: () => provider.resetSpo2TempScan(),
          onProceedPressed: () => _runWithAiDelay(context, () => provider.goToNextStep()),
        ),

        // Page 6: Urine Analysis Step
        RakshaUrineAnalysisScreen(
          status: provider.urineStatus,
          patientId: provider.patientInfo.id,
          currentStep: 6,
          totalSteps: TriageProvider.totalPages,
          onStartScanPressed: () => _runWithAiDelay(context, () => provider.runUrineScan()),
          onRetakePressed: () => provider.resetUrineScan(),
          onFinishPressed: () => _runWithAiDelay(context, () => provider.goToNextStep()),
        ),

        // ── Page 7: Final Triage Summary ──────────────────────────────────────
        RakshaFinalTriageScreen(
          triageStatus: provider.hasAnyAbnormal
              ? TriageResultStatus.red
              : TriageResultStatus.green,
          patientId: provider.patientInfo.id,
          heartRate: provider.stethResult != null
              ? provider.stethResult!.heartRate.toStringAsFixed(1)
              : '--',
          bloodPressure: provider.bpResult?.formatted ?? '--/--',
          spo2: provider.spo2TempResult != null
              ? '${provider.spo2TempResult!.spo2}'
              : '--',
          temperature: provider.spo2TempResult != null
              ? '${provider.spo2TempResult!.temperature}'
              : '--',
          summaryText: provider.hasAnyAbnormal
              ? 'One or more vitals are outside safe thresholds. Urgent clinical attention recommended.'
              : 'All vitals are within normal clinical thresholds. Safe for home care or local follow-up.',

          // ── Cloud Sync with AI Delay ──
          onSyncCloudPressed: () async {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return const Center(child: CircularProgressIndicator());
              },
            );

            await Future.delayed(const Duration(seconds: 3));

            final success = await provider.syncDataToCloud();

            if (context.mounted) {
              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? "Cloud Sync Successful! Patient data secured. 🚀"
                        : "Sync Failed. Saved offline, will retry later. ⚠️",
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  backgroundColor: success
                      ? const Color(0xFF047857)
                      : const Color(0xFFDC2626),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
            }
          },
          onReturnHomePressed: () => provider.resetAll(),
        ),
      ],
    );
  }
}
