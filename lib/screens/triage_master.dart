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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TriageProvider>();

    return Scaffold(
      body: PageView(
        controller: provider.pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Page 0: Base / Home Landing Screen
          RakshaTriageHomeScreen(onStartCheck: () => provider.goToNextStep()),

          // ── Page 1: Patient Registration (Tera Asli UI) ──────────────
          RakshaPatientRegistrationScreen(
            patientId: provider.patientInfo.id,
            progressFraction: 0.125,

            // Jab user "Proceed to Vitals" dabaye, tab next page par jaye
            onProceedPressed: () {
              provider.goToNextStep();
            },
          ),

          // Page 2: Stethoscope Step
          StethoscopeScanStep(
            status: provider.stethStatus,
            patientId: provider.patientInfo.id,
            currentStep: 2,
            totalSteps: TriageProvider.totalPages,
            onPrimaryPressed: provider.stethStatus == ScanStatus.initial
                ? () => provider.runStethScan()
                : () => provider.goToNextStep(),
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
            onStartRecordingPressed: () => provider.runEcgScan(),
            onRetakePressed: () => provider.resetEcgScan(),
            onProceedPressed: () => provider.goToNextStep(),
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
            onStartMeasurementPressed: () => provider.runBpScan(),
            onRetakePressed: () => provider.resetBpScan(),
            onProceedPressed: () => provider.goToNextStep(),
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
            onStartMeasurementPressed: () => provider.runSpo2TempScan(),
            onRetakePressed: () => provider.resetSpo2TempScan(),
            onProceedPressed: () => provider.goToNextStep(),
          ),

          // Page 6: Urine Analysis Step
          RakshaUrineAnalysisScreen(
            status: provider.urineStatus,
            patientId: provider.patientInfo.id,
            currentStep: 6,
            totalSteps: TriageProvider.totalPages,
            onStartScanPressed: () => provider.runUrineScan(),
            onRetakePressed: () => provider.resetUrineScan(),
            onFinishPressed: () => provider.goToNextStep(),
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

            // ── THE MAGIC HAPPENS HERE ──
            onSyncCloudPressed: () async {
              // 1. Screen par ek loading spinner overlay daal do
              showDialog(
                context: context,
                barrierDismissible: false, // User touch karke hata na sake
                builder: (context) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );

              // 2. API Call fire kar
              final success = await provider.syncDataToCloud();

              // 3. API response aate hi loading spinner hatao
              if (context.mounted) {
                Navigator.of(context).pop();

                // 4. Success ya Error ka Snackbar dikhao
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
      ),
    );
  }
}
