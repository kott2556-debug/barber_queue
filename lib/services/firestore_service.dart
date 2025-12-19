import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --------------------
  // เพิ่มคิว (ลูกค้าจอง)
  // --------------------
  Future<void> addBooking({
    required String name,
    required String phone,
    required String time,
  }) async {
    await _db.collection('bookings').add({
      'name': name,
      'phone': phone,
      'time': time,
      'status': 'waiting', // waiting | serving | done
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // --------------------
  // 🔄 ดึงคิวแบบ realtime
  // --------------------
  Stream<QuerySnapshot> streamBookings() {
    return _db
        .collection('bookings')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  // --------------------
  // Admin: เรียกคิวถัดไป
  // --------------------
  Future<void> callNextQueue(String docId) async {
    await _db.collection('bookings').doc(docId).update({
      'status': 'serving',
    });
  }

  // --------------------
  // Admin: ปิดคิว
  // --------------------
  Future<void> finishQueue(String docId) async {
    await _db.collection('bookings').doc(docId).update({
      'status': 'done',
    });
  }

  // --------------------
  // Admin: ล้างคิวทั้งหมด
  // --------------------
  Future<void> clearAllQueues() async {
    final snapshot = await _db.collection('bookings').get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
