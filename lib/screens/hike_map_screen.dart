import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../database/database_helper.dart';

class HikeMapScreen extends StatefulWidget {
  const HikeMapScreen({super.key});

  @override
  State<HikeMapScreen> createState() => _HikeMapScreenState();
}

class _HikeMapScreenState extends State<HikeMapScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHikes();
  }

  Future<void> _loadHikes() async {
    setState(() => _isLoading = true);
    final hikes = await _dbHelper.getAllHikes();

    final Set<Marker> markers = {};
    for (var hike in hikes) {
      if (hike.latitude != null && hike.longitude != null) {
        markers.add(
          Marker(
            markerId: MarkerId('hike_${hike.id}'),
            position: LatLng(hike.latitude!, hike.longitude!),
            infoWindow: InfoWindow(title: hike.name, snippet: hike.location),
          ),
        );
      }
    }

    setState(() {
      _markers = markers;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hike Locations Map'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _markers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hikes with location data',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add GPS location when creating hikes',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _markers.first.position,
                zoom: 10,
              ),
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
