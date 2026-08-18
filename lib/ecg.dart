import 'package:flutter/material.dart';

/// Status states for the ECG scan step
enum EcgScanStatus {
  /// Initial state before measurement
  initial,

  /// Clean scan completed
  clean,

  /// Abnormal scan reading detected
  abnormal,
}

/// Production-ready, pixel-perfect StatelessWidget for Step 2: ECG UI.
class RakshaEcgScreen extends StatelessWidget {
  final EcgScanStatus status;
  final String patientId;
  final int currentStep;
  final int totalSteps;
  final String heartRateReading;
  final VoidCallback? onProceedPressed;
  final VoidCallback? onStartRecordingPressed;
  final VoidCallback? onRetakePressed;
  final String? illustrationUrl;

  const RakshaEcgScreen({
    super.key,
    this.status = EcgScanStatus.abnormal,
    this.patientId = 'PT-XXXX',
    this.currentStep = 2,
    this.totalSteps = 4,
    this.heartRateReading = '72 BPM',
    this.onProceedPressed,
    this.onStartRecordingPressed,
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
        : 0.25;

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
                // Top Progress Bar
                _buildProgressBar(progressFraction),
                const SizedBox(height: 16),

                // Brand Header Section
                _buildHeader(),
                const SizedBox(height: 24),

                // Step Info & Patient ID Section
                _buildStepInfo(),
                const SizedBox(height: 16),

                // Illustration & Instructions Canvas
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

                // Dynamic Status & Actions Section (Pinned Bottom)
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
          'Step $currentStep:\nECG',
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
    const String defaultUrl =
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBgYvILIBoOI59JUCY3VwNr0sfGZMps-sIqG2CcOgiM2kfAQAL-0MIFixd2teF1ffPH7gQNDO3Zx4Lnn1jOmCIOQOFZ3qIEF-wr5BmBQOCR9R4etFO2hlcSRHaDOY-PwZO6iJnk0GOns2jYbk5fjrZCAAX2RvbxOhmhozpWcemC4tAgCJ8yHiL6A4q4m_8uFfP_dsGP50sXgkNyYb1cjK3zBsUTpG4km4udFZ_PT9ZGmNzIssc8VLnHqZ3QaU2RV-XNFw';

    final String targetUrl = illustrationUrl ?? defaultUrl;

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
        child: Image.network(
          targetUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              _buildFallbackIllustration(),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFallbackIllustration() {
    return CustomPaint(
      size: const Size(double.infinity, 180),
      painter: _ChestLeadsPainter(),
    );
  }

  Widget _buildInstructionText() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.0),
      child: Text(
        "Ensure all leads are securely\nattached to the patient's chest\nas shown.",
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
        if (status == EcgScanStatus.initial) ...[
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: onStartRecordingPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text(
                'Start ECG Recording',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ] else if (status == EcgScanStatus.abnormal) ...[
          _buildStatusBanner(
            bgColor: abnormalBg,
            borderColor: abnormalBorder,
            textColor: abnormalText,
            icon: Icons.warning_amber_rounded,
            text: 'WARNING: ABNORMAL HEART RATE',
          ),
          const SizedBox(height: 8),
          _buildRetakeLink(),
          const SizedBox(height: 12),
        ] else if (status == EcgScanStatus.clean) ...[
          _buildStatusBanner(
            bgColor: cleanBg,
            borderColor: cleanBorder,
            textColor: cleanText,
            icon: Icons.monitor_heart_outlined,
            text: 'ECG: ${heartRateReading.toUpperCase()}',
          ),
          const SizedBox(height: 8),
          _buildRetakeLink(),
          const SizedBox(height: 12),
        ],

        // Primary Proceed Button
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
                  'Proceed to Blood Pressure',
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
    final Paint strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final double w = size.width;
    final double h = size.height;

    final Path shieldPath = Path();
    shieldPath.moveTo(w * 0.5, 0);
    shieldPath.lineTo(w, h * 0.2);
    shieldPath.lineTo(w, h * 0.5);
    shieldPath.cubicTo(w, h * 0.8, w * 0.5, h, w * 0.5, h);
    shieldPath.cubicTo(w * 0.5, h, 0, h * 0.8, 0, h * 0.5);
    shieldPath.lineTo(0, h * 0.2);
    shieldPath.close();

    canvas.drawPath(shieldPath, strokePaint);

    final double cx = w * 0.5;
    final double cy = h * 0.45;
    final double crossSize = w * 0.25;

    canvas.drawLine(
      Offset(cx - crossSize, cy),
      Offset(cx + crossSize, cy),
      strokePaint..strokeWidth = 1.8,
    );
    canvas.drawLine(
      Offset(cx, cy - crossSize),
      Offset(cx, cy + crossSize),
      strokePaint..strokeWidth = 1.8,
    );
  }

  @override
  bool shouldRepaint(covariant _RakshaShieldPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _ChestLeadsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final double w = size.width;
    final double h = size.height;

    final Path chestPath = Path();
    chestPath.moveTo(w * 0.3, h * 0.1);
    chestPath.quadraticBezierTo(w * 0.5, h * 0.2, w * 0.7, h * 0.1);

    canvas.drawPath(chestPath, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
