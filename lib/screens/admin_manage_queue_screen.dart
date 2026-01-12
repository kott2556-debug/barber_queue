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
        title: const Text('จัดการคิว Admin'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 20, 175, 131),
        foregroundColor: Colors.white
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

          // ✅ sort ตามเลขคิว
          final sortedDocs = [...docs];
          sortedDocs.sort((a, b) {
            final aLabel = (a['queueLabel'] ?? '') as String;
            final bLabel = (b['queueLabel'] ?? '') as String;

            int extract(String s) =>
                int.tryParse(RegExp(r'\d+').firstMatch(s)?.group(0) ?? '') ?? 999;

            return extract(aLabel).compareTo(extract(bLabel));
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedDocs.length,
            itemBuilder: (context, index) {
              final doc = sortedDocs[index];
              final data = doc.data() as Map<String, dynamic>;

              final status = data['status'] ?? 'waiting';
              final queueLabel = data['queueLabel'] ?? 'คิว ${index + 1}';

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
                  leading: Container(
                    width: 44,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      queueLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

                      // ▶️ เรียกคิว (เปลี่ยน status อย่างเดียว)
                      if (status == 'waiting')
                        TextButton(
                          onPressed: () async {
                            await firestoreService
                                .callNextQueueByAdmin(doc.id);
                          },
                          child: const Text('เรียกคิว'),
                        ),

                      // ✅ เสร็จแล้ว (เปลี่ยน status อย่างเดียว)
                      if (status == 'serving')
                        TextButton(
                          onPressed: () async {
                            await firestoreService
                                .finishQueueByAdmin(doc.id);
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
