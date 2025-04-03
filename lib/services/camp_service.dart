import 'package:cloud_firestore/cloud_firestore.dart';

class CampService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = "camps";

  // Add a new camp
  Future<void> addCamp(Map<String, dynamic> campData) async {
    try {
      await _firestore.collection(_collectionPath).add({
        ...campData,
        "verified": false, // Camps need admin verification
        "createdAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error adding camp: $e");
      throw e;
    }
  }

  // Get a list of verified camps
  Future<List<Map<String, dynamic>>> getCamps() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collectionPath)
          .where("verified", isEqualTo: true) // Only get verified camps
          .orderBy("createdAt", descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {"id": doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print("Error fetching camps: $e");
      throw e;
    }
  }

  // Get all camps (for admin verification)
  Future<List<Map<String, dynamic>>> getAllCamps() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collectionPath)
          .orderBy("createdAt", descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {"id": doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print("Error fetching all camps: $e");
      throw e;
    }
  }

  // Verify a camp (Admin Feature)
  Future<void> verifyCamp(String campId) async {
    try {
      await _firestore
          .collection(_collectionPath)
          .doc(campId)
          .update({"verified": true});
    } catch (e) {
      print("Error verifying camp: $e");
      throw e;
    }
  }

  // Delete a camp
  Future<void> deleteCamp(String campId) async {
    try {
      await _firestore.collection(_collectionPath).doc(campId).delete();
    } catch (e) {
      print("Error deleting camp: $e");
      throw e;
    }
  }
}
