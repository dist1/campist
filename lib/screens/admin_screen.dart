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
      setState(() {}); // Refresh UI
    }).catchError((error) {
      print("Error updating camp: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;
    String userEmail = user?.email ?? "Admin";

    return Scaffold(
      appBar: AppBar(
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
          _buildCampSection("pending"), // Pending Requests Tab
          _buildCampSection("rejected"), // Rejected Camps Tab
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                title: Text(campData["name"] ?? "No Name"),
                subtitle: Text(campData["location"] ?? "No Location"),
                trailing: status == "pending"
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
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
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}
