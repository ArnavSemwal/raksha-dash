import 'dart:async';
import 'package:flutter/material.dart';

/// Self-contained full-screen hardware loading UI using dynamic circular icons,
/// test-specific rotating clinical quotes every 1.5 seconds,
/// and an automatic pop after 4 seconds to return `true` to the dashboard.
class TestLoaderScreen extends StatefulWidget {
  final String testName;
  final IconData icon;

  const TestLoaderScreen({
    super.key,
    required this.testName,
    required this.icon,
  });

  @override
  State<TestLoaderScreen> createState() => _TestLoaderScreenState();
}

class _TestLoaderScreenState extends State<TestLoaderScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;

  Timer? _quoteTimer;
  Timer? _completionTimer;

  int _currentQuoteIndex = 0;
  late final List<String> _quotes;

  // Exact test-specific quotes map matching dashboard titles
  static const Map<String, List<String>> _testQuotes = {
    "ECG Analysis": [
      "Ensure patient is completely relaxed.",
      "Keep the electrodes steady.",
      "Analyzing heart rhythm...",
      "Filtering background signal noise...",
    ],
    "Body Temperature": [
      "Hold the IR sensor steady.",
      "Checking ambient room conditions...",
      "Calculating core body temperature...",
      "Ensuring precise thermal calibration...",
    ],
    "Urine Strip Analysis": [
      "Position the strip clearly under the sensor.",
      "Analyzing specific RGB color values...",
      "Checking hydration and health markers...",
      "Processing chemical reactions...",
    ],
    "Stethoscope Scan": [
      "Keep the digital chest piece flat against the skin.",
      "Instruct the patient to breathe normally.",
      "Isolating acoustic body signals...",
      "Recording clear lung/heart sounds...",
    ],
    "SpO2 & Pulse": [
      "Ensure the finger is placed correctly.",
      "Keep hands warm and perfectly still.",
      "Measuring blood oxygen levels...",
      "Calculating real-time pulse rate...",
    ],
  };

  // Generic fallback quotes if testName doesn't match any key
  static const List<String> _fallbackQuotes = [
    "Initializing hardware sensor...",
    "Calibrating system parameters...",
    "Processing real-time measurements...",
    "Finalizing clinical analysis...",
  ];

  static const Color _primaryBlue = Color(0xFF2563EB);
  static const Color _darkCharcoal = Color(0xFF1C1B1B);
  static const Color _subtleGray = Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();

    // 1. Resolve quotes list with fallback protection
    _quotes = _testQuotes[widget.testName] ?? _fallbackQuotes;

    // 2. Subtle pulsing animation setup (scale 0.92 to 1.08)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // 3. Rotate quotes every 1.5 seconds
    _quoteTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (mounted) {
        setState(() {
          _currentQuoteIndex = (_currentQuoteIndex + 1) % _quotes.length;
        });
      }
    });

    // 4. Automatically pop back to dashboard after exactly 4 seconds
    _completionTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pop(context, true);
      }
    });
  }

  @override
  void dispose() {
    // Strictly cancel all timers and dispose controller to avoid memory leaks
    _quoteTimer?.cancel();
    _completionTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // TOP: Dynamic Pulsing Circular Icon Graphic
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 160.0,
                      height: 160.0,
                      decoration: BoxDecoration(
                        color: _primaryBlue.withOpacity(0.08),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _primaryBlue.withOpacity(0.18),
                          width: 3.0,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          widget.icon,
                          size: 76.0,
                          color: _primaryBlue,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 36.0),

              // MIDDLE: Title & Loading Progress
              Text(
                'Initializing ${widget.testName}...',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22.0,
                  fontWeight: FontWeight.w800,
                  color: _darkCharcoal,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 16.0),
              const SizedBox(
                width: 34,
                height: 34,
                child: CircularProgressIndicator(
                  strokeWidth: 3.0,
                  valueColor: AlwaysStoppedAnimation<Color>(_primaryBlue),
                ),
              ),

              const Spacer(),

              // BOTTOM: Rotating Quote with Smooth Fade Transition
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.tips_and_updates_rounded,
                      color: _primaryBlue,
                      size: 24.0,
                    ),
                    const SizedBox(width: 14.0),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.0, 0.2),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          _quotes[_currentQuoteIndex],
                          key: ValueKey<int>(_currentQuoteIndex),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            color: _subtleGray,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12.0),
            ],
          ),
        ),
      ),
    );
  }
}
