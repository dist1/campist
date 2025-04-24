import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // ✅ Detect Web

const String cloudinaryUploadPreset = 'campist';
const String cloudinaryCloudName = 'dxmfceyvs';


class AddCampScreen extends StatefulWidget {
  @override
  _AddCampScreenState createState() => _AddCampScreenState();
}

class _AddCampScreenState extends State<AddCampScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  File? _imageFile;
  Uint8List? _webImage; // ✅ Used for Flutter Web

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        // ✅ Web: Use bytes
        var imageBytes = await pickedFile.readAsBytes();
        setState(() => _webImage = imageBytes);
      } else {
        // ✅ Mobile: Use File
        setState(() => _imageFile = File(pickedFile.path));
      }
    }
  }

Future<String?> _uploadImage() async {
  if (_imageFile == null && _webImage == null) return null;

  try {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload');

    var request = http.MultipartRequest('POST', uri);
    request.fields['upload_preset'] = cloudinaryUploadPreset;

    if (kIsWeb) {
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        _webImage!,
        filename: '$fileName.jpg',
      ));
    } else {
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        _imageFile!.path,
        filename: '$fileName.jpg',
      ));
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      final resStr = await response.stream.bytesToString();
      final jsonRes = json.decode(resStr);
      return jsonRes['secure_url'];
    } else {
      print('Cloudinary upload failed: ${response.statusCode}');
      throw Exception('Cloudinary upload failed');
    }
  } catch (e) {
    print("Cloudinary Upload Error: $e");
    throw Exception("Image upload failed. Please try again.");
  }
}

  Future<void> _submitCamp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

try {
  String? imageUrl = await _uploadImage();

  await FirebaseFirestore.instance.collection('camps').add({
    'name': _nameController.text.trim(),
    'location': _locationController.text.trim(),
    'description': _descriptionController.text.trim(),
    'imageUrl': imageUrl ?? "",
    'verified': false,
    'status': 'pending', // ✅ Added
    "holder": FirebaseAuth.instance.currentUser?.email,
    'submittedBy': FirebaseAuth.instance.currentUser!.email,
    'createdAt': Timestamp.now(),
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Camp submitted for verification!"), backgroundColor: Colors.green),
  );

  Navigator.pop(context);
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Submission failed: $e"), backgroundColor: Colors.red),
  );
}

    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F9), // Professional soft beige
      appBar: AppBar(
        title: const Text("Add New Camp"),
        backgroundColor: Color(0xFFD5C9C0), // Complementing color
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade400,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            constraints: BoxConstraints(maxWidth: 500), // Centers on wide screens
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Camp Name",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Enter a camp name" : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: "Location",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Enter a location" : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: "Description",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Enter a description" : null,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: _webImage != null
                        ? Image.memory(_webImage!, height: 120, fit: BoxFit.cover)
                        : _imageFile != null
                            ? Image.file(_imageFile!, height: 120, fit: BoxFit.cover)
                            : const Text("No image selected",
                                style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text("Pick an Image (Optional)"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown.shade300,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitCamp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text("Submit for Verification"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}