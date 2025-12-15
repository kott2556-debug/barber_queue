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
  final queueManager = QueueManager();

  void _changeStatus(int index, String status) {
    setState(() {
      queueManager.bookings[index]['status'] = status;
    });
  }

  void _removeQueue(int index) {
    setState(() {
      queueManager.bookings.removeAt(index);
    });
  }

  void _clearAllQueues() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("ยืนยันการล้างคิว"),
        content:
            const Text("คุณต้องการลบคิวทั้งหมดใช่หรือไม่?"),
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
              setState(() {
                queueManager.bookings.clear();
              });
              Navigator.pop(context);
            },
            child: const Text("ล้างทั้งหมด"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookings = queueManager.bookings;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: const Text("จัดการคิว"),
        centerTitle: true,
        backgroundColor: const Color(0xFF1F3C34),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: "ล้างคิวทั้งหมด",
            onPressed:
                bookings.isEmpty ? null : _clearAllQueues,
          ),
        ],
      ),
      body: bookings.isEmpty
          ? const Center(
              child: Text(
                "ยังไม่มีคิวในระบบ",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.content_cut,
                                  color: Color(0xFF4CAF93)),
                              const SizedBox(width: 10),
                              Text(
                                "เวลา ${booking['time']}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                onPressed: () =>
                                    _removeQueue(index),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Wrap(
                            spacing: 10,
                            children: [
                              _statusButton(
                                label: "รอ",
                                isActive:
                                    booking['status'] ==
                                        "Pending",
                                color: Colors.orange,
                                onTap: () =>
                                    _changeStatus(index,
                                        "Pending"),
                              ),
                              _statusButton(
                                label: "กำลังตัด",
                                isActive:
                                    booking['status'] ==
                                        "Cutting",
                                color: Colors.blue,
                                onTap: () =>
                                    _changeStatus(index,
                                        "Cutting"),
                              ),
                              _statusButton(
                                label: "เสร็จแล้ว",
                                isActive:
                                    booking['status'] ==
                                        "Done",
                                color: Colors.green,
                                onTap: () =>
                                    _changeStatus(
                                        index, "Done"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _statusButton({
    required String label,
    required bool isActive,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isActive ? color : Colors.grey.shade300,
        foregroundColor:
            isActive ? Colors.white : Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      child: Text(label),
    );
  }
}
