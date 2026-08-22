import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/triage_provider.dart';
import 'providers/triage_state.dart';
import 'screens/base.dart';
import 'screens/hardware_vitals_screen.dart';

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
      providers: [
        ChangeNotifierProvider(create: (_) => TriageProvider()),
        ChangeNotifierProvider(create: (_) => TriageState()),
      ],
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
        home: const RakshaHardwareVitalsScreen(),
      ),
    );
  }
}
