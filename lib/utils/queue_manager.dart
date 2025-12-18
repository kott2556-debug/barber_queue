class QueueManager {
  static final QueueManager _instance = QueueManager._internal();
  factory QueueManager() => _instance;
  QueueManager._internal();

  // --------------------
  // ข้อมูลผู้ใช้ปัจจุบัน
  // --------------------
  String? currentUserName;
  String? currentUserPhone;

  void setCurrentUser({required String name, required String phone}) {
    currentUserName = name;
    currentUserPhone = phone;
  }

  // --------------------
  // คิว
  // --------------------
  final List<Map<String, dynamic>> bookings = [];
  List<String> get availableTimes => [
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
  ];

  void addBooking({
    required String name,
    required String phone,
    required String time,
  }) {
    // ถ้าคนเดิมจองซ้ำ → ลบทิ้งแล้วใส่ใหม่ (เหลือ 1 บรรทัด)
    bookings.removeWhere((b) => b['phone'] == phone);

    bookings.add({
      'name': name,
      'phone': phone,
      'time': time,
      'status': 'waiting', // waiting | serving
      'createdAt': DateTime.now(),
    });

    _sortQueue();
  }

  void _sortQueue() {
    bookings.sort((a, b) => a['createdAt'].compareTo(b['createdAt']));
  }

  // --------------------
  // Admin เรียกคิวถัดไป
  // --------------------
  void callNextQueue() {
    if (bookings.isEmpty) return;

    // รีเซ็ตทุกคิวเป็น waiting
    for (var b in bookings) {
      b['status'] = 'waiting';
    }

    // คิวแรก = กำลังให้บริการ
    bookings.first['status'] = 'serving';
  }

  Map<String, dynamic>? get servingQueue {
    try {
      return bookings.firstWhere((b) => b['status'] == 'serving');
    } catch (_) {
      return null;
    }
  }
}
