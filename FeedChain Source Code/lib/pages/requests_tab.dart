import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_request_page.dart';
import 'request_details_page.dart';

class RequestsTab extends StatefulWidget {
  const RequestsTab({super.key});
  @override
  State<RequestsTab> createState() => _RequestsTabState();
}

class _RequestsTabState extends State<RequestsTab> {
  late GoogleMapController _mapController;
  final LatLng _center = const LatLng(13.0827, 80.2707);
  final user = FirebaseAuth.instance.currentUser;

  Set<Marker> _markersFromSnapshot(QuerySnapshot snapshot) {
    final Set<Marker> markers = {};
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['lat'] == null || data['lng'] == null) continue;
      markers.add(Marker(
        markerId: MarkerId(doc.id),
        position: LatLng((data['lat'] as num).toDouble(), (data['lng'] as num).toDouble()),
        infoWindow: InfoWindow(
          title: data['need'] ?? 'Request',
          snippet: "Qty: ${data['quantity'] ?? '-'}",
        ),
      ));
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('requests').snapshots(),
      builder: (context, snapshot) {
        final markers = snapshot.hasData ? _markersFromSnapshot(snapshot.data!) : <Marker>{};

        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(target: _center, zoom: 12),
              markers: markers,
              onMapCreated: (c) => _mapController = c,
              myLocationEnabled: true,
            ),
            if (snapshot.hasData)
              DraggableScrollableSheet(
                initialChildSize: 0.15,
                minChildSize: 0.1,
                maxChildSize: 0.45,
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
                    ),
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final doc = snapshot.data!.docs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            title: Text(
                              data['need'] ?? '-',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                            ),
                            subtitle: Text("Qty: ${data['quantity'] ?? '-'}"),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blueGrey),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RequestDetailsPage(docId: doc.id, data: data),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                heroTag: "addRequest",
                backgroundColor: Colors.blue[700],
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddRequestPage())),
                child: const Icon(Icons.add, color: Colors.white,),
              ),
            ),
          ],
        );
      },
    );
  }
}
