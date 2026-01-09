import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==================================================
  // 🔐 USER: จองคิว (Transaction กันจองซ้ำ)
  // ==================================================
  Future<void> addBookingTransaction({
    required String name,
    required String phone,
    required String time,
    required String queueLabel,
  }) async {
    final activeRef = _db.collection('active_bookings').doc(phone);
    final bookingRef = _db.collection('bookings').doc();

    await _db.runTransaction((transaction) async {
      final activeSnap = await transaction.get(activeRef);

      // ❌ มีคิวอยู่แล้ว
      if (activeSnap.exists) {
        throw Exception('USER_ALREADY_HAS_QUEUE');
      }

      // ✅ สร้างคิว
      transaction.set(bookingRef, {
        'name': name,
        'phone': phone,
        'time': time,
        'queueLabel': queueLabel,
        'status': 'waiting',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // ✅ lock เบอร์โทร
      transaction.set(activeRef, {
        'bookingId': bookingRef.id,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // ==================================================
  // 🧑‍💼 ADMIN: เรียกคิว
  // ==================================================
  Future<void> callNextQueue(String docId) async {
    await _db.collection('bookings').doc(docId).update({
      'status': 'serving',
    });
  }

  // ==================================================
  // 🧑‍💼 ADMIN: ปิดคิว + ปลด lock
  // ==================================================
  Future<void> finishQueue(String docId, String phone) async {
    await _db.collection('bookings').doc(docId).update({
      'status': 'done',
    });

    await _db.collection('active_bookings').doc(phone).delete();
  }

  // ==================================================
  // 🔄 ADMIN: realtime ดูคิวทั้งหมด
  // ==================================================
  Stream<QuerySnapshot> streamBookings() {
    return _db
        .collection('bookings')
        .orderBy('createdAt')
        .snapshots();
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
  // 🔥 ADMIN: ล้างคิวทั้งหมด (2 collection)
  // ==================================================
  Future<void> clearAllQueues() async {
    final batch = _db.batch();

    // ลบ bookings
    final bookings = await _db.collection('bookings').get();
    for (final doc in bookings.docs) {
      batch.delete(doc.reference);
    }

    // ลบ active_bookings
    final actives = await _db.collection('active_bookings').get();
    for (final doc in actives.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
