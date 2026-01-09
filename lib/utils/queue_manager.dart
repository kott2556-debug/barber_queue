import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class QueueManager extends ChangeNotifier {
  // --------------------
  // Singleton
  // --------------------
  static final QueueManager _instance = QueueManager._internal();
  factory QueueManager() => _instance;
  QueueManager._internal() {
    _initDefaultTimes();
  }

  final FirestoreService _firestore = FirestoreService();

  // --------------------
  // ผู้ใช้ปัจจุบัน
  // --------------------
  String? _currentUserName;
  String? _currentUserPhone;

  String? get currentUserName => _currentUserName;
  String? get currentUserPhone => _currentUserPhone;

  void setCurrentUser({required String name, required String phone}) {
    _currentUserName = name;
    _currentUserPhone = phone;
    notifyListeners();
  }

  // --------------------
  // เวลาที่เปิดให้จอง
  // --------------------
  final List<String> _availableTimes = [];

  List<String> get availableTimes => List.unmodifiable(_availableTimes);

  void _initDefaultTimes() {
    if (_availableTimes.isEmpty) {
      _availableTimes.addAll([
        '07:00',
        '08:00',
        '09:00',
        '10:00',
        '11:00',
        '13:00',
        '14:30',
        '15:00',
        '16:30',
        '17:00',
      ]);
    }
  }

  void setAvailableTimes(List<String> times) {
    _availableTimes
      ..clear()
      ..addAll(times);
    notifyListeners();
  }

  // --------------------
  // เปิด / ปิดรับคิว
  // --------------------
  bool _isOpenForBooking = true;
  bool get isOpenForBooking => _isOpenForBooking;

  void setOpenForBooking(bool open) {
    _isOpenForBooking = open;
    notifyListeners();
  }

  // --------------------
  // คิวทั้งหมด (เก็บเผื่ออนาคต)
  // --------------------
  final List<Map<String, dynamic>> _bookings = [];

  List<Map<String, dynamic>> get bookings => _bookings;

  // --------------------
  // เพิ่มคิว
  // --------------------
  Future<void> addBooking({
    required String name,
    required String phone,
    required String time,
  }) async {
    await _firestore.addBookingTransaction(
      name: name,
      phone: phone,
      time: time,
      queueLabel: 'คิว ${_bookings.length + 1}',
    );
  }

  // --------------------
  // ล้างคิว (Admin)
  // --------------------
  void clearQueue() {
    _bookings.clear();
    notifyListeners();
  }
}
