import 'package:flutter/material.dart';
import 'providers/triage_provider.dart' show ScanStatus;

/// Alias so all existing references to BloodPressureScanStatus compile unchanged.
typedef BloodPressureScanStatus = ScanStatus;

/// Production-ready, pixel-perfect StatelessWidget for the Raksha Step 3: Blood Pressure UI.
///
/// Converts the HTML/Tailwind layout completely into a single stateless Flutter Widget.
class RakshaBloodPressureScreen extends StatelessWidget {
  /// Scan state (defaults to [BloodPressureScanStatus.abnormal])
  final BloodPressureScanStatus status;

  /// Patient identification string
  final String patientId;

  /// Current step (default: 3)
  final int currentStep;

  /// Total steps (default: 4)
  final int totalSteps;

  /// Measured BP reading string for clean state (default: "120/80 mmHg")
  final String bpReading;

  /// Callback when primary proceed button is pressed
  final VoidCallback? onProceedPressed;

  /// Callback when start measurement button is pressed (initial state)
  final VoidCallback? onStartMeasurementPressed;

  /// Callback when "Tap to Retake" text is pressed
  final VoidCallback? onRetakePressed;

  /// Optional illustration image URL
  final String? illustrationUrl;

  const RakshaBloodPressureScreen({
    super.key,
    this.status = BloodPressureScanStatus.abnormal,
    this.patientId = 'PT-XXXX',
    this.currentStep = 3,
    this.totalSteps = 4,
    this.bpReading = '120/80 mmHg',
    this.onProceedPressed,
    this.onStartMeasurementPressed,
    this.onRetakePressed,
    this.illustrationUrl,
  });

  // Core Colors
  static const Color primaryBlue = Color(0xFF2563EB); // Cobalt Blue #2563EB
  static const Color darkText = Color(0xFF111827); // Charcoal #111827
  static const Color secondaryText = Color(0xFF434655); // Body Gray #434655
  static const Color outlineGray = Color(0xFF737686); // Link & Subtext #737686
  static const Color cardBg = Color(0xFFF9FAFB); // Card Surface
  static const Color borderGray = Color(0xFFE5E7EB); // Outline Border #E5E7EB

  // Status Colors
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
        : 0.5;

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
                // Top Progress Bar (50%)
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

  /// Builds top 4px linear progress bar matching Tailwind `h-1`
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

  /// Builds Header with RAKSHA brand name and custom Shield icon
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

  /// Builds Step Title and Patient ID Pill Badge
  Widget _buildStepInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step $currentStep:\nBlood\nPressure',
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

  /// Builds rounded illustration card
  Widget _buildIllustrationCard() {
    const String defaultUrl =
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCh0Ul6BJ7D0YdHxb41rQ2HNfMWB7ibIYDa4e8ORmdXGhQxarYuH5GNTo4Rk13EqXF-lwOLw7XBpHy4rstomC32wbdh2MxEzxnoS1iq1aNRPnvZ4hAMQfHeAMgG3IxH1xzPvsd7FKCizWaICXIwmS9vNQNzenTQiR0VMgArDALQnr1MnFvN6CQ0iifJ3qz7LcDEDRdc39coY8HlCBLr7LwlzdhSuv4oYjktwg17WShUA5FEG8-N8o5p-9KMsaYODe0-8g';

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

  /// Vector CustomPainter for offline fallback of BP cuff placement
  Widget _buildFallbackIllustration() {
    return CustomPaint(
      size: const Size(double.infinity, 180),
      painter: _StethoscopeArmBendingPainter(),
    );
  }

  /// Builds instruction text block based on state
  Widget _buildInstructionText() {
    final String text = (status == BloodPressureScanStatus.initial)
        ? 'Wrap BP cuff securely around\nthe upper left arm.'
        : "Ensure the cuff is positioned correctly on the patient's upper arm, level with the heart.";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: secondaryText,
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
      ),
    );
  }

  /// Builds bottom section with status banners, retake action, and proceed button
  Widget _buildBottomSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (status == BloodPressureScanStatus.initial) ...[
          // Initial State: Start BP Measurement Button
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
                'Start BP Measurement',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ] else if (status == BloodPressureScanStatus.abnormal) ...[
          // Abnormal State Banner
          _buildStatusBanner(
            bgColor: abnormalBg,
            borderColor: abnormalBorder,
            textColor: abnormalText,
            icon: Icons.warning_amber_rounded,
            text: 'WARNING: ABNORMAL BP DETECTED',
          ),
          const SizedBox(height: 8),
          _buildRetakeLink(),
          const SizedBox(height: 12),
        ] else if (status == BloodPressureScanStatus.clean) ...[
          // Clean State Banner
          _buildStatusBanner(
            bgColor: cleanBg,
            borderColor: cleanBorder,
            textColor: cleanText,
            icon: Icons.favorite_border_rounded,
            text: 'BP: ${bpReading.toUpperCase()}',
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
                  'Proceed to SpO2',
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

  /// Builds status banner widget
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

  /// Builds "Tap to Retake" underlined text button
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

/// CustomPainter for RAKSHA Shield Logo
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

/// Fallback CustomPainter vector art for Arm & BP Cuff placement
class _StethoscopeArmBendingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final double w = size.width;
    final double h = size.height;

    final Path armPath = Path();
    armPath.moveTo(w * 0.2, h * 0.2);
    armPath.quadraticBezierTo(w * 0.35, h * 0.35, w * 0.4, h * 0.45);
    armPath.quadraticBezierTo(w * 0.55, h * 0.55, w * 0.75, h * 0.55);

    armPath.moveTo(w * 0.28, h * 0.4);
    armPath.quadraticBezierTo(w * 0.42, h * 0.5, w * 0.48, h * 0.65);
    armPath.quadraticBezierTo(w * 0.6, h * 0.7, w * 0.75, h * 0.68);

    final Rect cuffRect = Rect.fromLTWH(w * 0.32, h * 0.32, w * 0.16, h * 0.24);

    canvas.drawPath(armPath, linePaint);
    canvas.drawRect(cuffRect, linePaint);

    final Path tube = Path();
    tube.moveTo(w * 0.4, h * 0.56);
    tube.quadraticBezierTo(w * 0.42, h * 0.7, w * 0.44, h * 0.75);
    canvas.drawPath(tube, linePaint);
    canvas.drawCircle(Offset(w * 0.44, h * 0.8), 8, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
