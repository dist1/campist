import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminVerificationScreen extends StatefulWidget {
  @override
  _AdminVerificationScreenState createState() =>
      _AdminVerificationScreenState();
}

class _AdminVerificationScreenState extends State<AdminVerificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Camp Verification (Admin)")),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('camps')
            .where('verified', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text("No pending camps for verification."));
          }

          final List<QueryDocumentSnapshot<Map<String, dynamic>>> camps =
              snapshot.data!.docs;

          return ListView.builder(
            itemCount: camps.length,
            itemBuilder: (context, index) {
              var camp = camps[index];
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(camp['name'] ?? 'Unnamed Camp',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Location: ${camp['location'] ?? 'Unknown'}"),
                      Text(
                          "Description: ${camp['description'] ?? 'No Description'}"),
                      Text(
                          "Added On: ${camp['createdAt'] != null ? camp['createdAt'].toDate() : 'Unknown'}"),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => _verifyCamp(camp.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () => _deleteCamp(camp.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _verifyCamp(String campId) {
    FirebaseFirestore.instance.collection('camps').doc(campId).update({
      'verified': true,
    });
  }

  void _deleteCamp(String campId) {
    FirebaseFirestore.instance.collection('camps').doc(campId).delete();
  }
}
