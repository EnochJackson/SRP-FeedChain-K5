import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class AddRequestPage extends StatefulWidget {
  const AddRequestPage({super.key});

  @override
  State<AddRequestPage> createState() => _AddRequestPageState();
}

class _AddRequestPageState extends State<AddRequestPage> {
  final _needController = TextEditingController();
  final _quantityController = TextEditingController();
  final _urgencyController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _loading = false;

  Future<Position> _getLocation() async {
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final need = _needController.text.trim();
    final qty = int.tryParse(_quantityController.text.trim()) ?? 0;
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (need.isEmpty || qty <= 0 || name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid need, quantity, name and phone")),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final pos = await _getLocation();
      await FirebaseFirestore.instance.collection('requests').add({
        'userId': user.uid,
        'requester': name,
        'phone': phone,
        'need': need,
        'quantity': qty,
        'urgency': _urgencyController.text.trim(),
        'lat': pos.latitude,
        'lng': pos.longitude,
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Request posted successfully")),
      );
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
        title: const Text("Add Request",
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
            _buildTextField(_needController, "Need (e.g., Meals)"),
            _buildTextField(_quantityController, "Quantity (people)",
                keyboardType: TextInputType.number),
            _buildTextField(_urgencyController, "Urgency (Low/Medium/High)"),
            _buildTextField(_nameController, "Requester Name"),
            _buildTextField(_phoneController, "Phone Number",
                keyboardType: TextInputType.phone),
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
                        "Submit Request",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold, color:  Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
