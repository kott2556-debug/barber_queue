import 'package:flutter/material.dart';
import '../utils/queue_manager.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookings = QueueManager().bookings;
    final latestBooking =
        bookings.isNotEmpty ? bookings.last : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: const Text("คิวของคุณ"),
        centerTitle: true,
        backgroundColor: const Color(0xFFE6F4EF),
        elevation: 0,
      ),
      body: Center(
        child: latestBooking == null
            ? const Text(
                "ยังไม่มีการจองคิว",
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF607D75),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Material(
                  elevation: 6,
                  shadowColor:
                      Colors.black.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(26),
                  color: Colors.white,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 26,
                      horizontal: 22,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      color: const Color(0xFFEAF7F2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.content_cut,
                          size: 30,
                          color: Color(0xFF4CAF93),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          "ฉันนัดตัดผม : ${latestBooking['time']}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color.fromARGB(255, 44, 94, 80),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
