import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  bool isEditingName = true;
  bool isEditingPhone = true;

  @override
  void initState() {
    super.initState();
    _loadSavedUser();
  }

  Future<void> _loadSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('user_name');
    final savedPhone = prefs.getString('user_phone');

    if (savedName != null && savedPhone != null) {
      setState(() {
        nameController.text = savedName;
        phoneController.text = savedPhone;
        isEditingName = false;
        isEditingPhone = false;
      });
    }
  }

  Future<void> _saveUser(String name, String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('user_phone', phone);
  }

  void _login() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรอกชื่อและเบอร์โทรให้ครบก่อนนะครับ")),
      );
      return;
    }

    await _saveUser(name, phone);
    if (!mounted) return;
    // ---- เงื่อนไขเข้า Admin ----
    if (name == "admin" && phone == "2468") {
      Navigator.pushReplacementNamed(context, '/admin');
      return;
    }

    // ---- ผู้ใช้ทั่วไป ----
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: const Text("ร้านตัดผมชาย"),
        centerTitle: true,
        backgroundColor: const Color(0xFFE6F4EF),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            /// ---- ชื่อ ----
            isEditingName
                ? TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "ชื่อ",
                      border: OutlineInputBorder(),
                    ),
                  )
                : GestureDetector(
                    onTap: () {
                      setState(() {
                        isEditingName = true;
                        nameController.clear();
                      });
                    },
                    child: _infoBox("ชื่อ", nameController.text),
                  ),

            const SizedBox(height: 16),

            /// ---- เบอร์โทร ----
            isEditingPhone
                ? TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "เบอร์โทร",
                      border: OutlineInputBorder(),
                    ),
                  )
                : GestureDetector(
                    onTap: () {
                      setState(() {
                        isEditingPhone = true;
                        phoneController.clear();
                      });
                    },
                    child: _infoBox("เบอร์โทร", phoneController.text),
                  ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF93),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "เข้าใช้งาน",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// กล่องแสดงข้อมูล (แตะเพื่อแก้ไข)
  Widget _infoBox(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const Icon(Icons.edit, size: 18, color: Colors.grey),
        ],
      ),
    );
  }
}
