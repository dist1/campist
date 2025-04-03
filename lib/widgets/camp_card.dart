import 'package:flutter/material.dart';

class CampCard extends StatelessWidget {
  final String title;
  final String location;
  final String image;

  CampCard({required this.title, required this.location, required this.image});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: ListTile(
        leading: Image.asset(image, width: 50, height: 50),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(location),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Navigate to Details Screen (To be implemented later)
        },
      ),
    );
  }
}
