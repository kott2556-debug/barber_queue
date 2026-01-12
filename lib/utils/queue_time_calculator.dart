import 'package:flutter/material.dart';

class QueueTimeCalculator {
  /// สร้างเวลาคิวตามที่ Admin ตั้ง
  /// [startTime] เวลาเริ่ม
  /// [count] จำนวนคิว
  /// [minutesPerQueue] นาทีต่อคิว
  static List<String> generateTimes({
    required TimeOfDay startTime,
    required int count,
    required int minutesPerQueue,
  }) {
    final List<String> result = [];

    DateTime current = DateTime(
      0,
      1,
      1,
      startTime.hour,
      startTime.minute,
    );

    for (int i = 0; i < count; i++) {
      result.add(
        '${current.hour.toString().padLeft(2, '0')}:'
        '${current.minute.toString().padLeft(2, '0')}',
      );

      current = current.add(
        Duration(minutes: minutesPerQueue),
      );
    }

    return result;
  }
}
