import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class MapScreen extends StatefulWidget {
  final String locationName;
  final String? title;

  const MapScreen({super.key, required this.locationName, this.title});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  LatLng? _location;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _geocodeLocation();
  }

  Future<void> _geocodeLocation() async {
    try {
      List<Location> locations = await locationFromAddress(widget.locationName);
      if (locations.isNotEmpty) {
        setState(() {
          _location = LatLng(locations[0].latitude, locations[0].longitude);
          _isLoading = false;
        });
        // Move camera to location
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_location!, 14.0),
        );
      } else {
        setState(() {
          _error = 'Location not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Unable to find location: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Location Map'),
        actions: [
          if (_location != null)
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: () {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(_location!, 14.0),
                );
              },
              tooltip: 'Center on location',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[600]),
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _error = null;
                      });
                      _geocodeLocation();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _location == null
          ? const Center(
              child: Text(
                'No location available',
                style: TextStyle(color: Colors.white),
              ),
            )
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _location!,
                zoom: 14.0,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('location'),
                  position: _location!,
                  infoWindow: InfoWindow(
                    title: widget.title ?? 'Location',
                    snippet: widget.locationName,
                  ),
                ),
              },
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              mapType: MapType.normal,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
            ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
