import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'camp_details_screen.dart';

class FindCampsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Find Camps")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('camps')
            .where('verified', isEqualTo: true) // Show only verified camps
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No verified camps available."));
          }

          final List<QueryDocumentSnapshot> camps = snapshot.data!.docs;

          return ListView.builder(
            itemCount: camps.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> camp =
                  camps[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(camp['name'] ?? 'No Name',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Location: ${camp['location'] ?? 'Unknown'}"),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CampDetailsScreen(campId: camps[index].id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
