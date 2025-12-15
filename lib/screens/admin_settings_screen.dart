import 'package:flutter/material.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ตั้งค่าระบบ"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          ListTile(
            leading: Icon(Icons.access_time),
            title: Text("ตั้งค่าเวลารับคิว"),
            subtitle: Text("กำหนดช่วงเวลาที่เปิดจอง"),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.block),
            title: Text("ปิดรับคิว"),
            subtitle: Text("หยุดรับคิวชั่วคราว"),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.restart_alt),
            title: Text("ล้างคิวทั้งหมด"),
            subtitle: Text("ใช้เมื่อจบวัน"),
          ),
        ],
      ),
    );
  }
}
