import 'package:flutter/material.dart';
import 'providers/triage_provider.dart' show ScanStatus;

/// Alias so all existing references to Spo2TempScanStatus compile unchanged.
typedef Spo2TempScanStatus = ScanStatus;

/// Production-ready, pixel-perfect StatelessWidget for Step 4: SpO2 & Temp UI.
class RakshaSpo2TempScreen extends StatelessWidget {
  final Spo2TempScanStatus status;
  final String patientId;
  final int currentStep;
  final int totalSteps;
  final String spo2Reading;
  final String tempReading;
  final VoidCallback? onProceedPressed;
  final VoidCallback? onStartMeasurementPressed;
  final VoidCallback? onRetakePressed;
  final String? illustrationUrl;

  const RakshaSpo2TempScreen({
    super.key,
    this.status = Spo2TempScanStatus.abnormal,
    this.patientId = 'PT-XXXX',
    this.currentStep = 4,
    this.totalSteps = 5,
    this.spo2Reading = '98%',
    this.tempReading = '36.8°C',
    this.onProceedPressed,
    this.onStartMeasurementPressed,
    this.onRetakePressed,
    this.illustrationUrl,
  });

  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color darkText = Color(0xFF111827);
  static const Color secondaryText = Color(0xFF434655);
  static const Color outlineGray = Color(0xFF737686);
  static const Color cardBg = Color(0xFFF9FAFB);
  static const Color borderGray = Color(0xFFE5E7EB);

  static const Color abnormalBg = Color(0xFFFFEBEB);
  static const Color abnormalBorder = Color(0xFFD32F2F);
  static const Color abnormalText = Color(0xFFD32F2F);

  static const Color cleanBg = Color(0xFFD1FAE5);
  static const Color cleanBorder = Color(0xFF047857);
  static const Color cleanText = Color(0xFF047857);

  @override
  Widget build(BuildContext context) {
    final double progressFraction = (totalSteps > 0)
        ? (currentStep / totalSteps).clamp(0.0, 1.0)
        : 0.8;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProgressBar(progressFraction),
                const SizedBox(height: 16),
                _buildHeader(),
                const SizedBox(height: 24),
                _buildStepInfo(),
                const SizedBox(height: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildIllustrationCard(),
                      const SizedBox(height: 20),
                      _buildInstructionText(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildBottomSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(double fraction) {
    return Container(
      height: 4.0,
      width: double.infinity,
      decoration: BoxDecoration(
        color: borderGray,
        borderRadius: BorderRadius.circular(2.0),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: fraction,
        child: Container(
          decoration: BoxDecoration(
            color: primaryBlue,
            borderRadius: BorderRadius.circular(2.0),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomPaint(
          size: const Size(16, 18),
          painter: _RakshaShieldPainter(color: primaryBlue),
        ),
        const SizedBox(width: 8),
        const Text(
          'RAKSHA',
          style: TextStyle(
            color: primaryBlue,
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildStepInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step $currentStep:\nSpO2 & Temp',
          style: const TextStyle(
            color: darkText,
            fontFamily: 'Inter',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: borderGray, width: 1.0),
          ),
          child: Text(
            'ID: $patientId',
            style: const TextStyle(
              color: Color(0xFF374151),
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIllustrationCard() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 220),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: borderGray, width: 1.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: CustomPaint(
          size: const Size(double.infinity, 180),
          painter: _OximeterThermometerPainter(),
        ),
      ),
    );
  }

  Widget _buildInstructionText() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.0),
      child: Text(
        'Place devices securely and keep\npatient silent.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: secondaryText,
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (status == Spo2TempScanStatus.initial) ...[
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: onStartMeasurementPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text(
                'Start Measurement',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ] else if (status == Spo2TempScanStatus.abnormal) ...[
          _buildStatusBanner(
            bgColor: abnormalBg,
            borderColor: abnormalBorder,
            textColor: abnormalText,
            icon: Icons.warning_amber_rounded,
            text: 'WARNING: CRITICAL VITALS DETECTED',
          ),
          const SizedBox(height: 8),
          _buildRetakeLink(),
          const SizedBox(height: 12),
        ] else if (status == Spo2TempScanStatus.clean) ...[
          _buildStatusBanner(
            bgColor: cleanBg,
            borderColor: cleanBorder,
            textColor: cleanText,
            icon: Icons.thermostat_rounded,
            text: 'SPO2: $spo2Reading | TEMP: $tempReading',
          ),
          const SizedBox(height: 8),
          _buildRetakeLink(),
          const SizedBox(height: 12),
        ],

        SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: onProceedPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Proceed to Urine Analysis',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBanner({
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetakeLink() {
    return Center(
      child: GestureDetector(
        onTap: onRetakePressed,
        child: const Text(
          'Tap to Retake',
          style: TextStyle(
            color: outlineGray,
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            decorationColor: outlineGray,
          ),
        ),
      ),
    );
  }
}

class _RakshaShieldPainter extends CustomPainter {
  final Color color;
  _RakshaShieldPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final w = size.width;
    final h = size.height;

    final shieldPath = Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w, h * 0.2)
      ..lineTo(w, h * 0.5)
      ..cubicTo(w, h * 0.8, w * 0.5, h, w * 0.5, h)
      ..cubicTo(w * 0.5, h, 0, h * 0.8, 0, h * 0.5)
      ..lineTo(0, h * 0.2)
      ..close();

    canvas.drawPath(shieldPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _RakshaShieldPainter oldDelegate) => false;
}

class _OximeterThermometerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.5),
      24,
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
