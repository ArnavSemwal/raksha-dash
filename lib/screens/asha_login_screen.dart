import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_header.dart';
import 'base.dart';

/// Transpiled pixel-accurate ASHA Secure Portal Login Screen with persistent authentication.
class AshaLoginScreen extends StatefulWidget {
  const AshaLoginScreen({super.key});

  @override
  State<AshaLoginScreen> createState() => _AshaLoginScreenState();
}

class _AshaLoginScreenState extends State<AshaLoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  bool _isAuthenticating = false;

  static const Color _bgSurface = Color(0xFFFFFFFF);
  static const Color _onSurface = Color(0xFF1C1B1B);
  static const Color _outline = Color(0xFF737686);
  static const Color _outlineVariant = Color(0xFFC3C6D7);
  static const Color _borderGray = Color(0xFFE5E7EB);
  static const Color _primary = Color(0xFF004AC6);

  Future<void> _handleAuthenticate() async {
    setState(() {
      _isAuthenticating = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_authenticated', true);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const BaseScreen(),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgSurface,
      body: SafeArea(
        child: Column(
          children: [
            // SECTION 1: BRANDING HEADER (Top)
            const AppHeader(),

            // SECTION 2: LOGIN FORM (Middle - Centered Vertically)
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'ASHA SECURE PORTAL',
                          style: TextStyle(
                            fontFamily: 'Space Mono',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _outline,
                            letterSpacing: 3.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // Field 1: ASHA ID or Mobile Number
                        Container(
                          height: 64.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: _borderGray, width: 1.0),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          alignment: Alignment.centerLeft,
                          child: TextField(
                            controller: _idController,
                            style: const TextStyle(
                              fontFamily: 'Space Mono',
                              fontSize: 16,
                              color: _onSurface,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'ASHA ID or Mobile Number',
                              hintStyle: TextStyle(
                                fontFamily: 'Space Mono',
                                fontSize: 16,
                                color: _outlineVariant,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Field 2: 4-Digit PIN
                        Container(
                          height: 64.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: _borderGray, width: 1.0),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          alignment: Alignment.centerLeft,
                          child: TextField(
                            controller: _pinController,
                            obscureText: true,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            style: const TextStyle(
                              fontFamily: 'Space Mono',
                              fontSize: 16,
                              color: _onSurface,
                              letterSpacing: 8.0,
                            ),
                            decoration: const InputDecoration(
                              counterText: '',
                              hintText: '4-Digit PIN',
                              hintStyle: TextStyle(
                                fontFamily: 'Space Mono',
                                fontSize: 16,
                                color: _outlineVariant,
                                letterSpacing: 0.0,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // SECTION 3: FOOTER ACTION (Bottom Anchor)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  bottom: 32.0,
                  top: 16.0,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 72.0,
                  child: ElevatedButton(
                    onPressed: _isAuthenticating ? null : _handleAuthenticate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      side: const BorderSide(color: _primary, width: 2.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: _isAuthenticating
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'AUTHENTICATE',
                                style: TextStyle(
                                  fontFamily: 'Space Mono',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              SizedBox(width: 12),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 24,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
