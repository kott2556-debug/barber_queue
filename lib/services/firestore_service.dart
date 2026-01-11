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
      final activeSnap = await transaction.get(activeRef);
      if (activeSnap.exists) {
        throw Exception('USER_ALREADY_HAS_QUEUE');
      }

      final timeSnap = await transaction.get(timeLockRef);
      if (timeSnap.exists) {
        throw Exception('TIME_ALREADY_BOOKED');
      }

      transaction.set(bookingRef, {
        'name': name,
        'phone': phone,
        'time': time,
        'queueLabel': queueLabel,
        'status': 'waiting',
        'createdAt': FieldValue.serverTimestamp(),
      });

      transaction.set(activeRef, {
        'bookingId': bookingRef.id,
        'createdAt': FieldValue.serverTimestamp(),
      });

      transaction.set(timeLockRef, {
        'bookingId': bookingRef.id,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // ==================================================
  // 🔄 realtime ดูคิวทั้งหมด
  // ==================================================
  Stream<QuerySnapshot> streamBookings() {
    return _db.collection('bookings').orderBy('createdAt').snapshots();
  }

  // ==================================================
  // 🧑‍💼 ADMIN: เรียกคิว (UX เดิม / ไม่แตะ lock)
  // ==================================================
  Future<void> callNextQueueByAdmin(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'serving',
    });
  }

  // ==================================================
  // 🧑‍💼 ADMIN: เสร็จแล้ว (UX เดิม)
  // ==================================================
  Future<void> finishQueueByAdmin(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({'status': 'done'});
  }

  // ==================================================
  // 🔐 SYSTEM: ปลด lock (ใช้เฉพาะ flow ที่ต้องการจริง ๆ)
  // ==================================================
  Future<void> releaseLocks({
    required String phone,
    required String time,
  }) async {
    final batch = _db.batch();

    batch.delete(_db.collection('active_bookings').doc(phone));
    batch.delete(_db.collection('time_locks').doc(time));

    await batch.commit();
  }

  // ==================================================
  // 🔄 realtime เวลาที่ถูกจอง (กันเวลาซ้ำ)
  // ==================================================
  Stream<List<String>> streamBookedTimes() {
    return _db
        .collection('bookings')
        .where('status', whereIn: ['waiting', 'serving'])
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => doc['time'] as String).toList(),
        );
  }

  // ==================================================
  // 🔥 ADMIN: ล้างคิวทั้งหมด
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

  // 🔒 realtime เวลาที่ถูก lock (ใช้กับหน้าจองคิว)
  Stream<List<String>> streamLockedTimes() {
    return _db
        .collection('time_locks')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }
}
