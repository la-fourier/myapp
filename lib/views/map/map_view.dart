import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/models/map_location.dart';
import 'package:myapp/services/map_service.dart';
import 'package:provider/provider.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    // Load sample data on start for demonstration
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapService>().loadSampleData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final mapService = context.watch<MapService>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(loc?.mapTitle ?? 'Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => mapService.loadSampleData(),
            tooltip: 'Reload Data',
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              // Center on a default location (e.g., Berlin for now)
              _mapController.move(const LatLng(52.5200, 13.4050), 13.0);
            },
            tooltip: 'Center Map',
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: const LatLng(52.5200, 13.4050), // Berlin
          initialZoom: 13.0,
          onLongPress: (tapPosition, point) {
            _addNewLocation(tapPosition, point);
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.crealcraft.myapp',
            tileProvider: CancellableNetworkTileProvider(),
          ),
          PolylineLayer(
            polylines: mapService.routes
                .where((r) => r.isVisible)
                .map((r) => Polyline(
                      points: r.points,
                      color: r.color,
                      strokeWidth: r.strokeWidth,
                      isFilled: false,
                    ))
                .toList(),
          ),
          MarkerLayer(
            markers: mapService.locations.map((loc) {
              return Marker(
                point: loc.position,
                width: 80,
                height: 80,
                child: GestureDetector(
                  onTap: () {
                    _showLocationDetails(context, loc);
                  },
                  child: Column(
                    children: [
                      _getMarkerIcon(loc.type),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 2),
                          ],
                        ),
                        child: Text(
                          loc.name,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          RichAttributionWidget(
            attributions: [
              TextSourceAttribution(
                'OpenStreetMap contributors',
                onTap: () => {}, // In a real app, launch the OSM URL
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getMarkerIcon(MapLocationType type) {
    IconData iconData;
    Color color;

    switch (type) {
      case MapLocationType.restaurant:
        iconData = Icons.restaurant;
        color = Colors.orange;
        break;
      case MapLocationType.sight:
        iconData = Icons.camera_alt;
        color = Colors.blue;
        break;
      case MapLocationType.hotel:
        iconData = Icons.hotel;
        color = Colors.green;
        break;
      default:
        iconData = Icons.location_on;
        color = Colors.red;
    }

    return Icon(iconData, color: color, size: 30);
  }

  void _addNewLocation(TapPosition tapPosition, LatLng point) {
    String? newName;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Neuen Ort hinzufügen'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Name des Ortes'),
            onChanged: (value) => newName = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newName != null && newName!.isNotEmpty) {
                  context.read<MapService>().addLocation(MapLocation(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: newName!,
                        position: point,
                        type: MapLocationType.place,
                      ));
                  Navigator.pop(context);
                }
              },
              child: const Text('Speichern'),
            ),
          ],
        );
      },
    );
  }

  void _showLocationDetails(BuildContext context, MapLocation location) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                location.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                location.description ?? 'Keine Beschreibung verfügbar.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Schließen'),
              ),
            ],
          ),
        );
      },
    );
  }
}
