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
    _autoResetAtMidnight(); // 🕛 เพิ่ม: รีเซ็ตอัตโนมัติเมื่อวันเปลี่ยน
    _listenBookingStatus();
    _listenQueueSettings();
  }

  final FirestoreService _firestore = FirestoreService();

  StreamSubscription<DocumentSnapshot>? _bookingStatusSub;
  StreamSubscription<DocumentSnapshot>? _queueSettingsSub;

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
  final List<String> _availableTimes = [];
  List<String> get availableTimes => List.unmodifiable(_availableTimes);

  // --------------------
  // ค่า config ล่าสุด (Admin)
  // --------------------
  int _totalQueues = 10;
  int _minutesPerQueue = 30;

  int get totalQueues => _totalQueues;
  int get minutesPerQueue => _minutesPerQueue;

  // --------------------
  // แปลงเวลา → ป้ายคิว
  // --------------------
  String getQueueLabel(String time) {
    final index = _availableTimes.indexOf(time);
    if (index == -1) return '';
    return 'คิว ${index + 1}';
  }

  // --------------------
  // Admin บันทึกเวลา + config
  // --------------------
  Future<void> saveQueueSettings({
    required List<String> times,
    required int totalQueues,
    required int minutesPerQueue,
  }) async {
    _availableTimes
      ..clear()
      ..addAll(times);

    _totalQueues = totalQueues;
    _minutesPerQueue = minutesPerQueue;

    await FirebaseFirestore.instance
        .collection('system_settings')
        .doc('queue_times')
        .set({
      'times': times,
      'totalQueues': totalQueues,
      'minutesPerQueue': minutesPerQueue,
    });

    notifyListeners();
  }

  // --------------------
  // Sync เวลา + config จาก Firestore
  // --------------------
  void _listenQueueSettings() {
    _queueSettingsSub = FirebaseFirestore.instance
        .collection('system_settings')
        .doc('queue_times')
        .snapshots()
        .listen((doc) {
      if (!doc.exists) return;

      final data = doc.data() as Map<String, dynamic>;

      final List<dynamic>? times = data['times'];
      final int? tq = data['totalQueues'];
      final int? mpq = data['minutesPerQueue'];

      if (times != null) {
        _availableTimes
          ..clear()
          ..addAll(times.cast<String>());
      }

      if (tq != null) _totalQueues = tq;
      if (mpq != null) _minutesPerQueue = mpq;

      notifyListeners();
    });
  }

  // --------------------
  // เปิด / ปิดรับคิว
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
  // 🕛 รีเซ็ตอัตโนมัติเมื่อวันเปลี่ยน (00:00)
  // --------------------
  Future<void> _autoResetAtMidnight() async {
    final now = DateTime.now();
    final today =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final docRef = FirebaseFirestore.instance
        .collection('system_settings')
        .doc('booking');

    final doc = await docRef.get();
    final data = doc.data() ?? {};

    if (data['lastResetDate'] != today) {
      await docRef.set({
        'isOpen': true,
        'lastResetDate': today,
      }, SetOptions(merge: true));
    }
  }

  // --------------------
  // เพิ่มคิว (Transaction)
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
    _queueSettingsSub?.cancel();
    super.dispose();
  }
}
