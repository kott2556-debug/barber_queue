import 'package:flutter/material.dart';
import '../utils/queue_manager.dart';
import '../utils/queue_time_calculator.dart';

class AdminSetTimeScreen extends StatefulWidget {
  const AdminSetTimeScreen({super.key});

  @override
  State<AdminSetTimeScreen> createState() => _AdminSetTimeScreenState();
}

class _AdminSetTimeScreenState extends State<AdminSetTimeScreen> {
  TimeOfDay? _startTime;
  int _numQueues = 10;
  int _minutesPerQueue = 30;

  final QueueManager _qm = QueueManager();

  List<String> _generatedTimes = [];

  @override
  void initState() {
    super.initState();
    _loadExistingTimes();
  }

  void _loadExistingTimes() {
    final times = _qm.availableTimes;
    if (times.isEmpty) return;

    _generatedTimes = List.from(times);

    final first = times.first.split(':');
    _startTime = TimeOfDay(
      hour: int.parse(first[0]),
      minute: int.parse(first[1]),
    );

    _numQueues = times.length;

    if (times.length >= 2) {
      final firstMin =
          int.parse(times[0].split(':')[0]) * 60 +
          int.parse(times[0].split(':')[1]);
      final secondMin =
          int.parse(times[1].split(':')[0]) * 60 +
          int.parse(times[1].split(':')[1]);

      _minutesPerQueue = (secondMin - firstMin).clamp(5, 120);
    }
  }

  void _generateTimes() {
    if (_startTime == null) return;

    _generatedTimes = QueueTimeCalculator.generateTimes(
      startTime: _startTime!,
      count: _numQueues,
      minutesPerQueue: _minutesPerQueue,
    );
  }

  Future<void> _save() async {
    _generateTimes();
    await _qm.saveAvailableTimes(_generatedTimes);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('บันทึกเวลารับคิวเรียบร้อย')),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ตั้งเวลารับคิว'),
        backgroundColor: const Color(0xFF4CAF93),
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text('เวลาเริ่มรับคิว'),
              subtitle: Text(
                _startTime != null
                    ? _startTime!.format(context)
                    : 'ยังไม่ได้เลือก',
              ),
              trailing: ElevatedButton(
                onPressed: () async {
                  final t = await showTimePicker(
                    context: context,
                    initialTime:
                        _startTime ?? const TimeOfDay(hour: 9, minute: 0),
                  );
                  if (t != null) setState(() => _startTime = t);
                },
                child: const Text('เลือก'),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                const Text('จำนวนคิว: '),
                Expanded(
                  child: Slider(
                    value: _numQueues.toDouble(),
                    min: 1,
                    max: 20,
                    divisions: 19,
                    label: '$_numQueues',
                    onChanged: (v) =>
                        setState(() => _numQueues = v.toInt()),
                  ),
                ),
                Text('$_numQueues'),
              ],
            ),

            Row(
              children: [
                const Text('นาทีต่อคิว: '),
                Expanded(
                  child: Slider(
                    value: _minutesPerQueue.toDouble(),
                    min: 5,
                    max: 120,
                    divisions: 23,
                    label: '$_minutesPerQueue',
                    onChanged: (v) =>
                        setState(() => _minutesPerQueue = v.toInt()),
                  ),
                ),
                Text('$_minutesPerQueue นาที'),
              ],
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startTime == null ? null : _save,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFF4CAF93),
              ),
              child: const Text(
                'บันทึกคิว',
                style: TextStyle(fontSize: 18),
              ),
            ),

            const SizedBox(height: 20),
            if (_generatedTimes.isNotEmpty)
              const Text(
                'เวลาคิวที่กำหนด:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            for (final t in _generatedTimes) Text(t),
          ],
        ),
      ),
    );
  }
}
