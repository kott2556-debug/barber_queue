import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_set_time_screen.dart';
import '../utils/queue_manager.dart';
import '../services/firestore_service.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final QueueManager qm = QueueManager();
  final FirestoreService firestore = FirestoreService();

  bool isClosedForBooking = false;

  @override
  void initState() {
    super.initState();
    isClosedForBooking = !qm.isOpenForBooking;
    qm.addListener(_updateState);
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

  // ===============================
  // ล้างคิวทั้งหมด
  // ===============================
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
            child: const Text("ยืนยันล้าง"),
          ),
        ],
      ),
    );
  }

  // ===============================
  // popup เลือกล้างคิว 1 คิว
  // ===============================
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

              if (docs.isEmpty) {
                return const Text("ไม่มีคิวในระบบ");
              }

              final sortedDocs = [...docs];
              sortedDocs.sort((a, b) {
                int getNum(String s) =>
                    int.tryParse(
                      RegExp(r'\d+').firstMatch(s)?.group(0) ?? '',
                    ) ??
                    999;
                return getNum(a['queueLabel'])
                    .compareTo(getNum(b['queueLabel']));
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

  // ===============================
  // popup ยืนยันล้างคิวเดียว
  // ===============================
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
            child: const Text("ยืนยันล้าง"),
          ),
        ],
      ),
    );
  }

  // ===============================
  // UI
  // ===============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ตั้งค่าระบบ Admin"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 14, 172, 127),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(
            leading: const Icon(Icons.access_time, size: 45, color: Colors.blue),
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
            leading: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red, width: 2),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.delete, color: Colors.red),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.red, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '1',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            title: const Text(
              "ล้างคิว 1 คิว",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text("กรณีลูกค้ายกเลิกหรือเปลี่ยนเวลาจอง"),
            onTap: _openClearSingleQueuePopup,
          ),

          const Divider(),

          ListTile(
            leading:
                const Icon(Icons.restart_alt, size: 55, color: Colors.red),
            title: const Text(
              "ล้างคิวทั้งหมด",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text("ลบข้อมูลคิวลูกค้าทั้งหมด"),
            onTap: _confirmClearAllQueues,
          ),
        ],
      ),
    );
  }
}
