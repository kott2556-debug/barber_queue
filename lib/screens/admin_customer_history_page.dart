import 'package:flutter/material.dart';

class AdminCustomerHistoryPage extends StatelessWidget {
  const AdminCustomerHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: const Text("ประวัติลูกค้า"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 11, 167, 122),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    SizedBox(height: 50),
                    Center(
                      child: Text(
                        "อยู่ระหว่างพัฒนา",
                        style: TextStyle(
                          color: Colors.black38,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: 50),
                    // ต่อไปสามารถเพิ่มรายการประวัติ หรือ Widget อื่นๆ ที่ scroll ได้
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
