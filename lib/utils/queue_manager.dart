import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class QueueManager extends ChangeNotifier {
  // --------------------
  // Singleton
  // --------------------
  static final QueueManager _instance = QueueManager._internal();
  factory QueueManager() => _instance;

  QueueManager._internal() {
    _listenBookingStatus();
    _listenAvailableTimes(); // 🔥 ฟังเวลาคิวจาก Firestore
  }

  final FirestoreService _firestore = FirestoreService();

  StreamSubscription<DocumentSnapshot>? _bookingStatusSub;
  StreamSubscription<DocumentSnapshot>? _availableTimesSub;

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
  // เวลาที่เปิดให้จอง (จาก Firestore เท่านั้น)
  // --------------------
  final List<String> _availableTimes = [];
  List<String> get availableTimes => List.unmodifiable(_availableTimes);

  // --------------------
  // 🏷️ แปลงเวลา → ป้ายคิว
  // --------------------
  String getQueueLabel(String time) {
    final index = _availableTimes.indexOf(time);
    if (index == -1) return '';
    return 'คิว ${index + 1}';
  }

  // --------------------
  // 🔥 Admin บันทึกเวลาคิว
  // --------------------
  Future<void> saveAvailableTimes(List<String> times) async {
    _availableTimes
      ..clear()
      ..addAll(times);

    await FirebaseFirestore.instance
        .collection('system_settings')
        .doc('queue_times')
        .set({
      'times': times,
    });

    notifyListeners();
  }

  // --------------------
  // 🔥 Sync เวลาคิวจาก Firestore (Realtime)
  // --------------------
  void _listenAvailableTimes() {
    _availableTimesSub = FirebaseFirestore.instance
        .collection('system_settings')
        .doc('queue_times')
        .snapshots()
        .listen((doc) {
      if (!doc.exists) return;

      final data = doc.data() as Map<String, dynamic>;
      final List<dynamic>? times = data['times'];

      if (times != null) {
        _availableTimes
          ..clear()
          ..addAll(times.cast<String>());
        notifyListeners();
      }
    });
  }

  // --------------------
  // 🔓 เปิด / ปิดรับคิว
  // --------------------
  bool _isOpenForBooking = true;
  bool get isOpenForBooking => _isOpenForBooking;

  void _listenBookingStatus() {
    _bookingStatusSub = FirebaseFirestore.instance
        .collection('system_settings')
        .doc('booking')
        .snapshots()
        .listen((doc) {
      if (!doc.exists) return;

      final data = doc.data() as Map<String, dynamic>;
      _isOpenForBooking = data['isOpen'] ?? true;
      notifyListeners();
    });
  }

  Future<void> setOpenForBooking(bool open) async {
    await FirebaseFirestore.instance
        .collection('system_settings')
        .doc('booking')
        .set(
      {'isOpen': open},
      SetOptions(merge: true),
    );
  }

  // --------------------
  // ➕ เพิ่มคิว (Transaction)
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
      queueLabel: getQueueLabel(time),
    );
  }

  @override
  void dispose() {
    _bookingStatusSub?.cancel();
    _availableTimesSub?.cancel();
    super.dispose();
  }
}
