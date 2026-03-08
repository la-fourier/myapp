import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:myapp/models/map_location.dart';
import 'package:myapp/models/map_route.dart';
import 'package:myapp/services/map_service.dart';
import 'package:provider/provider.dart';
import 'package:myapp/l10n/app_localizations.dart';

class MapSidePanel extends StatelessWidget {
  final MapController mapController;

  const MapSidePanel({super.key, required this.mapController});

  @override
  Widget build(BuildContext context) {
    final mapService = context.watch<MapService>();
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          left: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: loc?.overview ?? 'Overview'),
              Tab(text: loc?.collections ?? 'Collections'),
              Tab(text: loc?.tours ?? 'Tours'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildLocationsList(context, mapService, loc),
                _buildCollectionsList(context, mapService, loc),
                _buildToursList(context, mapService, loc),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationsList(BuildContext context, MapService mapService, AppLocalizations? loc) {
    return ListView.builder(
      itemCount: mapService.locations.length,
      itemBuilder: (context, index) {
        final location = mapService.locations[index];
        return ListTile(
          leading: _getMarkerIcon(location.type),
          title: Text(location.name),
          subtitle: Text(location.description ?? ''),
          onTap: () {
            mapController.move(location.position, 15.0);
          },
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: () => mapService.removeLocation(location.id),
          ),
        );
      },
    );
  }

  Widget _buildCollectionsList(BuildContext context, MapService mapService, AppLocalizations? loc) {
    return const Center(child: Text('Collections coming soon...'));
  }

  Widget _buildToursList(BuildContext context, MapService mapService, AppLocalizations? loc) {
    return ListView.builder(
      itemCount: mapService.routes.length,
      itemBuilder: (context, index) {
        final route = mapService.routes[index];
        return ListTile(
          leading: Icon(_getTransportIcon(route.transportMode), color: route.color),
          title: Text(route.name),
          subtitle: Text('${loc?.transportMode ?? 'Mode'}: ${route.transportMode.name}'),
          trailing: Switch(
            value: route.isVisible,
            onChanged: (_) => mapService.toggleRouteVisibility(route.id),
          ),
          onTap: () {
            if (route.points.isNotEmpty) {
              mapController.move(route.points.first, 13.0);
            }
          },
        );
      },
    );
  }

  IconData _getTransportIcon(TransportMode mode) {
    switch (mode) {
      case TransportMode.walking: return Icons.directions_walk;
      case TransportMode.cycling: return Icons.directions_bike;
      case TransportMode.driving: return Icons.directions_car;
    }
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
    return Icon(iconData, color: color, size: 20);
  }
}
