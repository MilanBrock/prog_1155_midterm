import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// A view-only version of the Google Map. Used on the task details screen to visually show the location of the task
class MapView extends StatelessWidget {
  // Latitude and longitude from the task are used to show the location
  final double latitude;
  final double longitude;

  const MapView({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    final LatLng position = LatLng(latitude, longitude);

    return SizedBox(
      height: 200,
      child: GoogleMap(
        // Set the camera
        initialCameraPosition: CameraPosition(
          target: position,
          zoom: 15,
        ),
        markers: {
          Marker(markerId: const MarkerId('task-marker'), position: position),
        },
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        onMapCreated: (GoogleMapController controller) {},
      ),
    );
  }
}
