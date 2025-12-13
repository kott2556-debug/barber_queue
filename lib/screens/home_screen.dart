import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            // ปุ่มแรก
            SizedBox(
              width: double.infinity, // ปุ่มเต็มหน้าจอแนวนอน
              height: 70, // สูงขึ้น
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 117, 236, 203), // สีโทนอ่อน
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24), // มน ๆ
                  ),
                  elevation: 4, // เพิ่มมิติ
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/booking');
                },
                child: const Text(
                  'จองคิว',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 24), // เว้นระยะปุ่มแนวดิ่ง

            // ปุ่มที่สอง
            SizedBox(
              width: double.infinity,
              height: 70, // สูงขึ้น
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB2DFCC), // สีโทนอ่อน
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
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
