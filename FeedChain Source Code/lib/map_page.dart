import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(13.0827, 80.2707); // Chennai default
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _loadRequests(); // load Firestore data on init
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _loadRequests() async {
    final snapshot = await FirebaseFirestore.instance.collection('requests').get();

    setState(() {
      _markers.clear();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        _markers.add(
          Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(data['lat'], data['lng']),
            infoWindow: InfoWindow(
              title: data['needType'],
              snippet: "Qty: ${data['quantity']} | Urgency: ${data['urgency']}",
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (_) => Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Need: ${data['needType']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text("Quantity: ${data['quantity']}"),
                        Text("Urgency: ${data['urgency']}"),
                        ElevatedButton(
                          onPressed: () {
                            // implement contact/request action here
                          },
                          child: const Text("Contact Requester"),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Requests Map")),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(target: _center, zoom: 12),
        markers: _markers,
      ),
    );
  }
}
