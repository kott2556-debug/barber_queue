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
        backgroundColor: const Color.fromARGB(255, 13, 168, 124), // ✅ สีแอพบาร์
        foregroundColor: Colors.white,
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

          // ==================================================
          // ✅ SORT เฉพาะ UI ตาม queueLabel (คิว 1 → คิว 10)
          // ==================================================
          final sortedDocs = [...docs];
          sortedDocs.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;

            final aLabel = aData['queueLabel'] ?? '';
            final bLabel = bData['queueLabel'] ?? '';

            int extractNumber(String label) {
              final match = RegExp(r'\d+').firstMatch(label);
              return match != null ? int.parse(match.group(0)!) : 999;
            }

            return extractNumber(aLabel).compareTo(extractNumber(bLabel));
          });

          return ListView.builder(
            itemCount: sortedDocs.length,
            itemBuilder: (context, index) {
              final data =
                  sortedDocs[index].data() as Map<String, dynamic>;

              final name = data['name'] ?? '-';
              final phone = data['phone'] ?? '-';
              final time = data['time'] ?? '-';
              final status = data['status'] ?? 'waiting';
              final queueLabel = data['queueLabel'] ?? '-';

              late Color statusColor;
              late String statusText;

              switch (status) {
                case 'serving':
                  statusColor = const Color(0xFF2E7D32); // เขียวเข้มอ่านง่าย
                  statusText = 'กำลังให้บริการ';
                  break;
                case 'done':
                  statusColor = Colors.grey;
                  statusText = 'เสร็จแล้ว';
                  break;
                default:
                  statusColor = Colors.blue;
                  statusText = 'รอคิว';
              }

              return Card(
                // ✅ ตัดสีเทาหม่นของ Material 3
                surfaceTintColor: Colors.transparent,

                // ✅ สีเวกเตอร์อ่อน ๆ เฉพาะ serving
                color: status == 'serving'
                    ? const Color(0xFFE8F5F0)
                    : null,

                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  // คิว 1–10 (serving เด่นขึ้น)
                  leading: Text(
                    queueLabel,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: status == 'serving'
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFF2196F3),
                    ),
                  ),

                  // ชื่อ + เว้นวรรค + เบอร์โทร
                  title: Text(
                    '$name   $phone',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  // ใต้ชื่อ → เวลา → ใต้เวลา → สถานะ
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('เวลา $time'),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
