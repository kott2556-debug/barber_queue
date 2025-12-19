import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/queue_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/admin_manage_queue_screen.dart';
import 'screens/admin_settings_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Barber Queue',
      initialRoute: '/',
      routes: {
        '/': (_) => const LoginScreen(),
        '/home': (_) => const HomeScreen(),
        '/booking': (_) => const BookingScreen(),
        '/queue': (_) => QueueScreen(),

        // --- Admin ---
        '/admin': (_) => const AdminDashboard(),
        '/admin/manage': (_) =>  AdminManageQueueScreen(),
        '/admin/settings': (_) => const AdminSettingsScreen(),
      },
    );
  }
}
