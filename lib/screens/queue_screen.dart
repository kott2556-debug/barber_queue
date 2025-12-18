import 'package:flutter/material.dart';
import '../utils/queue_manager.dart';

class QueueScreen extends StatelessWidget {
   QueueScreen({super.key});

  final qm = QueueManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("คิวของคุณ")),
      body: qm.bookings.isEmpty
          ? const Center(child: Text("ยังไม่มีคิว"))
          : ListView.builder(
              itemCount: qm.bookings.length,
              itemBuilder: (context, index) {
                final b = qm.bookings[index];

                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(b['name']),
                  subtitle: Text('เวลา ${b['time']}'),
                  trailing: b['status'] == 'serving'
                      ? const Text(
                          "กำลังให้บริการ",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : const Text("รอคิว"),
                );
              },
            ),
    );
  }
}
