import 'package:flutter/material.dart';
import '../utils/queue_manager.dart';

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
    if (times.isNotEmpty) {
      _generatedTimes = List.from(times);

      final first = times.first.split(':');
      _startTime = TimeOfDay(
        hour: int.tryParse(first[0]) ?? 10,
        minute: int.tryParse(first[1]) ?? 0,
      );

      _numQueues = times.length;

      if (times.length >= 2) {
        final firstMinutes = (int.tryParse(times[0].split(':')[0]) ?? 0) * 60 +
            (int.tryParse(times[0].split(':')[1]) ?? 0);
        final secondMinutes = (int.tryParse(times[1].split(':')[0]) ?? 0) * 60 +
            (int.tryParse(times[1].split(':')[1]) ?? 0);

        int diff = secondMinutes - firstMinutes;
        if (diff <= 0) diff = 30;
        _minutesPerQueue = diff.clamp(5, 120);
      }
    }
  }

  void _generateAvailableTimes() {
    if (_startTime == null) return;

    _generatedTimes.clear();
    DateTime current = DateTime(0, 0, 0, _startTime!.hour, _startTime!.minute);

    for (int i = 0; i < _numQueues; i++) {
      String formatted =
          "${current.hour.toString().padLeft(2, '0')}:${current.minute.toString().padLeft(2, '0')}";
      _generatedTimes.add(formatted);
      current = current.add(Duration(minutes: _minutesPerQueue));
    }
  }

  void _saveToQueueManager() {
    _generateAvailableTimes();
    _qm.setAvailableTimes(_generatedTimes);

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
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text('เวลาเริ่มรับคิว'),
              subtitle: Text(
                _startTime != null ? _startTime!.format(context) : 'ยังไม่ได้เลือก',
              ),
              trailing: ElevatedButton(
                onPressed: () async {
                  final t = await showTimePicker(
                    context: context,
                    initialTime: _startTime ?? const TimeOfDay(hour: 10, minute: 0),
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
                    value: _numQueues.toDouble().clamp(1, 20),
                    min: 1,
                    max: 20,
                    divisions: 19,
                    label: "$_numQueues",
                    onChanged: (v) => setState(() => _numQueues = v.toInt()),
                  ),
                ),
                Text("$_numQueues"),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                const Text('นาทีต่อคิว: '),
                Expanded(
                  child: Slider(
                    value: _minutesPerQueue.toDouble().clamp(5, 120),
                    min: 5,
                    max: 120,
                    divisions: 23,
                    label: "$_minutesPerQueue",
                    onChanged: (v) => setState(() => _minutesPerQueue = v.toInt()),
                  ),
                ),
                Text("$_minutesPerQueue นาที"),
              ],
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: (_startTime != null) ? _saveToQueueManager : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFF4CAF93),
              ),
              child: const Text('บันทึกคิว', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),

            if (_generatedTimes.isNotEmpty)
              const Text("เวลาคิวที่กำหนด:", style: TextStyle(fontWeight: FontWeight.bold)),
            for (var e in _generatedTimes) Text(e),
          ],
        ),
      ),
    );
  }
}
