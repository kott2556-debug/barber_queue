class QueueManager {
  static final QueueManager _instance = QueueManager._internal();

  factory QueueManager() => _instance;

  QueueManager._internal();

  List<Map<String, String>> bookings = [];
  // เวลาที่ Admin ตั้งเอง
  List<String> availableTimes = [
    "8.00",
    "8.45",
    "9.30",
    "10.15",
    "11.00",
    "13.00",
    "13.45",
    "14.30",
    "15.15",
    "16.00",
  ];
  // ฟังก์ชันให้ Admin ตั้งเวลาเอง (จำกัด 10 ช่อง)
  void setAdminTimes(List<String> newTimes) {
    availableTimes = newTimes.take(10).toList();
  }

  void addBooking(String time) {
    bookings.add({"time": time, "status": "Pending"});
  }
}
