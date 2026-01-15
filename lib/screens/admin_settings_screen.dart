import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_set_time_screen.dart';
import '../utils/queue_manager.dart';
import '../services/firestore_service.dart';
import 'package:intl/intl.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final QueueManager qm = QueueManager();
  final FirestoreService firestore = FirestoreService();
  final FirebaseFirestore db = FirebaseFirestore.instance;
  

  bool isClosedForBooking = false;
  bool _autoChecked = false; // กันรันซ้ำ

  @override
  void initState() {
    super.initState();
    isClosedForBooking = !qm.isOpenForBooking;
    qm.addListener(_updateState);

    // 👉 เช็ค auto กึ่งอัตโนมัติ
    _checkAutoClearIfNeeded();
  }

  @override
  void dispose() {
    qm.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    setState(() {
      isClosedForBooking = !qm.isOpenForBooking;
    });
  }

  void _toggleBooking() {
    qm.setOpenForBooking(!qm.isOpenForBooking);
  }

  /// ===============================
  /// 🔁 AUTO กึ่งอัตโนมัติ (ไม่ใช้ Cloud Function)
  /// ===============================
  Future<void> _checkAutoClearIfNeeded() async {
    if (_autoChecked) return;
    _autoChecked = true;

    try {
      final snap = await db
          .collection('system_settings')
          .doc('queue_clear')
          .get();
      if (!snap.exists) return;

      final data = snap.data()!;
      final mode = data['mode'];
      final autoEnabled = data['autoEnabled'] == true;
      final lastClearedDate = data['lastClearedDate'] as String?;

      // 🔒 ตอนนี้คุณตั้ง manual → จะไม่เข้าเงื่อนไขนี้
      if (mode != 'auto' || !autoEnabled) return;

      final now = DateTime.now();
      final today = DateFormat('yyyy-MM-dd').format(now);

      if (lastClearedDate == today) return;
      if (now.hour != 0) return;


      // 👉 ล้างคิวทั้งหมด
      await firestore.clearAllQueues();

      // 👉 บันทึกวันที่ล้าง
      await db.collection('system_settings').doc('queue_clear').update({
        'lastClearedDate': today,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ล้างคิวอัตโนมัติแล้ว')));
    } catch (e) {
      debugPrint('Auto clear error: $e');
    }
  }

  /// ===============================
  /// 🔴 ล้างคิวทั้งหมด (Manual)
  /// ===============================
  void _confirmClearAllQueues() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("ยืนยันการล้างคิว"),
        content: const Text(
          "การล้างคิวจะลบข้อมูลลูกค้าทั้งหมด\nไม่สามารถกู้คืนได้\n\nต้องการดำเนินการต่อหรือไม่?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("ยกเลิก"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(dialogContext);
              final messenger = ScaffoldMessenger.of(context);
              await firestore.clearAllQueues();
              if (!mounted) return;
              messenger.showSnackBar(
                const SnackBar(content: Text("ล้างคิวทั้งหมดเรียบร้อย")),
              );
            },
            child: const Text(
              "ยืนยันล้าง",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// ===============================
  /// 🔵 ล้างทีละคิว (Manual)
  /// ===============================
  void _openClearSingleQueuePopup() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("เลือกคิวที่ต้องการล้าง"),
        content: SizedBox(
          width: double.maxFinite,
          child: StreamBuilder<QuerySnapshot>(
            stream: firestore.streamBookings(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) return const Text("ไม่มีคิวในระบบ");

              final sortedDocs = [...docs];
              sortedDocs.sort((a, b) {
                int getNum(String s) =>
                    int.tryParse(
                      RegExp(r'\d+').firstMatch(s)?.group(0) ?? '',
                    ) ??
                    999;
                return getNum(
                  a['queueLabel'],
                ).compareTo(getNum(b['queueLabel']));
              });

              return ListView.builder(
                shrinkWrap: true,
                itemCount: sortedDocs.length,
                itemBuilder: (context, index) {
                  final doc = sortedDocs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(
                      data['queueLabel'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("${data['name']} • ${data['phone']}"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pop(dialogContext);
                      _confirmClearSingleQueue(
                        bookingId: doc.id,
                        queueLabel: data['queueLabel'],
                        phone: data['phone'],
                        time: data['time'],
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("ยกเลิก"),
          ),
        ],
      ),
    );
  }

  void _confirmClearSingleQueue({
    required String bookingId,
    required String queueLabel,
    required String phone,
    required String time,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("ยืนยันการล้างคิว"),
        content: Text(
          "ต้องการล้าง $queueLabel ใช่หรือไม่?\n\nข้อมูลจะไม่สามารถกู้คืนได้",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("ยกเลิก"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(dialogContext);
              final messenger = ScaffoldMessenger.of(context);
              await firestore.clearSingleQueue(
                bookingId: bookingId,
                phone: phone,
                time: time,
              );
              if (!mounted) return;
              messenger.showSnackBar(
                SnackBar(content: Text("ล้าง $queueLabel เรียบร้อย")),
              );
            },
            child: const Text(
              "ยืนยันล้าง",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ตั้งค่าระบบ Admin"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 14, 172, 127),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.access_time,
                  size: 45,
                  color: Colors.blue,
                ),
                title: const Text(
                  "ตั้งค่าเวลารับคิว",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text("กำหนดช่วงเวลาที่เปิดจอง"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminSetTimeScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(
                  isClosedForBooking ? Icons.lock_open : Icons.block,
                  color: isClosedForBooking ? Colors.green : Colors.red,
                  size: 45,
                ),
                title: Text(
                  isClosedForBooking ? "เปิดรับคิว" : "ปิดรับคิว",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  isClosedForBooking
                      ? "สถานะ: ปิดอยู่ (แตะเพื่อเปิด)"
                      : "สถานะ: เปิดอยู่ (แตะเพื่อปิด)",
                ),
                onTap: _toggleBooking,
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete, size: 45, color: Colors.red),
                title: const Text(
                  "ล้างคิว 1 คิว",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text("กรณีลูกค้ายกเลิกหรือเปลี่ยนเวลาจอง"),
                onTap: _openClearSingleQueuePopup,
              ),
              const Divider(),
              ListTile(
                leading: const Icon(
                  Icons.restart_alt,
                  size: 55,
                  color: Colors.red,
                ),
                title: const Text(
                  "ล้างคิวทั้งหมด",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text("ลบข้อมูลคิวลูกค้าทั้งหมด"),
                onTap: _confirmClearAllQueues,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
