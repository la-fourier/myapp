import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:myapp/models/map_location.dart';
import 'package:myapp/models/map_route.dart';

class MapService with ChangeNotifier {
  final List<MapLocation> _locations = [];
  final List<MapRoute> _routes = [];

  List<MapLocation> get locations => List.unmodifiable(_locations);
  List<MapRoute> get routes => List.unmodifiable(_routes);

  void addLocation(MapLocation location) {
    _locations.add(location);
    notifyListeners();
  }

  void removeLocation(String id) {
    _locations.removeWhere((loc) => loc.id == id);
    notifyListeners();
  }

  void addRoute(MapRoute route) {
    _routes.add(route);
    notifyListeners();
  }

  void removeRoute(String id) {
    _routes.removeWhere((route) => route.id == id);
    notifyListeners();
  }

  void clearAll() {
    _locations.clear();
    _routes.clear();
    notifyListeners();
  }

  // Helper to add some sample data for demonstration
  void loadSampleData() {
    clearAll();
    
    addLocation(const MapLocation(
      id: '1',
      name: 'Brandenburger Tor',
      description: 'Historisches Wahrzeichen in Berlin',
      position: LatLng(52.5163, 13.3777),
      type: MapLocationType.sight,
    ));

    addLocation(const MapLocation(
      id: '2',
      name: 'Fernsehturm',
      description: 'Aussichtsturm am Alexanderplatz',
      position: LatLng(52.5208, 13.4094),
      type: MapLocationType.sight,
    ));

    addRoute(const MapRoute(
      id: 'r1',
      name: 'Tourist Walk',
      points: [
        LatLng(52.5163, 13.3777), // Brandenburger Tor
        LatLng(52.5186, 13.3761), // Reichstag
        LatLng(52.5208, 13.4094), // Fernsehturm
      ],
    ));
  }
}
