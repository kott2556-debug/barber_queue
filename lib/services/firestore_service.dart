import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==================================================
  // 🔐 TRANSACTION กันจองซ้ำ
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

      if (activeSnap.exists) {
        throw Exception('USER_ALREADY_HAS_QUEUE');
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
    });
  }

  // ===============================
  // 🧑‍💼 Admin: เรียกคิว
  // ===============================
  Future<void> callNextQueue(String docId) async {
    await _db.collection('bookings').doc(docId).update({
      'status': 'serving',
    });
  }

  // ===============================
  // 🧑‍💼 Admin: ปิดคิว
  // ===============================
  Future<void> finishQueue(String docId, String phone) async {
    await _db.collection('bookings').doc(docId).update({
      'status': 'done',
    });

    await _db.collection('active_bookings').doc(phone).delete();
  }

  // ===============================
  // 🔄 realtime (Admin)
  // ===============================
  Stream<QuerySnapshot> streamBookings() {
    return _db
        .collection('bookings')
        .orderBy('createdAt')
        .snapshots();
  }

  // ===============================
  // 🔄 realtime เวลาที่ถูกจอง
  // ===============================
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
}
