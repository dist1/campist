import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // ✅ Detect Web

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
    try {
      if (_imageFile == null && _webImage == null) return null;

      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref =
          FirebaseStorage.instance.ref().child('camp_images/$fileName');

      UploadTask uploadTask;
      if (kIsWeb) {
        // ✅ Web: Upload as Uint8List
        uploadTask = ref.putData(_webImage!);
      } else {
        // ✅ Mobile: Upload as File
        uploadTask = ref.putFile(_imageFile!);
      }

      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      return null;
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
        'imageUrl': imageUrl ?? "", // Store empty string if no image
        'verified': false,
        'submittedBy': FirebaseAuth.instance.currentUser!.email,
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Camp submitted for verification!"),
            backgroundColor: Colors.green),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }

    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Camp")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Camp Name"),
                validator: (value) =>
                    value!.isEmpty ? "Enter a camp name" : null,
              ),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: "Location"),
                validator: (value) =>
                    value!.isEmpty ? "Enter a location" : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                validator: (value) =>
                    value!.isEmpty ? "Enter a description" : null,
              ),
              const SizedBox(height: 10),

              /// ✅ **Fixed Image Preview**
              _webImage != null
                  ? Image.memory(_webImage!, height: 100, fit: BoxFit.cover)
                  : _imageFile != null
                      ? Image.file(_imageFile!, height: 100, fit: BoxFit.cover)
                      : const Text("No image selected"),

              ElevatedButton(
                onPressed: _pickImage,
                child: const Text("Pick an Image (Optional)"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitCamp,
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text("Submit for Verification"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
