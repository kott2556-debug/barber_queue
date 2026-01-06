import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class AdminManageQueueScreen extends StatelessWidget {
  AdminManageQueueScreen({super.key});

  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('จัดการคิว (Admin)'),
        centerTitle: true,
        backgroundColor: const Color(0xFF4CAF93),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.streamBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('ยังไม่มีคิว'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final status = data['status'] ?? 'waiting';
              final phone = data['phone']; // ✅ ใช้ตอน finishQueue

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

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: statusColor,
                    child: Text('${index + 1}'),
                  ),
                  title: Text(data['name'] ?? '-'),
                  subtitle: Text('เวลา ${data['time'] ?? '-'}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (status == 'waiting')
                        TextButton(
                          onPressed: () async {
                            await firestoreService.callNextQueue(doc.id);
                          },
                          child: const Text('เรียกคิว'),
                        ),
                      if (status == 'serving')
                        TextButton(
                          onPressed: phone == null
                              ? null
                              : () async {
                                  await firestoreService.finishQueue(
                                    doc.id,
                                    phone,
                                  );
                                },
                          child: const Text('เสร็จแล้ว'),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
