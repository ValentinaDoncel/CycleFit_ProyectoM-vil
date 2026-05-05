import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cycle_fit/core/services/firebase/firestore_service.dart';
import 'package:cycle_fit/models/app_models.dart';

class SymptomsFirestoreService {
  const SymptomsFirestoreService();

  Future<SymptomRecordData?> getRecordForDay(String uid, DateTime date) async {
    final documentId =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final snapshot =
        await FirestoreService.symptomsCollection(uid).doc(documentId).get();
    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }

    return SymptomRecordData.fromMap(snapshot.data()!);
  }

  Future<List<SymptomRecordData>> getRecentRecords(String uid, {int limit = 10}) async {
    final query = await FirestoreService.symptomsCollection(uid)
        .orderBy('date', descending: true)
        .limit(limit)
        .get();

    return query.docs
        .map((doc) => SymptomRecordData.fromMap(doc.data()))
        .toList();
  }

  Future<void> saveRecord(String uid, SymptomRecordData record) {
    return FirestoreService.symptomsCollection(uid)
        .doc(record.documentId)
        .set(record.toMap(), SetOptions(merge: true));
  }
}
