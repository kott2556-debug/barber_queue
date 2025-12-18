import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // เพิ่มคิว
  Future<void> addBooking({
    required String name,
    required String phone,
    required String time,
  }) async {
    await _db.collection('bookings').add({
      'name': name,
      'phone': phone,
      'time': time,
      'status': 'waiting',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
