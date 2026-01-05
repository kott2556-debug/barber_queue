import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

    // =========================
  // 👤 ลูกค้า : เช็คว่ามีคิวค้างอยู่ไหม
  // =========================
  Future<bool> hasActiveBooking(String phone) async {
    final snapshot = await _db
        .collection('bookings')
        .where('phone', isEqualTo: phone)
        .where('status', whereIn: ['waiting', 'serving'])
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }


  // =========================
  // 👤 ลูกค้า : เพิ่มคิว
  // =========================
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

  // =========================
  // 🔄 Admin / ลูกค้า : ดูคิว realtime
  // =========================
  Stream<QuerySnapshot<Map<String, dynamic>>> streamBookings() {
    return _db
        .collection('bookings')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  // =========================
  // 🧑‍💼 Admin : เรียกคิวถัดไป
  // =========================
  Future<void> callNextQueue(String docId) async {
    await _db.collection('bookings').doc(docId).update({
      'status': 'serving',
    });
  }

  // =========================
  // 🧑‍💼 Admin : ปิดคิว
  // =========================
  Future<void> finishQueue(String docId) async {
    await _db.collection('bookings').doc(docId).update({
      'status': 'done',
    });
  }

  // =========================
  // 🧑‍💼 Admin : ล้างคิวทั้งหมด
  // =========================
  Future<void> clearAllQueues() async {
    final snapshot = await _db.collection('bookings').get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
