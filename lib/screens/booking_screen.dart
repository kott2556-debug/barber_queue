import 'package:flutter/material.dart';
import '../utils/queue_manager.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String? selectedTime; // เวลาที่ผู้ใช้เลือก

  @override
  Widget build(BuildContext context) {
    // เวลาที่ Admin ตั้ง → จำกัดแค่ 10 เวลา
    final times = QueueManager().availableTimes.take(10).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("จองคิว")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: times.length,
        itemBuilder: (context, index) {
          final time = times[index];

          final isSelected = selectedTime == time;

          return GestureDetector(
            onTap: () {
              // ถ้ากดไปแล้ว ห้ามกดซ้ำ
              if (selectedTime != null) return;

              setState(() {
                selectedTime = time;
              });

              // บันทึกคิวจริง
              QueueManager().addBooking(time);

              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('จองคิวเวลา $time สำเร็จ')),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.green.shade100 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.green : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    time,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const Spacer(),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: Colors.green)
                  else if (selectedTime != null)
                    const Icon(Icons.lock, color: Colors.grey)
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
