import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        centerTitle: true,
        backgroundColor: const Color(0xFF1F3C34),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- HEADER ----------
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F4EF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: const [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Color(0xFF4CAF93),
                    child: Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ผู้ดูแลระบบ",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "จัดการคิวและระบบร้าน",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "เมนูหลัก",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // ---------- MENU : ประวัติลูกค้า ----------
            _adminMenuCard(
              context: context,
              icon: Icons.history,
              title: "ประวัติลูกค้า",
              subtitle: "รายละเอียด • การเข้าใช้บริการ",
              color: const Color(0xFF4CAF93), // สีเดิม
              onTap: () {
                Navigator.pushNamed(context, '/admin/customer-history');
              },
            ),

            const SizedBox(height: 16),

            // ---------- MENU : จัดการคิว ----------
            _adminMenuCard(
              context: context,
              icon: Icons.edit_calendar,
              title: "จัดการคิว",
              subtitle: "เรียกคิว • ลบคิว • จบวัน",
              color: const Color(0xFF3F7F6A),
              onTap: () {
                Navigator.pushNamed(context, '/admin/manage');
              },
            ),

            const SizedBox(height: 16),

            // ---------- MENU : ตั้งค่า ----------
            _adminMenuCard(
              context: context,
              icon: Icons.settings,
              title: "ตั้งค่าระบบ",
              subtitle: "ตั้งค่าเวลาเปิดร้าน / ระบบ",
              color: const Color(0xFF2F5D50),
              onTap: () {
                Navigator.pushNamed(context, '/admin/settings');
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Reusable Menu Card ----------
  Widget _adminMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(22),
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 34),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white70,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
