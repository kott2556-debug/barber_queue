import 'package:flutter/material.dart';
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
    isClosedForBooking = qm.availableTimes.isEmpty;
    qm.addListener(_updateState);
  }

  @override
  void dispose() {
    qm.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    setState(() {
      isClosedForBooking = qm.availableTimes.isEmpty;
    });
  }

  void _toggleBooking() {
    if (isClosedForBooking) {
      if (qm.availableTimes.isEmpty) {
        qm.setAvailableTimes([
          '07:00',
          '08:00',
          '09:00',
          '10:00',
          '11:00',
          '13:00',
          '14:00',
          '15:00',
          '16:00',
          '17:00',
        ]);
      }
      qm.setOpenForBooking(true);
    } else {
      qm.setOpenForBooking(false);
    }

    setState(() {
      isClosedForBooking = !qm.isOpenForBooking;
    });
  }

  // ===============================
  // 🔥 ล้างคิวทั้งหมด + ยืนยัน
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
          child: const Text("ยกเลิก"),
          onPressed: () => Navigator.pop(dialogContext),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text("ยืนยันล้างคิว"),
          onPressed: () async {
            Navigator.pop(dialogContext);

            // 🔒 เก็บ context ไว้ก่อน async
            final navigator = Navigator.of(context);
            final messenger = ScaffoldMessenger.of(context);

            await firestore.clearAllQueues();

            if (!mounted) return;

            messenger.showSnackBar(
              const SnackBar(content: Text("ล้างคิวทั้งหมดเรียบร้อย")),
            );

            navigator.pushNamedAndRemoveUntil(
              '/',
              (route) => false,
            );
          },
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
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ----------------------------
          // ตั้งค่าเวลารับคิว
          // ----------------------------
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text("ตั้งค่าเวลารับคิว"),
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

          // ----------------------------
          // เปิด / ปิดรับคิว
          // ----------------------------
          ListTile(
            leading: Icon(isClosedForBooking ? Icons.lock_open : Icons.block),
            title: Text(isClosedForBooking ? "เปิดรับคิว" : "ปิดรับคิว"),
            subtitle: Text(
              isClosedForBooking
                  ? "สถานะ: ปิดอยู่ (แตะเพื่อเปิด)"
                  : "สถานะ: เปิดอยู่ (แตะเพื่อปิด)",
            ),
            onTap: _toggleBooking,
          ),
          const Divider(),

          // ----------------------------
          // ล้างคิวทั้งหมด
          // ----------------------------
          ListTile(
            leading: const Icon(Icons.restart_alt, color: Colors.red),
            title: const Text("ล้างคิวทั้งหมด"),
            subtitle: const Text("ลบข้อมูลคิวลูกค้าทั้งหมด"),
            onTap: _confirmClearAllQueues,
          ),
        ],
      ),
    );
  }
}
