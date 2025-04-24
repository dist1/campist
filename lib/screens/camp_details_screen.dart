import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CampDetailsScreen extends StatefulWidget {
  final String campId;

  const CampDetailsScreen({Key? key, required this.campId}) : super(key: key);

  @override
  _CampDetailsScreenState createState() => _CampDetailsScreenState();
}

class _CampDetailsScreenState extends State<CampDetailsScreen> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> _campDetails;

  @override
  void initState() {
    super.initState();
    _campDetails =
        FirebaseFirestore.instance.collection('camps').doc(widget.campId).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Camp Details")),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _campDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData ||
              snapshot.data == null ||
              !snapshot.data!.exists) {
            return const Center(child: Text("Camp not found."));
          }

          final Map<String, dynamic>? camp = snapshot.data!.data();
          if (camp == null) {
            return const Center(child: Text("Invalid camp data."));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  camp['name'] ?? 'No Name',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text("Location: ${camp['location'] ?? 'Unknown'}",
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text("Description:",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Text(camp['description'] ?? 'No Description',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                camp['verified'] == true
                    ? const Text("✅ Verified Camp",
                        style: TextStyle(color: Colors.green, fontSize: 16))
                    : const Text("⏳ Pending Verification",
                        style: TextStyle(color: Colors.red, fontSize: 16)),
              ],
            ),
          );
        },
      ),
    );
  }
}
