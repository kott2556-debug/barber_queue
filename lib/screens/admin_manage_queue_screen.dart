import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class AdminManageQueueScreen extends StatelessWidget {
  AdminManageQueueScreen({super.key});

  final FirestoreService firestoreService = FirestoreService();

  Color _getQueueColor(String status) {
    switch (status) {
      case 'arrived':
        return Colors.green;
      case 'absent':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

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

          final sortedDocs = [...docs];
          sortedDocs.sort((a, b) {
            final aLabel = (a['queueLabel'] ?? '') as String;
            final bLabel = (b['queueLabel'] ?? '') as String;

            int extract(String s) =>
                int.tryParse(RegExp(r'\d+').firstMatch(s)?.group(0) ?? '') ??
                999;

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
              final queueColor = _getQueueColor(status);
              final bool isLocked =
                  status == 'arrived' || status == 'absent';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // -------- เลขคิว --------
                      Container(
                        width: 55,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: queueColor,
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

                      // -------- ข้อมูลลูกค้า --------
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['name'] ?? 'ลูกค้า',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data['phone'] ?? '-',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data['time'] ?? '-',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // -------- ปุ่มแนวตั้ง --------
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ปุ่ม มา
                          SizedBox(
                            width: 85,
                            height: 34,
                            child: ElevatedButton(
                              onPressed: isLocked
                                  ? null
                                  : () async {
                                      await FirebaseFirestore.instance
                                          .collection('bookings')
                                          .doc(doc.id)
                                          .update({'status': 'arrived'});
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: status == 'arrived'
                                    ? Colors.green
                                    : status == 'absent'
                                        ? Colors.grey
                                        : Colors.blue,
                                disabledBackgroundColor:
                                    status == 'arrived'
                                        ? Colors.green
                                        : Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                status == 'arrived'
                                    ? 'เสร็จ'
                                    : 'มา',
                                    maxLines: 1,                  // 👈 บังคับบรรทัดเดียว
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // ปุ่ม ไม่มา
                          SizedBox(
                            width: 85,
                            height: 34,
                            child: ElevatedButton(
                              onPressed: isLocked
                                  ? null
                                  : () async {
                                      await FirebaseFirestore.instance
                                          .collection('bookings')
                                          .doc(doc.id)
                                          .update({'status': 'absent'});
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: status == 'absent'
                                    ? Colors.red
                                    : status == 'arrived'
                                        ? Colors.grey
                                        : Colors.blue,
                                disabledBackgroundColor:
                                    status == 'absent'
                                        ? Colors.red
                                        : Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'ไม่มา',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
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
