import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/triage_provider.dart';
import 'providers/triage_state.dart';
import 'screens/asha_login_screen.dart';
import 'screens/base.dart';
import 'screens/dashboard_completed_screen.dart';
import 'screens/hardware_vitals_screen.dart';
import 'screens/register.dart';
import 'screens/triage_result_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool isAuthenticated = prefs.getBool('is_authenticated') ?? false;

  runApp(RakshaApp(isAuthenticated: isAuthenticated));
}

/// Root Application Widget with dynamic authentication gate & route registry
class RakshaApp extends StatelessWidget {
  final bool isAuthenticated;

  const RakshaApp({
    super.key,
    this.isAuthenticated = false,
  });

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
          fontFamily: 'Space Mono',
          useMaterial3: false,
          scaffoldBackgroundColor: Colors.white,
        ),
        initialRoute: isAuthenticated ? '/dashboard' : '/login',
        routes: {
          '/login': (context) => const AshaLoginScreen(),
          '/dashboard': (context) => const RakshaHardwareVitalsScreen(),
          '/dashboard_completed': (context) => const DashboardCompletedScreen(),
          '/triage_result': (context) => const TriageResultScreen(),
          '/hardware_vitals': (context) => const RakshaHardwareVitalsScreen(),
          '/register': (context) => const RakshaPatientRegistrationScreen(),
          '/home': (context) => const BaseScreen(),
        },
      ),
    );
  }
}
