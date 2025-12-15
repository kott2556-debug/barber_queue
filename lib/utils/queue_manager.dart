class QueueManager {
  static final QueueManager _instance = QueueManager._internal();

  factory QueueManager() => _instance;

  QueueManager._internal();

  List<Map<String, String>> bookings = [];
  // เวลาที่ Admin ตั้งเอง
  List<String> availableTimes = [
    "คิวที่ 1   เวลา  8.00",
    "คิวที่ 2   เวลา  8.45",
    "คิวที่ 3   เวลา  9.30",
    "คิวที่ 4   เวลา  10.15",
    "คิวที่ 5   เวลา  11.00",
    "คิวที่ 6   เวลา  13.00",
    "คิวที่ 7   เวลา  13.45",
    "คิวที่ 8   เวลา  14.30",
    "คิวที่ 8   เวลา  15.15",
    "คิวที่ 10   เวลา 16.00",
  ];
  // ฟังก์ชันให้ Admin ตั้งเวลาเอง (จำกัด 10 ช่อง)
  void setAdminTimes(List<String> newTimes) {
    availableTimes = newTimes.take(10).toList();
  }

  void addBooking(String time) {
    bookings.add({"time": time, "status": "Pending"});
  }
}
