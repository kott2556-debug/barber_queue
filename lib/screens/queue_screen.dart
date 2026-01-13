import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../utils/queue_manager.dart';

class QueueScreen extends StatelessWidget {
  QueueScreen({super.key});

  final FirestoreService firestoreService = FirestoreService();
  final QueueManager qm = QueueManager();

  /// แปลง "11:10" → DateTime วันนี้
  DateTime? _parseBookingTime(String? time) {
    if (time == null || !time.contains(':')) return null;

    final parts = time.split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return null;

    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  /// คำนวณข้อความนับถอยหลังแบบ step
  String? _countdownText(DateTime bookingTime) {
    final now = DateTime.now();
    final diffMinutes = bookingTime.difference(now).inMinutes;

    if (diffMinutes > 60) return null;

    if (diffMinutes <= 0) {
      return 'กรุณามารับบริการ';
    }

    if (diffMinutes > 50) return 'อีก 60 นาที จะถึงคิวคุณ';
    if (diffMinutes > 40) return 'อีก 50 นาที จะถึงคิวคุณ';
    if (diffMinutes > 30) return 'อีก 40 นาที จะถึงคิวคุณ';
    if (diffMinutes > 20) return 'อีก 30 นาที จะถึงคิวคุณ';
    if (diffMinutes > 10) return 'อีก 20 นาที จะถึงคิวคุณ';

    return 'อีก 10 นาที จะถึงคิวคุณ';
  }

  @override
  Widget build(BuildContext context) {
    final userPhone = qm.currentUserPhone;

    return Scaffold(
      appBar: AppBar(
        title: const Text('คิวของฉัน'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 12, 158, 117),
        foregroundColor: Colors.white,
      ),
      body: userPhone == null
          ? const Center(child: Text('ไม่พบข้อมูลผู้ใช้'))
          : StreamBuilder<QuerySnapshot>(
              stream: firestoreService.streamBookings(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('ไม่พบข้อมูลคิว'));
                }

                final userDocs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['phone'] == userPhone;
                }).toList();

                if (userDocs.isEmpty) {
                  return const Center(child: Text('คุณยังไม่มีคิว'));
                }

                final doc = userDocs.last;
                final data = doc.data() as Map<String, dynamic>;

                final queueLabel = data['queueLabel'] ?? '';
                final name = data['name'] ?? '-';
                final time = data['time'];
                final bookingTime = _parseBookingTime(time);
                final countdown =
                    bookingTime != null ? _countdownText(bookingTime) : null;

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
                          Text(
                            queueLabel,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4CAF93),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),

                          /// เวลาที่จอง (แสดงตลอด)
                          Text(
                            'เวลาที่จอง $time',
                            style: const TextStyle(fontSize: 16),
                          ),

                          const SizedBox(height: 20),

                          /// ปุ่ม / ข้อความด้านล่าง
                          if (countdown == null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'รอคิว',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                countdown,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
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
