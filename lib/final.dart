import 'package:flutter/material.dart';

enum TriageResultStatus {
  green, // Stable / Home care
  red, // Urgent attention required
}

/// Production-ready, pixel-perfect StatelessWidget for Final Triage & Summary UI.
class RakshaFinalTriageScreen extends StatelessWidget {
  final TriageResultStatus triageStatus;
  final String patientId;
  final String dateString;
  final String heartRate;
  final String bloodPressure;
  final String spo2;
  final String temperature;
  final String summaryText;
  final VoidCallback? onSyncCloudPressed;
  final VoidCallback? onReturnHomePressed;

  const RakshaFinalTriageScreen({
    super.key,
    this.triageStatus = TriageResultStatus.green,
    this.patientId = 'PT-XXXX',
    this.dateString = '17 Aug 2026, 10:00 AM',
    this.heartRate = '78.5',
    this.bloodPressure = '120/80',
    this.spo2 = '97',
    this.temperature = '36.8',
    this.summaryText = 'Patient vitals are within normal clinical thresholds. Safe for home care or local follow-up.',
    this.onSyncCloudPressed,
    this.onReturnHomePressed,
  });

  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color darkText = Color(0xFF111827);
  static const Color secondaryText = Color(0xFF434655);
  static const Color subtextColor = Color(0xFF6B7280);
  static const Color containerBg = Color(0xFFF3F4F6);
  static const Color borderGray = Color(0xFFE5E7EB);

  static const Color greenBg = Color(0xFFD1FAE5);
  static const Color greenBorder = Color(0xFF047857);
  static const Color greenText = Color(0xFF047857);

  static const Color redBg = Color(0xFFFFEBEB);
  static const Color redBorder = Color(0xFFD32F2F);
  static const Color redText = Color(0xFFD32F2F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Progress Bar
                Container(
                  height: 4.0,
                  width: double.infinity,
                  color: primaryBlue,
                ),
                const SizedBox(height: 16),

                _buildHeader(),
                const SizedBox(height: 20),

                _buildStepInfo(),
                const SizedBox(height: 20),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildSummaryCardContainer(),
                        const SizedBox(height: 24),
                        _buildClinicalSummaryText(),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                _buildBottomButtons(),
              ],
            ),
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
        const Text(
          'Final Triage &\nSummary',
          style: TextStyle(
            color: darkText,
            fontFamily: 'Inter',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 6.0,
              ),
              decoration: BoxDecoration(
                color: containerBg,
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
            const SizedBox(height: 4),
            Text(
              dateString,
              style: const TextStyle(
                color: subtextColor,
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCardContainer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: borderGray, width: 1.0),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'HEART RATE',
                  value: heartRate,
                  unit: 'BPM',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'BLOOD PRESSURE',
                  value: bloodPressure,
                  unit: 'mmHg',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(title: 'SPO2', value: spo2, unit: '%'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'TEMP',
                  value: temperature,
                  unit: '°C',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTriageStatusBanner(),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String unit,
  }) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: borderGray, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: subtextColor,
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: darkText,
                  fontFamily: 'Inter',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(
                  color: subtextColor,
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTriageStatusBanner() {
    final bool isGreen = (triageStatus == TriageResultStatus.green);
    final Color bgColor = isGreen ? greenBg : redBg;
    final Color borderColor = isGreen ? greenBorder : redBorder;
    final Color textColor = isGreen ? greenText : redText;
    final IconData icon = isGreen
        ? Icons.check_circle_rounded
        : Icons.warning_amber_rounded;
    final String text = isGreen
        ? 'TRIAGE STATUS: GREEN (STABLE)'
        : 'TRIAGE STATUS: RED (URGENT ATTENTION)';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: 22),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalSummaryText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        summaryText,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: secondaryText,
          fontFamily: 'Inter',
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: onSyncCloudPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child: const Text(
              'Sync Data to Cloud',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 54,
          child: OutlinedButton(
            onPressed: onReturnHomePressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryBlue,
              side: const BorderSide(color: primaryBlue, width: 2.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Finish & Return to Home',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: primaryBlue,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 20, color: primaryBlue),
              ],
            ),
          ),
        ),
      ],
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
