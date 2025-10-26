import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class AddDonationPage extends StatefulWidget {
  const AddDonationPage({super.key});

  @override
  State<AddDonationPage> createState() => _AddDonationPageState();
}

class _AddDonationPageState extends State<AddDonationPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _foodController = TextEditingController();
  final _quantityController = TextEditingController();
  final _expiryController = TextEditingController();
  bool _loading = false;

  Future<Position> _getLocation() async {
    LocationPermission permission;
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception("Location services are disabled.");

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permission denied by user.");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permission permanently denied. Enable from settings.");
    }
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final food = _foodController.text.trim();
    final qty = int.tryParse(_quantityController.text.trim()) ?? 0;

    if (name.isEmpty || phone.isEmpty || food.isEmpty || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please enter valid name, phone, food & quantity"),
      ));
      return;
    }

    setState(() => _loading = true);
    try {
      final pos = await _getLocation();
      await FirebaseFirestore.instance.collection('donations').add({
        'userId': user.uid,
        'donor': user.email ?? user.uid,
        'donorName': name,
        'donorPhone': phone,
        'food': food,
        'quantity': qty,
        'expiry': _expiryController.text.trim(),
        'lat': pos.latitude,
        'lng': pos.longitude,
        'timestamp': FieldValue.serverTimestamp(),
        'picked': false,
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Donation posted successfully")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(14),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType ?? TextInputType.text,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.blueGrey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text("Add Donation",
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Colors.white)),
        backgroundColor: Colors.blue[700],
        centerTitle: true,
        elevation: 2,
        shadowColor: Colors.blueAccent[100],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTextField(_nameController, "Your Name"),
            _buildTextField(_phoneController, "Phone Number",
                keyboardType: TextInputType.phone),
            _buildTextField(_foodController, "Food Item"),
            _buildTextField(_quantityController, "Quantity (servings)",
                keyboardType: TextInputType.number),
            _buildTextField(_expiryController, "Expiry (optional)"),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: Colors.blueAccent[100],
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Submit Donation",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
