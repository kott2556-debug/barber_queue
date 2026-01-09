import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../utils/queue_manager.dart';

class QueueScreen extends StatelessWidget {
  QueueScreen({super.key});

  final FirestoreService firestoreService = FirestoreService();
  final QueueManager qm = QueueManager();

  @override
  Widget build(BuildContext context) {
    final userPhone = qm.currentUserPhone;

    return Scaffold(
      appBar: AppBar(
        title: const Text('คิวของฉัน'),
        centerTitle: true,
        backgroundColor: const Color(0xFF4CAF93),
      ),
      body: userPhone == null
          ? const Center(child: Text('ไม่พบข้อมูลผู้ใช้'))
          : StreamBuilder<QuerySnapshot>(
              stream: firestoreService.streamBookings(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData) {
                  return const Center(child: Text('ไม่พบข้อมูลคิว'));
                }

                // 🔥 กรองเฉพาะคิวของลูกค้าคนนี้
                final userQueues = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['phone'] == userPhone;
                }).toList();

                if (userQueues.isEmpty) {
                  return const Center(child: Text('คุณยังไม่มีคิว'));
                }

                // แสดงเฉพาะคิวล่าสุด
                final doc = userQueues.last;
                final data = doc.data() as Map<String, dynamic>;

                final status = data['status'];
                final queueLabel = data['queueLabel']; // ✅ ดึงชื่อคิว

                Color statusColor;
                String statusText;

                switch (status) {
                  case 'serving':
                    statusColor = Colors.green;
                    statusText = 'กำลังให้บริการ';
                    break;
                  case 'done':
                    statusColor = Colors.grey;
                    statusText = 'เสร็จแล้ว';
                    break;
                  default:
                    statusColor = Colors.orange;
                    statusText = 'รอคิว';
                }

                return Center(
                  child: Card(
                    elevation: 6,
                    margin: const EdgeInsets.all(20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ✅ ชื่อคิว
                          if (queueLabel != null)
                            Text(
                              queueLabel,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4CAF93),
                              ),
                            ),

                          if (queueLabel != null)
                            const SizedBox(height: 8),

                          Text(
                            data['name'] ?? '-',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'เวลา ${data['time']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
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
}
