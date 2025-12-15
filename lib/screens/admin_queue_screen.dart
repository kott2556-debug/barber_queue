import 'package:flutter/material.dart';
import '../utils/queue_manager.dart';

class AdminQueueScreen extends StatelessWidget {
  const AdminQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final qm = QueueManager();

    return Scaffold(
      appBar: AppBar(
        title: const Text("คิวทั้งหมด"),
        centerTitle: true,
      ),
      body: qm.bookings.isEmpty
          ? const Center(child: Text("ยังไม่มีคิว"))
          : ListView.builder(
              itemCount: qm.bookings.length,
              itemBuilder: (context, index) {
                final b = qm.bookings[index];
                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(b['name']),
                  subtitle: Text("เวลา ${b['time']} | ${b['phone']}"),
                );
              },
            ),
    );
  }
}
