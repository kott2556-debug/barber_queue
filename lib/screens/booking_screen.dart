import 'package:flutter/material.dart';
import '../utils/queue_manager.dart';
import '../services/firestore_service.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final QueueManager qm = QueueManager(); // ✅ ตรงกับ Singleton ของคุณ
  final FirestoreService firestore = FirestoreService();

  String? selectedTime;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: qm,
      builder: (context, _) {
        final times =
            qm.isOpenForBooking ? qm.availableTimes.take(10).toList() : [];

        return Scaffold(
          backgroundColor: const Color(0xFFF4F7F6),
          appBar: AppBar(
            title: const Text("จองคิว"),
            centerTitle: true,
            backgroundColor: const Color(0xFFE6F4EF),
            elevation: 0,
          ),

          // ================= BODY =================
          body: qm.isOpenForBooking
              ? ListView.builder(
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
                        color: isSelected
                            ? const Color(0xFFDFF3EC)
                            : Colors.white,
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
                                  duration:
                                      const Duration(milliseconds: 200),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check_circle,
                                          key: ValueKey('checked'),
                                          color: Color(0xFF4CAF93),
                                          size: 28,
                                        )
                                      : const SizedBox(
                                          key: ValueKey('empty'),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                )
              : Center(
                  child: Text(
                    "ขณะนี้ปิดรับคิวชั่วคราว",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                    ),
                  ),
                ),

          // ================= CONFIRM BUTTON =================
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: (!qm.isOpenForBooking ||
                      selectedTime == null ||
                      _isSubmitting)
                  ? null
                  : () async {
                      if (_isSubmitting) return;

                      setState(() => _isSubmitting = true);
                      final ctx = context;

                      // ตรวจสอบผู้ใช้
                      if (qm.currentUserName == null ||
                          qm.currentUserPhone == null) {
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(
                              content: Text("กรุณา Login ใหม่"),
                            ),
                          );
                        }
                        setState(() => _isSubmitting = false);
                        return;
                      }

                      try {
                        await firestore.addBookingTransaction(
                          name: qm.currentUserName!,
                          phone: qm.currentUserPhone!,
                          time: selectedTime!,
                        );

                        if (!ctx.mounted) return;
                        Navigator.pushReplacementNamed(ctx, '/queue');
                      } catch (e) {
                        if (!ctx.mounted) return;

                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text("คุณมีคิวอยู่แล้ว"),
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
                  : Text(
                      qm.isOpenForBooking
                          ? "ยืนยันจองคิว"
                          : "ปิดรับคิวชั่วคราว",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
