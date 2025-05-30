import 'package:geolocator/geolocator.dart';

import '../model/geo.dart';

class GeoService {
  Future<bool> handlePermission() async {
    final isServiceAvailable = await Geolocator.isLocationServiceEnabled();
    if (!isServiceAvailable) throw Exception('Location is not available.');

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission denied forever.');
    }

    return true;
  }

  Future<Geo> getLocation() async {
    return Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).then((position) {
      return Geo(latitude: position.latitude, longitude: position.longitude);
    });
  }

  // TODO: 1. Complete the getLocationStream() method implementation.
  Stream<Geo> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).map((position) {
      return Geo(latitude: position.latitude, longitude: position.longitude);
    });
  }
}
