import 'package:flutter/material.dart';

/// Represents the status state of the Stethoscope scan step.
enum StethoscopeScanStatus {
  /// Initial state before recording (Action: "Start 10s Recording")
  initial,

  /// Scan completed with no issues detected (Green banner)
  clean,

  /// Scan completed with abnormal readings detected (Red warning banner)
  abnormal,
}

/// A pixel-perfect, production-ready StatelessWidget for the Raksha Stethoscope Capture UI.
///
/// Designed as a self-contained, single stateless Flutter widget.
class StethoscopeScanStep extends StatelessWidget {
  /// Current state of the scan result (defaults to [StethoscopeScanStatus.abnormal])
  final StethoscopeScanStatus status;

  /// Patient identification string
  final String patientId;

  /// Current step number in the workflow sequence
  final int currentStep;

  /// Total number of steps in the workflow
  final int totalSteps;

  /// Callback when the primary action button is tapped
  final VoidCallback? onPrimaryPressed;

  /// Optional custom illustration image URL
  final String? illustrationUrl;

  const StethoscopeScanStep({
    super.key, // Fixed the super parameter warning for a cleaner codebase!
    this.status = StethoscopeScanStatus.abnormal,
    this.patientId = 'PT-XXXX',
    this.currentStep = 1,
    this.totalSteps = 4,
    this.onPrimaryPressed,
    this.illustrationUrl,
  });

  // Core Color System
  static const Color primaryBlue = Color(0xFF2563EB); // Cobalt Blue
  static const Color darkText = Color(0xFF111827); // Deep Gray/Charcoal
  static const Color secondaryText = Color(0xFF434655); // On-surface Variant
  static const Color cardBg = Color(0xFFF9FAFB); // Surface Low
  static const Color dividerColor = Color(0xFFF3F4F6); // Soft Gray Divider
  static const Color borderColor = Color(0xFFE5E7EB); // Border Outline

  // Status Banner Colors
  static const Color abnormalBg = Color(0xFFFEF2F2);
  static const Color abnormalBorder = Color(0xFFDC2626);
  static const Color abnormalText = Color(0xFFDC2626);

  static const Color cleanBg = Color(0xFFD1FAE5);
  static const Color cleanBorder = Color(0xFFA7F3D0);
  static const Color cleanText = Color(0xFF065F46);

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
              crossAxisAlignment:
                  CrossAxisAlignment.stretch, // Perfectly aligned now
              children: [
                // Top Linear Progress Bar
                _buildProgressBar(progressFraction),
                const SizedBox(height: 16),

                // Brand Header Section (Shield Logo + RAKSHA)
                _buildHeader(),
                const SizedBox(height: 24),

                // Step Info & Patient ID Pill Badge
                _buildStepInfo(),
                const SizedBox(height: 16),

                // Subtle Divider Line
                const Divider(color: dividerColor, height: 1, thickness: 1),
                const SizedBox(height: 24),

                // Main Content Area (Placement Illustration & Instructions)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildIllustrationCard(),
                      const SizedBox(height: 24),
                      _buildInstructionText(),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Bottom Action & Status Section
                _buildBottomSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the 6px top linear progress bar matching Tailwind `h-1.5`
  Widget _buildProgressBar(double fraction) {
    return Container(
      height: 6.0,
      width: double.infinity,
      decoration: BoxDecoration(
        color: dividerColor,
        borderRadius: BorderRadius.circular(3.0),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: fraction,
        child: Container(
          decoration: BoxDecoration(
            color: primaryBlue,
            borderRadius: BorderRadius.circular(3.0),
          ),
        ),
      ),
    );
  }

  /// Builds Header with RAKSHA brand name and custom Shield icon vector
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

  /// Builds Step Title and Patient ID Badge Container
  Widget _buildStepInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start, // Fixed here too
      children: [
        Text(
          'Step $currentStep:\nStethoscope',
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
            border: Border.all(color: borderColor, width: 1.0),
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

  /// Builds rounded card containing the placement graphic with network loading & offline vector fallback
  Widget _buildIllustrationCard() {
    const String defaultUrl =
        'https://lh3.googleusercontent.com/aida-public/AB6AXuC5u9CNA0b5bVo_l5M_awfe_trirdKcmlW6LHQnHLvjCbi6DeErzwhrdc_Ua87Mi0hUMVmCxWgB9yvYKCrEYW5594E3gCLc_-4WKUiKOANZgOs0evlu3oMtBMoT2FEMB5KP3_Rb295VfR4IDpTuqt6orBbYNWxiI08rBJkY6sYwysc4w_7TttydOPfjth0rXAJaqyZs6_8rOwJq7AdeTuaRiQ8G4RICGHahxvvzWwJ0BE7v6LKQdSPbaTqmfwEx2x7ztg';

    final String targetUrl = illustrationUrl ?? defaultUrl;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 230),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: dividerColor, width: 1.0),
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

  /// Vector line-art CustomPainter fallback when image asset/URL is unavailable
  Widget _buildFallbackIllustration() {
    return CustomPaint(
      size: const Size(double.infinity, 200),
      painter: _StethoscopeTorsoPainter(),
    );
  }

  /// Builds instruction text paragraph
  Widget _buildInstructionText() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        'Place device securely and keep\npatient silent.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: secondaryText,
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
      ),
    );
  }

  /// Builds bottom section containing the dynamic status banner & primary proceed button
  Widget _buildBottomSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch, // And fixed here!
      children: [
        if (status == StethoscopeScanStatus.abnormal) ...[
          _buildStatusBanner(
            bgColor: abnormalBg,
            borderColor: abnormalBorder,
            textColor: abnormalText,
            icon: Icons.warning_amber_rounded,
            text: 'WARNING: ABNORMAL DETECTED',
          ),
          const SizedBox(height: 12),
        ] else if (status == StethoscopeScanStatus.clean) ...[
          _buildStatusBanner(
            bgColor: cleanBg,
            borderColor: cleanBorder,
            textColor: cleanText,
            icon: Icons.check_rounded,
            text: 'SCAN COMPLETE: CLEAN',
          ),
          const SizedBox(height: 12),
        ],

        // Primary Action Button
        SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: onPrimaryPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  status == StethoscopeScanStatus.initial
                      ? 'Start 10s Recording'
                      : 'Proceed to ECG',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                if (status != StethoscopeScanStatus.initial) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Generic status banner widget component
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
                fontSize: 13,
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
}

