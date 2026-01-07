import 'package:flutter/material.dart';
import 'admin_set_time_screen.dart';
import '../utils/queue_manager.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final QueueManager qm = QueueManager(); // เปลี่ยนจาก _qm → qm

    return Scaffold(
      appBar: AppBar(
        title: const Text("ตั้งค่าระบบ"),
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
            leading: const Icon(Icons.block),
            title: Text(qm.isOpenForBooking ? "ปิดรับคิว" : "เปิดรับคิว"),
            subtitle: Text(qm.isOpenForBooking
                ? "หยุดรับคิวชั่วคราว"
                : "เปิดรับคิวตามเวลาที่ตั้งไว้"),
            onTap: () {
              qm.setOpenForBooking(!qm.isOpenForBooking);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(qm.isOpenForBooking
                      ? "เปิดรับคิวเรียบร้อย"
                      : "ปิดรับคิวเรียบร้อย"),
                ),
              );
            },
          ),
          const Divider(),

          // ----------------------------
          // หัวข้อ 3: ล้างคิวทั้งหมด
          // ----------------------------
          ListTile(
            leading: const Icon(Icons.restart_alt),
            title: const Text("ล้างคิวทั้งหมด"),
            subtitle: const Text("ลบรายชื่อและเบอร์โทรของลูกค้าทั้งหมด"),
            onTap: () {
              // ล้างเฉพาะรายชื่อ/เบอร์ลูกค้า แต่ไม่กระทบเวลาที่ตั้งไว้
              qm.clearQueue();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("ล้างคิวลูกค้าทั้งหมดเรียลไทม์")),
              );
            },
          ),
        ],
      ),
    );
  }
}
