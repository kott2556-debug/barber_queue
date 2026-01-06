import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==================================================
  // 🔐 TRANSACTION กันจองซ้ำ (ระดับ Firestore จริง)
  // ==================================================
  Future<void> addBookingTransaction({
    required String name,
    required String phone,
    required String time,
  }) async {
    final activeRef = _db.collection('active_bookings').doc(phone);
    final bookingRef = _db.collection('bookings').doc();

    await _db.runTransaction((transaction) async {
      final activeSnap = await transaction.get(activeRef);

      // ❌ ถ้ามีคิวอยู่แล้ว
      if (activeSnap.exists) {
        throw Exception('USER_ALREADY_HAS_QUEUE');
      }

      // ✅ สร้างคิว
      transaction.set(bookingRef, {
        'name': name,
        'phone': phone,
        'time': time,
        'status': 'waiting',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // ✅ lock เบอร์นี้ไว้
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
  // 🧑‍💼 Admin: ปิดคิว (ปลด lock)
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
}
