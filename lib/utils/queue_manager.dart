import 'package:flutter/material.dart';

class QueueManager extends ChangeNotifier {
  // --------------------
  // Singleton (ใช้ข้อมูลร่วมทั้งแอป)
  // --------------------
  static final QueueManager _instance = QueueManager._internal();
  factory QueueManager() => _instance;
  QueueManager._internal();

  // --------------------
  // ผู้ใช้ปัจจุบัน
  // --------------------
  String? _currentUserName;
  String? _currentUserPhone;

  String? get currentUserName => _currentUserName;
  String? get currentUserPhone => _currentUserPhone;

  void setCurrentUser({
    required String name,
    required String phone,
  }) {
    _currentUserName = name;
    _currentUserPhone = phone;
    notifyListeners();
  }

  // --------------------
  // เวลาที่เปิดให้จอง
  // --------------------
  final List<String> _availableTimes = [
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '12:00',
    '13:00',
    '13:30',
    '14:00',
    '14:30',
    '15:00',
  ];

  List<String> get availableTimes => _availableTimes;

  // --------------------
  // คิวทั้งหมด (Admin เห็นทั้งหมด)
  // --------------------
  final List<Map<String, dynamic>> _bookings = [];
  int _currentIndex = -1;

  List<Map<String, dynamic>> get bookings => _bookings;
  int get currentIndex => _currentIndex;

  Map<String, dynamic>? get currentQueue =>
      (_currentIndex >= 0 && _currentIndex < _bookings.length)
          ? _bookings[_currentIndex]
          : null;

  // --------------------
  // เพิ่มคิว (ลูกค้า)
  // --------------------
  void addBooking({
    required String name,
    required String phone,
    required String time,
  }) {
    _bookings.add({
      'name': name,
      'phone': phone,
      'time': time,
      'status': 'waiting', // waiting | serving | done
      'createdAt': DateTime.now(),
    });

    notifyListeners();
  }

  // --------------------
  // Admin เรียกคิวถัดไป
  // --------------------
  void callNextQueue() {
    if (_bookings.isEmpty) return;

    // ปิดคิวเก่า
    if (_currentIndex >= 0 && _currentIndex < _bookings.length) {
      _bookings[_currentIndex]['status'] = 'done';
    }

    _currentIndex++;

    // เปิดคิวใหม่
    if (_currentIndex < _bookings.length) {
      _bookings[_currentIndex]['status'] = 'serving';
    }

    notifyListeners(); // 🔥 realtime ทุกหน้า
  }

  // --------------------
  // คิวที่กำลังให้บริการ (ทุกคน)
  // --------------------
  Map<String, dynamic>? get servingQueue {
    try {
      return _bookings.firstWhere(
        (b) => b['status'] == 'serving',
      );
    } catch (_) {
      return null;
    }
  }

  // --------------------
  // 🔥 คิวของผู้ใช้ปัจจุบัน (ลูกค้าเห็นเฉพาะของตัวเอง)
  // --------------------
  List<Map<String, dynamic>> get myBookings {
    if (_currentUserPhone == null) return [];

    return _bookings
        .where((b) => b['phone'] == _currentUserPhone)
        .toList();
  }

  // คิวของฉันที่กำลังให้บริการ
  Map<String, dynamic>? get myServingQueue {
    try {
      return myBookings.firstWhere(
        (b) => b['status'] == 'serving',
      );
    } catch (_) {
      return null;
    }
  }

  // --------------------
  // ล้างคิวทั้งหมด (Admin)
  // --------------------
  void clearQueue() {
    _bookings.clear();
    _currentIndex = -1;
    notifyListeners();
  }
}
