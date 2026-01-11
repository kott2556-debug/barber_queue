import 'dart:async';
import '../services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QueueManager extends ChangeNotifier {
  // --------------------
  // Singleton
  // --------------------
  static final QueueManager _instance = QueueManager._internal();
  factory QueueManager() => _instance;
  QueueManager._internal() {
    _initDefaultTimes();
    _listenBookingStatus(); // 🔥 ฟังสถานะเปิด/ปิดจาก Firestore
  }

  final FirestoreService _firestore = FirestoreService();
  StreamSubscription<DocumentSnapshot>? _bookingStatusSub;

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
        '07:00', '08:00', '09:00', '10:00', '11:00',
        '13:00', '14:00', '15:00', '16:00', '17:00',
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
  // 🔓 เปิด / ปิดรับคิว (Firestore จริง)
  // --------------------
  bool _isOpenForBooking = true;
  bool get isOpenForBooking => _isOpenForBooking;

  void _listenBookingStatus() {
    _bookingStatusSub = FirebaseFirestore.instance
        .collection('system_settings')
        .doc('booking')
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _isOpenForBooking = data['isOpen'] ?? true;
        notifyListeners();
      }
    });
  }

  /// Admin ใช้สั่งเปิด / ปิดรับคิว
  Future<void> setOpenForBooking(bool open) async {
    await FirebaseFirestore.instance
        .collection('system_settings')
        .doc('booking')
        .set({'isOpen': open}, SetOptions(merge: true));
  }

  // --------------------
  // เพิ่มคิวแบบ transaction ป้องกันซ้ำ
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
      queueLabel: 'คิว ${_availableTimes.indexOf(time) + 1}',
    );
  }

  // --------------------
  // ล้างคิว (Admin)
  // --------------------
  void clearQueue() {
    notifyListeners();
  }

  @override
  void dispose() {
    _bookingStatusSub?.cancel();
    super.dispose();
  }
}
