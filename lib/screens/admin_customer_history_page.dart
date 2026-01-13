import 'package:flutter/material.dart';

class AdminCustomerHistoryPage extends StatelessWidget {
  const AdminCustomerHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: const Text("ประวัติลูกค้า"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 11, 167, 122), // สีเดิม
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          "อยู่ระหว่างพัฒนา",
          style: TextStyle(
            color: Colors.black38,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
