import 'package:flutter/material.dart';
import '../utils/queue_manager.dart';
import '../services/firestore_service.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String? selectedTime;

  final QueueManager qm = QueueManager();
  final FirestoreService firestore = FirestoreService();

  bool _isSubmitting = false; // ✅ กันกดซ้ำ

  @override
  Widget build(BuildContext context) {
    final times = qm.availableTimes.take(10).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: const Text("จองคิว"),
        centerTitle: true,
        backgroundColor: const Color(0xFFE6F4EF),
        elevation: 0,
      ),

      // ================= BODY =================
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        itemCount: times.length,
        itemBuilder: (context, index) {
          final time = times[index];
          final bool isSelected = selectedTime == time;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Material(
              elevation: isSelected ? 3 : 6,
              borderRadius: BorderRadius.circular(24),
              color: isSelected ? const Color(0xFFDFF3EC) : Colors.white,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: _isSubmitting
                    ? null
                    : () {
                        setState(() {
                          selectedTime = time;
                        });
                      },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 22,
                    horizontal: 20,
                  ),
                  child: Row(
                    children: [
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: isSelected
                            ? const Icon(
                                Icons.check_circle,
                                key: ValueKey('checked'),
                                color: Color(0xFF4CAF93),
                                size: 28,
                              )
                            : const SizedBox(key: ValueKey('empty')),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),

      // ================= CONFIRM BUTTON =================
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: (selectedTime == null || _isSubmitting)
              ? null
              : () async {
                  if (_isSubmitting) return;

                  setState(() {
                    _isSubmitting = true; // 🔒 ปิดปุ่มทันที
                  });

                  final ctx = context;

                  try {
                    // 🔐 เช็ค user
                    if (qm.currentUserName == null ||
                        qm.currentUserPhone == null) {
                      if (!ctx.mounted) return;
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text("กรุณา Login ใหม่")),
                      );
                      setState(() => _isSubmitting = false);
                      return;
                    }

                    // 🔄 กันจองซ้ำ
                    final hasQueue = await firestore.hasActiveBooking(
                      qm.currentUserPhone!,
                    );

                    if (hasQueue) {
                      if (!ctx.mounted) return;
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text("คุณมีคิวอยู่แล้ว")),
                      );
                      setState(() => _isSubmitting = false);
                      return;
                    }

                    // 🔥 เพิ่มข้อมูลเข้า Firestore
                    await firestore.addBooking(
                      name: qm.currentUserName!,
                      phone: qm.currentUserPhone!,
                      time: selectedTime!,
                    );

                    if (!ctx.mounted) return;

                    // ✅ ไปหน้าคิว (Back ไม่ย้อนกลับ)
                    Navigator.pushReplacementNamed(ctx, '/queue');
                  } catch (e) {
                    if (!ctx.mounted) return;
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text("เกิดข้อผิดพลาด กรุณาลองใหม่"),
                      ),
                    );
                    setState(() => _isSubmitting = false);
                  }
                },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            backgroundColor: const Color(0xFF4CAF93),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  "ยืนยันจองคิว",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}
