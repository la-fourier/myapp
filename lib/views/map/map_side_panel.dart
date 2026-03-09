import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:myapp/models/map_location.dart';
import 'package:myapp/models/map_route.dart';
import 'package:myapp/services/map_service.dart';
import 'package:provider/provider.dart';
import 'package:myapp/l10n/app_localizations.dart';

class MapSidePanel extends StatefulWidget {
  final MapController mapController;

  const MapSidePanel({super.key, required this.mapController});

  @override
  State<MapSidePanel> createState() => _MapSidePanelState();
}

class _MapSidePanelState extends State<MapSidePanel> {
  String? _selectedRouteId;

  @override
  Widget build(BuildContext context) {
    final mapService = context.watch<MapService>();
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      width: 320,
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
              Tab(text: loc?.overview ?? 'Items'),
              Tab(text: loc?.tours ?? 'Routes'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildLocationsList(context, mapService, loc),
                _selectedRouteId == null 
                  ? _buildToursList(context, mapService, loc)
                  : _buildRouteDetails(context, mapService, loc, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteDetails(BuildContext context, MapService mapService, AppLocalizations? loc, ThemeData theme) {
    final route = mapService.routes.firstWhere((r) => r.id == _selectedRouteId);
    
    return Column(
      children: [
        AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => _selectedRouteId = null),
          ),
          title: Text(route.name, style: theme.textTheme.titleMedium),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Transport Mode
              Text('Transportmittel', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<TransportMode>(
                segments: const [
                  ButtonSegment(value: TransportMode.walking, icon: Icon(Icons.directions_walk)),
                  ButtonSegment(value: TransportMode.cycling, icon: Icon(Icons.directions_bike)),
                  ButtonSegment(value: TransportMode.driving, icon: Icon(Icons.directions_car)),
                ],
                selected: {route.transportMode},
                onSelectionChanged: (val) {
                  mapService.updateRouteTransportMode(route.id, val.first);
                },
              ),
              const SizedBox(height: 24),

              // Summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailItem(theme, 'Zeit', '${route.duration?.inMinutes ?? 0} min', Icons.timer),
                  _buildDetailItem(theme, 'Distanz', '${route.points.length * 1.5} km', Icons.straighten),
                ],
              ),
              const SizedBox(height: 24),

              // Instructions
              Text('Anweisungen', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              ...route.instructions.map((instr) => ListTile(
                dense: true,
                leading: const Icon(Icons.turn_right, size: 16),
                title: Text(instr),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(ThemeData theme, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.titleMedium),
        Text(label, style: theme.textTheme.bodySmall),
      ],
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
            widget.mapController.move(location.position, 15.0);
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
          subtitle: Text('${route.duration?.inMinutes ?? 0} min • ${route.transportMode.name}'),
          trailing: Switch(
            value: route.isVisible,
            onChanged: (_) => mapService.toggleRouteVisibility(route.id),
          ),
          onTap: () {
            setState(() => _selectedRouteId = route.id);
            if (route.points.isNotEmpty) {
              widget.mapController.move(route.points.first, 13.0);
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
