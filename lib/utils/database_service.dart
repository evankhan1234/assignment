import 'package:cloud_firestore/cloud_firestore.dart';
class DatabaseService {
  final String uid;
  DatabaseService(this.uid);

  final CollectionReference brewCollection = FirebaseFirestore.instance.collection('brew');
  Future updateUserData(String name, String phone) async {
    Future<DocumentSnapshot<Object?>> data = brewCollection.doc(uid).get();
    return await brewCollection.doc(uid).set({
      'name': name,
      'phone': phone
    });
  }
}