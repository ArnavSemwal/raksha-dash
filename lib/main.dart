import 'package:flutter/material.dart';
import 'screens/test_dashboard_screen.dart';

void main() {
  runApp(const RakshaApp());
}

/// Root Application Widget configured for static layout testing.
class RakshaApp extends StatelessWidget {
  const RakshaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Raksha Static Test',
      theme: ThemeData(
        fontFamily: 'Inter',
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF2563EB),
        ),
      ),
      home: const TestDashboardScreen(),
    );
  }
}
