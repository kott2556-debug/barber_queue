import 'package:flutter/material.dart';
import 'admin_set_time_screen.dart';
import '../utils/queue_manager.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final QueueManager qm = QueueManager();
  bool isClosedForBooking = false; // true = ปิดรับคิวชั่วคราว

  @override
  void initState() {
    super.initState();
    // เช็คตอนเริ่มว่า availableTimes ว่างหรือไม่
    isClosedForBooking = qm.availableTimes.isEmpty;
    // ฟังการเปลี่ยนแปลง realtime
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
    // ถ้าเปิดรับคิว และยังไม่มีเวลาตั้งไว้
    final times = qm.availableTimes;

    if (times.isEmpty) {
      qm.setAvailableTimes([
        '10:00',
        '10:30',
        '11:00',
        '11:30',
        '12:00',
        '13:00',
        '13:30',
        '14:00',
        '14:30',
        '15:00',
      ]);
    }

    qm.setOpenForBooking(true);
  } else {
    // ปิดรับคิว
    qm.setOpenForBooking(false);
  }

  setState(() {
    isClosedForBooking = !qm.isOpenForBooking;
  });
}


  void _clearCustomerQueue() {
    // ล้างเฉพาะลูกค้า ไม่กระทบเวลาที่ตั้งไว้
    qm.clearQueue();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("ล้างคิวลูกค้าทั้งหมดเรียบร้อย")),
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
          // หัวข้อ 1: ตั้งค่าเวลารับคิว
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
          // หัวข้อ 2: ปิด/เปิดรับคิว
          // ----------------------------
          ListTile(
            leading: Icon(isClosedForBooking ? Icons.lock_open : Icons.block),
            title: Text(isClosedForBooking ? "เปิดรับคิว" : "ปิดรับคิว"),
            subtitle: Text(isClosedForBooking
                ? "สถานะ: ปัจจุบันปิดอยู่ คลิกเพื่อเปิด"
                : "สถานะ: ปัจจุบันเปิดอยู่ คลิกเพื่อปิด"),
            onTap: _toggleBooking,
          ),
          const Divider(),

          // ----------------------------
          // หัวข้อ 3: ล้างคิวลูกค้าทั้งหมด
          // ----------------------------
          ListTile(
            leading: const Icon(Icons.restart_alt),
            title: const Text("ล้างคิวทั้งหมด"),
            subtitle: const Text("ลบรายชื่อและเบอร์โทรของลูกค้าทั้งหมด"),
            onTap: _clearCustomerQueue,
          ),
        ],
      ),
    );
  }
}
