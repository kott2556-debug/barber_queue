import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.black87,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "เมนูผู้ดูแลระบบ",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // --- เมนู 1 ดูคิวทั้งหมด ---
            _adminMenuItem(
              icon: Icons.list_alt,
              title: "ดูคิวทั้งหมด",
              color: Colors.blueGrey.shade800,
              onTap: () {
                // ไปหน้า /queue ก็ได้ หรือทำหน้า admin ใหม่ก็ได้
                Navigator.pushNamed(context, '/queue');
              },
            ),

            const SizedBox(height: 15),

            // --- เมนู 2 จัดการคิว ---
            _adminMenuItem(
              icon: Icons.edit_calendar,
              title: "จัดการคิว",
              color: Colors.teal.shade700,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("ฟีเจอร์จะมาภายหลัง"))
                );
              },
            ),

            const SizedBox(height: 15),

            // --- เมนู 3 ตั้งค่า ---
            _adminMenuItem(
              icon: Icons.settings,
              title: "ตั้งค่าระบบ",
              color: Colors.indigo.shade700,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("ฟีเจอร์จะมาภายหลัง"))
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget ปุ่มเมนูแบบสวย ๆ ใช้ซ้ำ
  Widget _adminMenuItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(2, 3),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            )
          ],
        ),
      ),
    );
  }
}
