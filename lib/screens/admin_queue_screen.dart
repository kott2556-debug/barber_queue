import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class AdminQueueScreen extends StatelessWidget {
  const AdminQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("ดูคิวทั้งหมด Admin"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.streamBookings(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("เกิดข้อผิดพลาดในการโหลดคิว"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("ยังไม่มีคิว"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              final name = data['name'] ?? '-';
              final phone = data['phone'] ?? '-';
              final time = data['time'] ?? '-';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade600,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('เวลา $time\nเบอร์ $phone'),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
