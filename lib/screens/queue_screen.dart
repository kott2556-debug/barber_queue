import 'package:flutter/material.dart';
import '../utils/queue_manager.dart';

class QueueScreen extends StatefulWidget {
  const QueueScreen({super.key});

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {

  @override
  Widget build(BuildContext context) {
    final bookings = QueueManager().bookings;  // ใช้ข้อมูลจริง

    return Scaffold(
      appBar: AppBar(
        title: const Text("คิวของฉัน"),
        centerTitle: true,
      ),
      body: bookings.isEmpty
          ? const Center(
              child: Text(
                "ยังไม่มีคิวที่จองไว้",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final item = bookings[index];

                return Card(
                  child: ListTile(
                    title: Text("เวลา: ${item['time']}"),
                    subtitle: Text("สถานะ: ${item['status']}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          QueueManager().bookings.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
