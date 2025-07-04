import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

// The MapSelect is a view of the Map which allows controls by the user, therefore allows user to select location on the map.
class MapSelect extends StatefulWidget {
  final LatLng? initialLatLng;

  const MapSelect({super.key, this.initialLatLng});

  @override
  State<MapSelect> createState() => _MapSelectState();
}

class _MapSelectState extends State<MapSelect> {
  LatLng? _selectedPosition;
  String? _locationName;
  late CameraPosition _initialCamera;

  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _setupInitialCamera();
  }

  Future<void> _setupInitialCamera() async {
    // Get the user's location as the start location for the camera
    LatLng center = widget.initialLatLng ?? await _getCurrentLocation();

    setState(() {
      _selectedPosition = center;
      _initialCamera = CameraPosition(target: center, zoom: 15);
    });

    _reverseGeocode(center);
  }


  Future<LatLng> _getCurrentLocation() async {
    // Making sure its allowed to be gathering their location
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    final position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  // Helper function to format the location name
  Future<void> _reverseGeocode(LatLng position) async {
    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final name = [
          if (place.subThoroughfare != null) place.subThoroughfare, // house number
          if (place.thoroughfare != null) place.thoroughfare,       // street name
          if (place.locality != null) place.locality,               // city
        ].where((e) => e != null && e!.isNotEmpty).join(', ');


        setState(() {
          _locationName = name;
        });
      }
    } catch (_) {
      setState(() {
        _locationName = 'Unknown location';
      });
    }
  }

  void _onTap(LatLng position) {
    setState(() {
      _selectedPosition = position;
    });
    _reverseGeocode(position);
  }

  // Verify the selection
  void _confirmSelection() {
    if (_selectedPosition != null && _locationName != null) {
      Navigator.pop(context, {
        'name': _locationName,
        'lat': _selectedPosition!.latitude,
        'lng': _selectedPosition!.longitude,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick a Location')),
      body: _selectedPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: _initialCamera,
              onMapCreated: (controller) => _mapController = controller,
              markers: _selectedPosition != null
                  ? {
                Marker(
                  markerId: const MarkerId('selected'),
                  position: _selectedPosition!,
                )
              }
                  : {},
              onTap: _onTap,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
            ),
          ),
          if (_locationName != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Selected: $_locationName',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton.icon(
              onPressed: _confirmSelection,
              icon: const Icon(Icons.check),
              label: const Text('Confirm Location'),
            ),
          ),
        ],
      ),
    );
  }
}
