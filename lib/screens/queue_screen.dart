import 'dart:async';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../utils/queue_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QueueScreen extends StatefulWidget {
  const QueueScreen({super.key});

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  final FirestoreService firestoreService = FirestoreService();
  final QueueManager qm = QueueManager();

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Map<String, dynamic>? getCountdown(String time) {
    final now = DateTime.now();
    final parts = time.split(':');
    if (parts.length != 2) return null;

    final bookingTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );

    final diffMinutes = bookingTime.difference(now).inMinutes;

    if (diffMinutes > 30) return null;
    if (diffMinutes <= 4) {
      return {'text': 'ถึงเวลาเข้ารับบริการแล้ว', 'isFinal': true};
    }

    final stepMinute = ((diffMinutes / 5).floor()) * 5;
    return {'text': 'อีก $stepMinute นาที จะถึงคิวคุณ', 'isFinal': false};
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
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final userQueues = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['phone'] == userPhone;
                }).toList();

                if (userQueues.isEmpty) {
                  return const Center(child: Text('คุณยังไม่มีคิว'));
                }

                final data = userQueues.last.data() as Map<String, dynamic>;
                final queueLabel = data['queueLabel'];
                final name = data['name'] ?? '-';
                final time = data['time'];
                final countdown = time != null ? getCountdown(time) : null;
                final bool isFinal =
                    countdown != null && countdown['isFinal'] == true;

                final Color bgColor = isFinal
                    ? Colors.red.withAlpha(38)
                    : Colors.blue.withAlpha(38);
                final Color textColor = isFinal ? Colors.red : Colors.blue;

                return SingleChildScrollView(
                  child: Column(
                    children: [

                      // 🔼 กล่องข้อความด้านบน (กำหนดกว้าง สูงตามข้อความ)
                      Container(
                        width: 500, // 👉 คุมความกว้างอย่างเดียว
                        margin: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 5,
                        ),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(255, 255, 255, 0.45),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.05),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          '\n'
                          '',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ),

                      // 🎫 กล่องคิว
                      Card(
                        color: const Color(0xFFE8F5F0), // 👉 สีพื้นหลังของการ์ด
                        elevation: 6,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              if (queueLabel != null)
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
                              Text('เวลาที่จอง $time'),
                              const SizedBox(height: 20),
                              if (countdown != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 24,
                                  ),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    countdown['text'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      // 🔼 กล่องข้อความด้านล่าง (กำหนดกว้าง สูงตามข้อความ)
                      Container(
                        width: 500, // 👉 คุมความกว้างอย่างเดียว
                        margin: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 5,
                        ),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(255, 255, 255, 0.45),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.05),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          'กรุณามาถึงก่อนเวลา 5 นาที\n'
                          'ขอบคุณมากครับ',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
