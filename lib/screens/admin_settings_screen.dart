import 'package:flutter/material.dart';
import '../utils/queue_manager.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final qm = QueueManager();

  late bool isQueueOpen;
  late int maxQueue;
  late String openTime;
  late String closeTime;

  @override
  void initState() {
    super.initState();
    isQueueOpen = qm.isQueueOpen;
    maxQueue = qm.maxQueuePerDay;
    openTime = qm.openTime;
    closeTime = qm.closeTime;
  }

  Future<void> _pickTime(bool isOpenTime) async {
    final result = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );

    if (result == null) return;

    final time =
        "${result.hour.toString().padLeft(2, '0')}:${result.minute.toString().padLeft(2, '0')}";

    setState(() {
      if (isOpenTime) {
        openTime = time;
      } else {
        closeTime = time;
      }
    });
  }

  void _saveSettings() {
    qm.isQueueOpen = isQueueOpen;
    qm.maxQueuePerDay = maxQueue;
    qm.openTime = openTime;
    qm.closeTime = closeTime;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("บันทึกการตั้งค่าเรียบร้อย")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ตั้งค่าระบบ"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // เปิด / ปิด รับคิว
          SwitchListTile(
            title: const Text("เปิดรับคิว"),
            subtitle: Text(isQueueOpen ? "กำลังเปิดรับคิว" : "ปิดรับคิว"),
            value: isQueueOpen,
            onChanged: (v) => setState(() => isQueueOpen = v),
          ),

          const Divider(height: 30),

          // เวลาเปิดร้าน
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text("เวลาเปิดรับคิว"),
            trailing: Text(openTime),
            onTap: () => _pickTime(true),
          ),

          // เวลาปิดร้าน
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text("เวลาปิดรับคิว"),
            trailing: Text(closeTime),
            onTap: () => _pickTime(false),
          ),

          const Divider(height: 30),

          // จำนวนคิว
          Text(
            "จำนวนคิวต่อวัน: $maxQueue",
            style: const TextStyle(fontSize: 16),
          ),
          Slider(
            value: maxQueue.toDouble(),
            min: 1,
            max: 20,
            divisions: 19,
            label: maxQueue.toString(),
            onChanged: (v) => setState(() => maxQueue = v.toInt()),
          ),

          const SizedBox(height: 30),

          ElevatedButton(
            onPressed: _saveSettings,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 55),
            ),
            child: const Text(
              "บันทึกการตั้งค่า",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
