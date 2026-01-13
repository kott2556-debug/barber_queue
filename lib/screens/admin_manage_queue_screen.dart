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
        foregroundColor: Colors.white,
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
                  statusColor = Colors.blue;
                  statusText = 'รอคิว';
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // ---------- เลขคิว ----------
                      Container(
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
                      const SizedBox(width: 12),

                      // ---------- ชื่อ + เบอร์ + เวลา ----------
                      Expanded(
                        child: Stack(
                          children: [
                            // ชื่อ + เบอร์ชิดซ้าย
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['name'] ?? '-',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    maxLines: 1,
                                  ),
                                  Text(
                                    data['phone'] ?? '-',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                            // เวลาอยู่กึ่งกลาง Card
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                data['time'] ?? '-',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // ---------- สถานะ + ปุ่ม ----------
                      Column(
                        children: [
                          Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (status == 'waiting')
                            ElevatedButton(
                              onPressed: () async {
                                await firestoreService.callNextQueueByAdmin(doc.id);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                minimumSize: const Size(80, 32),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                              child: const Text(
                                'รอคิว',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (status == 'serving')
                            ElevatedButton(
                              onPressed: () async {
                                await firestoreService.finishQueueByAdmin(doc.id);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                minimumSize: const Size(100, 32),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                              child: const Text(
                                'กำลังให้บริการ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
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
