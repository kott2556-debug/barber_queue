import 'package:flutter/material.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ดูคิว")),
      body: const Center(child: Text("หน้านี้ไว้ดูคิว")),
    );
  }
}
