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
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.zero,
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);

              await firestore.clearAllQueues();

              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("ล้างคิวทั้งหมดเรียบร้อย")),
              );

              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFD32F2F),
                    Color(0xFFFF5252),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: const Text(
                "ยืนยันล้างคิว",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
        backgroundColor: const Color(0xFF4CAF93), // ✅ สีเดียวกับระบบ Admin
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text("ตั้งค่าเวลารับคิว"),
            subtitle: const Text("กำหนดช่วงเวลาที่เปิดจอง"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminSetTimeScreen()),
              );
            },
          ),
          const Divider(),

          // ✅ เปิด / ปิดรับคิว
          ListTile(
            leading: Icon(
              isClosedForBooking ? Icons.lock_open : Icons.block,
              color: isClosedForBooking ? Colors.green : Colors.red,
              size: 32,
            ),
            title: Text(
              isClosedForBooking ? "เปิดรับคิว" : "ปิดรับคิว",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFE53935),
                    Color(0xFFFF6F60),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.restart_alt, color: Colors.white),
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
    );
  }
}
