import 'package:flutter/material.dart';
import '../utils/queue_manager.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String? selectedTime;

  @override
  Widget build(BuildContext context) {
    final times = QueueManager().availableTimes.take(10).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: const Text("จองคิว"),
        centerTitle: true,
        backgroundColor: const Color(0xFFE6F4EF),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: times.length,
        itemBuilder: (context, index) {
          final time = times[index];
          final isSelected = selectedTime == time;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Material(
              elevation: isSelected ? 3 : 6,
              shadowColor: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(24),
              color: isSelected ? const Color(0xFFDFF3EC) : Colors.white,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                splashColor: const Color(0xFFBEE7D8).withValues(alpha: 0.4),
                onTap: () {
                  setState(() {
                    selectedTime = time;
                  });

                  QueueManager().addBooking(time);

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('เลือกคิวเวลา $time แล้ว')),
                  );
                },
                child: Container(
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
                          color: Color(0xFF2F5D50),
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
    );
  }
}
