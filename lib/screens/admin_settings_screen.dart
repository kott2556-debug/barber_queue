import 'package:flutter/material.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ตั้งค่าระบบ"),
        centerTitle: true,
        backgroundColor: const Color(0xFF1F3C34),
      ),
      body: const Center(
        child: Text(
          "หน้านี้ใช้ตั้งค่าเวลาเปิดร้าน / จำนวนคิว\n(จะทำต่อในขั้นถัดไป)",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
