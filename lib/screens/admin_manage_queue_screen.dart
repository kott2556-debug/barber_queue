import 'package:flutter/material.dart';
import '../utils/queue_manager.dart';

class AdminManageQueueScreen extends StatefulWidget {
  const AdminManageQueueScreen({super.key});

  @override
  State<AdminManageQueueScreen> createState() =>
      _AdminManageQueueScreenState();
}

class _AdminManageQueueScreenState
    extends State<AdminManageQueueScreen> {
  final qm = QueueManager();

  // =====================
  // แสดงสถานะคิว
  // =====================
  Widget _statusChip(String status) {
    if (status == 'serving') {
      return const Chip(
        label: Text(
          "กำลังให้บริการ",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      );
    }
    return const Chip(
      label: Text(
        "รอคิว",
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.orange,
    );
  }

  // =====================
  // ยืนยันลบคิว
  // =====================
  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("ยืนยันการลบคิว"),
        content: const Text("ลูกค้าไม่มาใช่หรือไม่?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ยกเลิก"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              _deleteQueue(index);
              Navigator.pop(context);
            },
            child: const Text("ลบคิว"),
          ),
        ],
      ),
    );
  }

  // =====================
  // ลบคิวจริง
  // =====================
  void _deleteQueue(int index) {
    setState(() {
      if (index >= 0 && index < qm.bookings.length) {
        qm.bookings.removeAt(index);
      }
    });
  }

  // =====================
  // UI
  // =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("จัดการคิว"),
        centerTitle: true,
      ),
      body: qm.bookings.isEmpty
          ? const Center(
              child: Text(
                "ยังไม่มีคิว",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: qm.bookings.length,
              itemBuilder: (context, index) {
                final booking = qm.bookings[index];
                final status = booking['status'];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                    ),
                    title: Text(booking['name']),
                    subtitle: Text(
                      "เบอร์: ${booking['phone']} | เวลา: ${booking['time']}",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _statusChip(status),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () =>
                              _confirmDelete(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              qm.callNextQueue();
            });
          },
          child: const Text(
            "▶️ เรียกคิวถัดไป",
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
