import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'firebase_options.dart';
import 'app_state.dart';
import 'auth_screens.dart';
import 'dashboard_screen.dart';
import 'admin_screen.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await sb.Supabase.initialize(
    url: 'https://lfkwoducqjuwqrcrlhrj.supabase.co', //'YOUR_SUPABASE_URL',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxma3dvZHVjcWp1d3FyY3JsaHJqIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MDE0MjgyMywiZXhwIjoyMDg1NzE4ODIzfQ.ScKPlNJYwlIipgHG2SUTCrmz-LnICI7XOI46UsehVQ8', //'YOUR_SUPABASE_ANON_KEY',
  );
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return MaterialApp(
      title: 'Automated Accounting System',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: _getHome(state),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/admin-login': (_) => const AdminLoginScreen(),
      },
    );
  }

  Widget _getHome(AppState state) {
    if (state.currentRole == 'user') {
      return const UserDashboard();
    } else if (state.currentRole == 'admin') {
      return const AdminDashboard();
    }
    return const LoginScreen();
  }
}
