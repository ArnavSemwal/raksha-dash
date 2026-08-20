import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/triage_provider.dart';
import 'screens/hardware_vitals_screen.dart';
import 'screens/ai_triage_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RakshaApp());
}

/// Root Application Widget
class RakshaApp extends StatelessWidget {
  const RakshaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => TriageProvider())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Raksha Triage App',
        theme: ThemeData(
          fontFamily: 'Inter',
          useMaterial3: false,
          scaffoldBackgroundColor: Colors.white,
        ),
        routes: {
          '/hardware_vitals': (context) => const RakshaHardwareVitalsScreen(),
        },
        home: const AiTriageScreen(
          vitals: {
            'hr': '72',
            'bp': '120/80',
            'spo2': '98',
            'temp': '36.6',
          },
          r: 240,
          g: 230,
          b: 140,
          triageStatus: 'RED',
        ),
      ),
    );
  }
}
