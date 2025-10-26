import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostDetailPage extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isDonation;

  const PostDetailPage({super.key, required this.data, required this.isDonation});

  Future<void> _cancelRequest(BuildContext context) async {
    final docId = data['id'];
    final currentUser = FirebaseAuth.instance.currentUser;
    if (docId == null || currentUser == null || currentUser.uid != data['userId']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can only cancel your own request")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('requests').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Request cancelled")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwner = currentUser != null && currentUser.uid == data['userId'];

    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text(isDonation ? "Donation Details" : "Request Details"),
        backgroundColor: Colors.blue[700],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            isDonation ? "Food: ${data['food'] ?? '-'}" : "Need: ${data['need'] ?? '-'}",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
          ),
          const SizedBox(height: 12),
          Text("Quantity: ${data['quantity'] ?? '-'}", style: const TextStyle(fontSize: 16)),
          if (isDonation && (data['expiry'] != null && data['expiry'] != ""))
            Text("Expiry: ${data['expiry']}", style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            "Posted by: ${data['name'] ?? data['donor'] ?? data['requester'] ?? '-'}",
            style: const TextStyle(fontSize: 16),
          ),
          if (data['phone'] != null)
            Text("Phone: ${data['phone']}", style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 20),
          if (!isDonation && isOwner)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _cancelRequest(context),
                icon: const Icon(Icons.cancel),
                label: const Text("Cancel Request"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}
