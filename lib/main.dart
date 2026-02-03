import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
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
