import 'package:flutter/material.dart';

/// Static, wide horizontal test card widget.
class TestCard extends StatelessWidget {
  final String title;
  final IconData icon;

  const TestCard({
    super.key,
    required this.title,
    required this.icon,
  });

  static const Color _primaryBlue = Color(0xFF2563EB);
  static const Color _darkCharcoal = Color(0xFF1C1B1B);
  static const Color _borderGray = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: _borderGray, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Row(
        children: [
          // Main Icon (Left)
          Container(
            width: 44.0,
            height: 44.0,
            decoration: BoxDecoration(
              color: _primaryBlue.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 24.0,
              color: _primaryBlue,
            ),
          ),
          const SizedBox(width: 14.0),

          // Title (Center, Expanded)
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15.0,
                fontWeight: FontWeight.w700,
                color: _darkCharcoal,
                letterSpacing: -0.2,
              ),
            ),
          ),
          const SizedBox(width: 12.0),

          // Action/Status Button (Right)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Start',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: _primaryBlue,
                ),
              ),
              SizedBox(width: 4.0),
              Icon(
                Icons.arrow_forward_rounded,
                size: 16.0,
                color: _primaryBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}