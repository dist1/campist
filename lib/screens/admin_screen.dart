import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  void _updateCampStatus(String campId, String status) async {
    await FirebaseFirestore.instance
        .collection('camps')
        .doc(campId)
        .update({'status': status}).then((_) {
      setState(() {});
    }).catchError((error) {
      print("Error updating camp: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;
    String userEmail = user?.email ?? "Admin";

    return Scaffold(
      backgroundColor: Color(0xFFF2F5F9), // Light pastel background
      appBar: AppBar(
        backgroundColor: Color(0xFFD5C9C0), // Soft blue app bar
        automaticallyImplyLeading: false,
        title: const Text("Admin Panel"),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.account_circle, size: 30),
            itemBuilder: (context) => [
              PopupMenuItem(child: Text(userEmail), enabled: false),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text("Logout"),
                  onTap: _logout,
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Pending Requests"),
            Tab(text: "Rejected Camps"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCampSection("pending"),
          _buildCampSection("rejected"),
        ],
      ),
    );
  }

  Widget _buildCampSection(String status) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('camps')
          .where('status', isEqualTo: status)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No camps in this section."));
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var camp = snapshot.data!.docs[index];
            Map<String, dynamic> campData = camp.data() as Map<String, dynamic>;

            return Card(
              margin: EdgeInsets.all(10),
              elevation: 3,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(campData["name"] ?? "No Name",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text(campData["location"] ?? "No Location"),
                    SizedBox(height: 5),
                    Text(campData["description"] ?? "No Description"),
                    SizedBox(height: 8),
                    Text("Posted by: ${campData["holder"]}", style: TextStyle(color: Colors.grey[600])),
                    if (status == "pending")
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.check, color: Colors.green),
                            onPressed: () =>
                                _updateCampStatus(camp.id, "approved"),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.red),
                            onPressed: () =>
                                _updateCampStatus(camp.id, "rejected"),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}