/// CustomPainter that renders the exact RAKSHA Shield Logo
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

    // Outer shield geometry
    final Path shieldPath = Path();
    shieldPath.moveTo(w * 0.5, 0);
    shieldPath.lineTo(w, h * 0.2);
    shieldPath.lineTo(w, h * 0.5);
    shieldPath.cubicTo(w, h * 0.8, w * 0.5, h, w * 0.5, h);
    shieldPath.cubicTo(w * 0.5, h, 0, h * 0.8, 0, h * 0.5);
    shieldPath.lineTo(0, h * 0.2);
    shieldPath.close();

    canvas.drawPath(shieldPath, strokePaint);

    // Inner cross symbol
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

/// Vector CustomPainter for torso & stethoscope placement
class _StethoscopeTorsoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = const Color(0xFF374151)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // Fixed the deprecated 'withOpacity' warning with proper ARGB mapping!
    final Paint lungPaint = Paint()
      ..color =
          const Color(0x80E5E7EB) // 50% opacity in Hex
      ..style = PaintingStyle.fill;

    final double w = size.width;
    final double h = size.height;

    // Torso outline
    final Path bodyPath = Path();
    bodyPath.moveTo(w * 0.38, h * 0.1);
    bodyPath.quadraticBezierTo(w * 0.4, h * 0.2, w * 0.42, h * 0.22);
    bodyPath.quadraticBezierTo(w * 0.25, h * 0.3, w * 0.15, h * 0.55);
    bodyPath.lineTo(w * 0.15, h * 0.9);

    bodyPath.moveTo(w * 0.62, h * 0.1);
    bodyPath.quadraticBezierTo(w * 0.6, h * 0.2, w * 0.58, h * 0.22);
    bodyPath.quadraticBezierTo(w * 0.75, h * 0.3, w * 0.85, h * 0.55);
    bodyPath.lineTo(w * 0.85, h * 0.9);

    bodyPath.moveTo(w * 0.5, h * 0.24);
    bodyPath.lineTo(w * 0.5, h * 0.85);

    final Path leftLung = Path();
    leftLung.addOval(Rect.fromLTWH(w * 0.26, h * 0.35, w * 0.2, h * 0.45));

    final Path rightLung = Path();
    rightLung.addOval(Rect.fromLTWH(w * 0.54, h * 0.35, w * 0.2, h * 0.45));

    canvas.drawPath(leftLung, lungPaint);
    canvas.drawPath(rightLung, lungPaint);
    canvas.drawPath(leftLung, linePaint);
    canvas.drawPath(rightLung, linePaint);
    canvas.drawPath(bodyPath, linePaint);

    final Offset chestPieceCenter = Offset(w * 0.6, h * 0.52);
    canvas.drawCircle(chestPieceCenter, 14, linePaint);
    canvas.drawCircle(chestPieceCenter, 10, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
