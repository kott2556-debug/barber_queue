import 'package:flutter/material.dart';
import '../utils/queue_manager.dart';
import '../services/firestore_service.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final QueueManager qm = QueueManager();
  final FirestoreService firestore = FirestoreService();

  String? selectedTime;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: qm,
      builder: (context, _) {
        // ✅ ใช้เวลาทั้งหมดตามที่ Admin ตั้ง
        final times = qm.isOpenForBooking ? qm.availableTimes : [];

        return Scaffold(
          backgroundColor: const Color(0xFFF4F7F6),
          appBar: AppBar(
            title: const Text("จองคิว"),
            centerTitle: true,
            backgroundColor: const Color.fromARGB(255, 8, 158, 106),
            elevation: 0,
            foregroundColor: Colors.white,
          ),
          body: qm.isOpenForBooking
              ? StreamBuilder<List<String>>(
                  stream: firestore.streamLockedTimes(),
                  builder: (context, snapshot) {
                    final bookedTimes = snapshot.data ?? [];

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                      itemCount: times.length,
                      itemBuilder: (context, index) {
                        final time = times[index];
                        final queueLabel = qm.getQueueLabel(
                          time,
                        ); // ✅ ใช้จาก QM
                        final isBooked = bookedTimes.contains(time);
                        final isSelected = selectedTime == time;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Material(
                            elevation: isSelected ? 3 : 1,
                            borderRadius: BorderRadius.circular(24),
                            color: isBooked
                                ? Colors.grey.shade300
                                : isSelected
                                ? const Color(0xFFDFF3EC)
                                : Colors.white,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: isBooked
                                  ? null
                                  : () => setState(() => selectedTime = time),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 22,
                                  horizontal: 20,
                                ),
                                child: Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          queueLabel,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          time,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isBooked
                                                ? Colors.grey
                                                : Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    if (isBooked)
                                      const Icon(Icons.lock, color: Colors.grey)
                                    else if (isSelected)
                                      const Icon(
                                        Icons.check_circle,
                                        color: Color(0xFF4CAF93),
                                        size: 28,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                )
              : Center(
                  child: Text(
                    "ขณะนี้ปิดรับคิวชั่วคราว",
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                  ),
                ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed:
                  (!qm.isOpenForBooking ||
                      selectedTime == null ||
                      _isSubmitting)
                  ? null
                  : () async {
                      if (_isSubmitting) return;
                      setState(() => _isSubmitting = true);

                      if (qm.currentUserName == null ||
                          qm.currentUserPhone == null) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("กรุณา Login ใหม่")),
                          );
                        }
                        setState(() => _isSubmitting = false);
                        return;
                      }

                      try {
                        await qm.addBooking(
                          name: qm.currentUserName!,
                          phone: qm.currentUserPhone!,
                          time: selectedTime!,
                        );

                        if (!context.mounted) return;
                        Navigator.pushReplacementNamed(context, '/queue');
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "คิวนี้ถูกจองแล้ว หรือ คุณมีคิวอยู่แล้ว",
                            ),
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // 👈 เพิ่มบรรทัดนี้
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
