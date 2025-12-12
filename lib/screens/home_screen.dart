import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("เมนูหลัก")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/booking'),
              child: const Text("จองคิว"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/queue'),
              child: const Text("ดูคิว"),
            ),
          ],
        ),
      ),
    );
  }
}
