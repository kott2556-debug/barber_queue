class QueueTimeCalculator {
  static List<String> generateWithLunchAnchor({
    required int totalQueues,
    required int minutesPerQueue,
  }) {
    assert(minutesPerQueue >= 20 && minutesPerQueue <= 60);
    assert(totalQueues >= 10 && totalQueues <= 20);

    final List<String> result = [];

    // ------------------
    // Anchor points
    // ------------------
    final lunchStart = DateTime(0, 1, 1, 12, 0); // เริ่มพัก
    final afternoonStart = DateTime(0, 1, 1, 13, 0); // เริ่มงานบ่ายจริง

    // ------------------
    // แบ่งคิว (เช้าไม่เกิน 5 คิว)
    // ------------------
    final int morningQueues = totalQueues >= 5 ? 5 : totalQueues;
    final int afternoonQueues = totalQueues - morningQueues;

    // ------------------
    // เช้า (ถอยหลังจาก 12:00)
    // ------------------
    DateTime currentMorning = lunchStart.subtract(
      Duration(minutes: minutesPerQueue * morningQueues),
    );

    for (int i = 0; i < morningQueues; i++) {
      result.add(_fmt(currentMorning));
      currentMorning =
          currentMorning.add(Duration(minutes: minutesPerQueue));
    }

    // ------------------
    // บ่าย (เริ่มที่ 13:00 ตรง)
    // ------------------
    DateTime currentAfternoon = afternoonStart;

    for (int i = 0; i < afternoonQueues; i++) {
      result.add(_fmt(currentAfternoon));
      currentAfternoon =
          currentAfternoon.add(Duration(minutes: minutesPerQueue));
    }

    return result;
  }

  static String _fmt(DateTime t) {
    return '${t.hour.toString().padLeft(2, '0')}:'
           '${t.minute.toString().padLeft(2, '0')}';
  }
}
