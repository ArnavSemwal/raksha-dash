import 'package:flutter/material.dart';

/// Safe, minimal dummy dashboard screen to establish a stable project baseline.
class TestDashboardScreen extends StatelessWidget {
  const TestDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Dashboard WIP',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
