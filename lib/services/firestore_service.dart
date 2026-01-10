import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==================================================
  // 🔐 USER: จองคิว (Transaction กันจองซ้ำเด็ดขาด)
  // ==================================================
  Future<void> addBookingTransaction({
    required String name,
    required String phone,
    required String time,
    required String queueLabel,
  }) async {
    final activeRef = _db.collection('active_bookings').doc(phone);
    final timeLockRef = _db.collection('time_locks').doc(time);
    final bookingRef = _db.collection('bookings').doc();

    await _db.runTransaction((transaction) async {
      // 🔒 เช็คว่ามีคิวอยู่แล้วไหม
      final activeSnap = await transaction.get(activeRef);
      if (activeSnap.exists) {
        throw Exception('USER_ALREADY_HAS_QUEUE');
      }

      // 🔒 เช็คว่าเวลานี้ถูกจองไปแล้วไหม
      final timeSnap = await transaction.get(timeLockRef);
      if (timeSnap.exists) {
        throw Exception('TIME_ALREADY_BOOKED');
      }

      // ✅ สร้าง booking
      transaction.set(bookingRef, {
        'name': name,
        'phone': phone,
        'time': time,
        'queueLabel': queueLabel,
        'status': 'waiting',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 🔒 lock เบอร์โทร
      transaction.set(activeRef, {
        'bookingId': bookingRef.id,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 🔒 lock เวลา
      transaction.set(timeLockRef, {
        'bookingId': bookingRef.id,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // ==================================================
  // 🔄 ADMIN / USER: realtime ดูคิวทั้งหมด
  // ==================================================
  Stream<QuerySnapshot> streamBookings() {
    return _db
        .collection('bookings')
        .orderBy('createdAt')
        .snapshots();
  }

  // ==================================================
  // 🧑‍💼 ADMIN: เรียกคิวถัดไป + ปลด lock
  // ==================================================
  Future<void> callNextQueue({
    required String bookingId,
    required String phone,
    required String time,
  }) async {
    final batch = _db.batch();

    // อัปเดตสถานะคิว
    batch.update(_db.collection('bookings').doc(bookingId), {
      'status': 'called',
    });

    // ปลด lock
    batch.delete(_db.collection('active_bookings').doc(phone));
    batch.delete(_db.collection('time_locks').doc(time));

    await batch.commit();
  }

  // ==================================================
  // 🧑‍💼 ADMIN: ปิดคิว (จบงาน)
  // ==================================================
  Future<void> finishQueue(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'done',
    });
  }

  // ==================================================
  // 🔄 realtime เวลาที่ถูกจอง (กันเวลาซ้ำ)
  // ==================================================
  Stream<List<String>> streamBookedTimes() {
    return _db
        .collection('bookings')
        .where('status', whereIn: ['waiting', 'called'])
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => doc['time'] as String).toList(),
        );
  }

  // ==================================================
  // 🔥 ADMIN: ล้างคิวทั้งหมด (ทุก collection)
  // ==================================================
  Future<void> clearAllQueues() async {
    final batch = _db.batch();

    final bookings = await _db.collection('bookings').get();
    for (final doc in bookings.docs) {
      batch.delete(doc.reference);
    }

    final actives = await _db.collection('active_bookings').get();
    for (final doc in actives.docs) {
      batch.delete(doc.reference);
    }

    final times = await _db.collection('time_locks').get();
    for (final doc in times.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
