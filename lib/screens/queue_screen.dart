import 'package:flutter/material.dart';
import '../utils/queue_manager.dart';

class QueueScreen extends StatelessWidget {
  QueueScreen({super.key});

  final QueueManager qm = QueueManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("คิวของคุณ"),
        centerTitle: true,
      ),

      // 🔥 ฟัง realtime จาก QueueManager
      body: AnimatedBuilder(
        animation: qm,
        builder: (context, _) {
          // ไม่มีคิวของตัวเอง
          if (qm.myBookings.isEmpty) {
            return const Center(
              child: Text(
                "คุณยังไม่มีคิว",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return Column(
            children: [
              // --------------------
              // แสดงสถานะถึงคิวแล้ว
              // --------------------
              if (qm.myServingQueue != null)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    "🟢 ถึงคิวคุณแล้ว\nเวลา ${qm.myServingQueue!['time']}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              // --------------------
              // รายการคิวของฉัน
              // --------------------
              Expanded(
                child: ListView.builder(
                  itemCount: qm.myBookings.length,
                  itemBuilder: (context, index) {
                    final b = qm.myBookings[index];

                    final bool isServing = b['status'] == 'serving';
                    final bool isDone = b['status'] == 'done';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              isServing ? Colors.green : Colors.grey.shade400,
                          child: Text('${index + 1}'),
                        ),
                        title: Text(
                          "เวลา ${b['time']}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          isServing
                              ? "กำลังให้บริการ"
                              : isDone
                                  ? "เสร็จแล้ว"
                                  : "รอคิว",
                          style: TextStyle(
                            color: isServing
                                ? Colors.green
                                : isDone
                                    ? Colors.grey
                                    : Colors.orange,
                            fontWeight: isServing
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
