import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/queue_manager.dart';
import '../utils/queue_time_calculator.dart';

class AdminSetTimeScreen extends StatefulWidget {
  const AdminSetTimeScreen({super.key});

  @override
  State<AdminSetTimeScreen> createState() => _AdminSetTimeScreenState();
}

class _AdminSetTimeScreenState extends State<AdminSetTimeScreen> {
  final QueueManager _qm = QueueManager();

  int _numQueues = 10;
  int _minutesPerQueue = 30;
  List<String> _previewTimes = [];

  @override
  void initState() {
    super.initState();
    _loadFromManager();
  }

  Future<void> _loadFromManager() async {
    while (!_qm.settingsLoaded) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    if (!mounted) return;

    setState(() {
      _numQueues = _qm.totalQueues;
      _minutesPerQueue = _qm.minutesPerQueue;
      _previewTimes = List.from(_qm.availableTimes);
    });
  }

  Future<void> _save() async {
    final times = QueueTimeCalculator.generateWithLunchAnchor(
      totalQueues: _numQueues,
      minutesPerQueue: _minutesPerQueue,
    );

    await _qm.saveQueueSettings(
      times: times,
      totalQueues: _numQueues,
      minutesPerQueue: _minutesPerQueue,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('บันทึกเวลารับคิวเรียบร้อย')),
    );

    setState(() {
      _previewTimes = times;
    });
  }

  @override
  Widget build(BuildContext context) {
    final morningTimes =
        _previewTimes.where((t) => t.compareTo('12:00') < 0).toList();
    final afternoonTimes =
        _previewTimes.where((t) => t.compareTo('13:00') >= 0).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ตั้งเวลารับคิว'),
        backgroundColor: const Color.fromARGB(255, 13, 168, 124),
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'หยุดพักเที่ยง 12:00 – 13:00',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // จำนวนคิว
            Row(
              children: [
                const Text('จำนวนคิว: '),
                Expanded(
                  child: Slider(
                    value: _numQueues.toDouble(),
                    min: 10,
                    max: 16,
                    divisions: 6,
                    label: '$_numQueues',
                    onChanged: (v) =>
                        setState(() => _numQueues = v.round()),
                  ),
                ),
                Text('$_numQueues'),
              ],
            ),

            // นาทีต่อคิว
            Row(
              children: [
                const Text('นาทีต่อคิว: '),
                Expanded(
                  child: Slider(
                    value: _minutesPerQueue.toDouble(),
                    min: 20,
                    max: 60,
                    divisions: 40,
                    label: '$_minutesPerQueue',
                    onChanged: (v) =>
                        setState(() => _minutesPerQueue = v.round()),
                  ),
                ),
                Text('$_minutesPerQueue นาที'),
              ],
            ),

            const SizedBox(height: 20),

            // ปุ่มบันทึก
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color.fromARGB(255, 132, 218, 193),
              ),
              child: const Text('บันทึกคิว', style: TextStyle(fontSize: 18)),
            ),

            const SizedBox(height: 24),

            if (_previewTimes.isNotEmpty) ...[
              const Text(
                'ตัวอย่างเวลาคิว',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              for (final t in morningTimes) Text(t),

              const SizedBox(height: 12),
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'พักเที่ยง 12:00 – 13:00',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 12),

              for (final t in afternoonTimes) Text(t),
            ],
          ],
        ),
      ),
    );
  }
}
