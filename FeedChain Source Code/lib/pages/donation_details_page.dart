import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class DonationDetailsPage extends StatefulWidget {
  final DocumentSnapshot donation;
  const DonationDetailsPage({super.key, required this.donation});

  @override
  State<DonationDetailsPage> createState() => _DonationDetailsPageState();
}

class _DonationDetailsPageState extends State<DonationDetailsPage> {
  bool _loading = false;

  Future<void> _openDirections(double lat, double lng) async {
    final uri = Uri.parse("https://www.google.com/maps/dir/?api=1&destination=$lat,$lng");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cannot open maps")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.donation.data() as Map<String, dynamic>;
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwner = currentUser != null && currentUser.uid == data['userId'];

    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text("Donation Details", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.blue[700],
        centerTitle: true,
        elevation: 2,
        shadowColor: Colors.blueAccent[100],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Food: ${data['food'] ?? '-'}",
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 13, 71, 161))),
                    const SizedBox(height: 8),
                    Text("Quantity: ${data['quantity'] ?? '-'}", style: const TextStyle(fontSize: 22, color: Colors.black87)),
                    Text("Expiry: ${data['expiry'] ?? '-'}", style: const TextStyle(fontSize: 22, color: Colors.black87)),
                    Text("Donor: ${data['donorName'] ?? '-'}", style: const TextStyle(fontSize: 22, color: Colors.black87)),
                    Text("Phone: ${data['donorPhone'] ?? '-'}", style: const TextStyle(fontSize: 22, color: Colors.black87)),
                    Text("Picked: ${data['picked'] == true ? 'Yes' : 'No'}", style: const TextStyle(fontSize: 22, color: Colors.black87)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _openDirections(
                    (data['lat'] as num).toDouble(), (data['lng'] as num).toDouble()),
                label: const Text("Show Directions", style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 86, 145, 197),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: Colors.blueAccent[100],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (isOwner) ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading
                      ? null
                      : () async {
                          setState(() => _loading = true);
                          await widget.donation.reference.delete();
                          setState(() => _loading = false);
                          Navigator.pop(context);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 207, 96, 95),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    shadowColor: Colors.redAccent[100],
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Cancel Donation", style: TextStyle(color: Colors.white),),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading || (data['picked'] == true)
                      ? null
                      : () async {
                          setState(() => _loading = true);
                          await widget.donation.reference.update({'picked': true});
                          setState(() => _loading = false);
                          Navigator.pop(context);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 94, 190, 99),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    shadowColor: Colors.greenAccent[100],
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Mark as Picked", style: TextStyle(color: Colors.white),),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
