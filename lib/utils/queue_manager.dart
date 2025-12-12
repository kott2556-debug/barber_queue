class QueueManager {
  static final QueueManager _instance = QueueManager._internal();

  factory QueueManager() => _instance;

  QueueManager._internal();

  List<Map<String, String>> bookings = [];
  // เวลาที่ Admin ตั้งเอง
  List<String> availableTimes = [
    "10:00",
    "11:00",
    "12:00",
    "13:00",
    "14:00",
    "15:00",
    "16:00",
    "17.00",
    "18.00",
    "19.00",
  ];
  // ฟังก์ชันให้ Admin ตั้งเวลาเอง (จำกัด 10 ช่อง)
  void setAdminTimes(List<String> newTimes) {
    availableTimes = newTimes.take(10).toList();
  }

  void addBooking(String time) {
    bookings.add({"time": time, "status": "Pending"});
  }
}
