class QueueManager {
  static final QueueManager _instance = QueueManager._internal();
  factory QueueManager() => _instance;
  QueueManager._internal();

  // =====================
  // SETTINGS
  // =====================
  String currentUserName = '';
  String currentUserPhone = '';
  
  bool isQueueOpen = true;
  int maxQueuePerDay = 10;

  String openTime = "09:00";
  String closeTime = "18:00";

  // =====================
  // AVAILABLE TIMES (แก้ error ตัวแดง)
  // =====================
  List<String> availableTimes = [
    "09:00",
    "10:00",
    "11:00",
    "12:00",
    "13:00",
    "14:00",
    "15:00",
    "16:00",
    "17:00",
    "18:00",
  ];

  // =====================
  // QUEUE DATA
  // =====================
  List<Map<String, dynamic>> bookings = [];

  bool canBook() {
    return isQueueOpen && bookings.length < maxQueuePerDay;
  }

  // =====================
  // ADD BOOKING (รองรับ booking_screen เดิม)
  // =====================
  void addBooking({
    required String name,
    required String phone,
    required String time,
  }) {
    if (!canBook()) return;

    // ให้เหลือแค่คิวล่าสุด
    bookings.clear();

    bookings.add({
      'name': name,
      'phone': phone,
      'time': time,
      'status': 'waiting',
      'timestamp': DateTime.now(),
    });
  }
}
