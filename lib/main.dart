import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/queue_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/admin_manage_queue_screen.dart';


void main() {
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
        '/queue': (_) => const QueueScreen(),
        '/admin': (_) => const AdminDashboard(),
        '/admin_manage': (_) => const AdminManageQueueScreen(),// 👈 เพิ่ม route ตรงนี้
      },
    );
  }
}
