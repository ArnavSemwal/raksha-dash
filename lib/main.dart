import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/triage_provider.dart';
import 'screens/triage_master.dart';

void main() {
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
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ),
        home: const TriageMaster(),
      ),
    );
  }
}
