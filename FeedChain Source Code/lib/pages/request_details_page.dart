import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class RequestDetailsPage extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;
  const RequestDetailsPage({super.key, required this.docId, required this.data});

  Future<void> _cancelRequest(BuildContext context) async {
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
    final user = FirebaseAuth.instance.currentUser;
    final isOwner = data['userId'] == user?.uid;

    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text("Request Details",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue[700],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            "Need: ${data['need'] ?? '-'}",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 12),
          Text("Quantity: ${data['quantity'] ?? '-'}", style: const TextStyle(fontSize: 16)),
          if (data['urgency'] != null)
            Text("Urgency: ${data['urgency']}", style: const TextStyle(fontSize: 16)),
          if (data['requesterName'] != null)
            Text("Requester: ${data['requesterName']}", style: const TextStyle(fontSize: 16)),
          if (data['requesterPhone'] != null)
            Text("Phone: ${data['requesterPhone']}", style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 24),
          Row(
            children: [
              if (data['lat'] != null && data['lng'] != null)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final uri = Uri.parse(
                          "https://www.google.com/maps/dir/?api=1&destination=${data['lat']},${data['lng']}");
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                    icon: const Icon(Icons.directions, color: Colors.white),
                    label: const Text("Directions", style: TextStyle( color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              if (isOwner) const SizedBox(width: 12),
              if (isOwner)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _cancelRequest(context),
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text("Cancel Request", style: TextStyle( color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
            ],
          ),
        ]),
      ),
    );
  }
}
