import 'package:flutter/material.dart';
import '../utils/queue_manager.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final qm = QueueManager();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: const Text('หน้าหลัก'),
        centerTitle: true,
        backgroundColor: const Color(0xFFE6F4EF),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ================== ปุ่มจองคิว ==================
            SizedBox(
              width: double.infinity,
              height: 70,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color.fromARGB(255, 167, 233, 214),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 4,
                ),
                onPressed: () {
                  // ถ้ายังไม่มี user (กันกรณีหลุด)
                  if (qm.currentUserName == null ||
                      qm.currentUserPhone == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("กรุณา Login ก่อน"),
                      ),
                    );
                    return;
                  }

                  Navigator.pushNamed(context, '/booking');
                },
                child: const Text(
                  'จองคิว',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ================== ปุ่มดูคิวของฉัน ==================
            SizedBox(
              width: double.infinity,
              height: 70,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color.fromARGB(255, 155, 229, 198),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 4,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/queue');
                },
                child: const Text(
                  'ดูคิวของฉัน',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
