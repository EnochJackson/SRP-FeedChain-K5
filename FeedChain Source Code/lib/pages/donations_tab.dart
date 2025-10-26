import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'donation_details_page.dart';
import 'add_donation_page.dart';

class DonationsTab extends StatefulWidget {
  const DonationsTab({super.key});

  @override
  State<DonationsTab> createState() => _DonationsTabState();
}

class _DonationsTabState extends State<DonationsTab> {
  late GoogleMapController _mapController;
  final LatLng _center = const LatLng(13.0827, 80.2707);

  Set<Marker> _markersFromSnapshot(QuerySnapshot snapshot) {
    final Set<Marker> markers = {};
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['lat'] == null || data['lng'] == null) continue;
      final id = doc.id;

      markers.add(Marker(
        markerId: MarkerId(id),
        position: LatLng((data['lat'] as num).toDouble(), (data['lng'] as num).toDouble()),
        infoWindow: InfoWindow(
          title: data['food'] ?? 'Donation',
          snippet: "Qty: ${data['quantity'] ?? '-'}",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DonationDetailsPage(donation: doc),
              ),
            );
          },
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
            (data['picked'] ?? false) ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed),
      ));
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('donations')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.blue));

            final markers = _markersFromSnapshot(snapshot.data!);

            return GoogleMap(
              initialCameraPosition: CameraPosition(target: _center, zoom: 12),
              markers: markers,
              onMapCreated: (controller) => _mapController = controller,
              myLocationEnabled: true,
            );
          },
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('donations')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();

            final docs = snapshot.data!.docs;
            return DraggableScrollableSheet(
              initialChildSize: 0.15,
              minChildSize: 0.1,
              maxChildSize: 0.5,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
                  ),
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(data['food'] ?? '-', style: const TextStyle(color: Color.fromARGB(255, 13, 71, 161), fontWeight: FontWeight.bold)),
                        subtitle: Text("Qty: ${data['quantity'] ?? '-'}", style: const TextStyle(color: Colors.black87)),
                        trailing: (data['picked'] ?? false)
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : null,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DonationDetailsPage(donation: doc),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            heroTag: "addDonation",
            backgroundColor: Colors.blue[600],
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddDonationPage())),
            child: const Icon(Icons.add, color: Colors.white,),
          ),
        ),
      ],
    );
  }
}
