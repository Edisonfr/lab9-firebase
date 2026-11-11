import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../modelos/solicitud.dart';
import '../servicios/solicitudes_servicio.dart';

class PantallaMapa extends StatelessWidget {
  const PantallaMapa({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de atenciones')),
      body: StreamBuilder<List<Solicitud>>(
        stream: SolicitudesServicio().mias(uid),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());

          final marcadores = <Marker>[];
          for (final s in snap.data!) {
            final g = s.ubicacion;
            if (g == null) continue;
            marcadores.add(Marker(
              point: LatLng(g.latitude, g.longitude),
              width: 44,
              height: 44,
              child: Tooltip(
                message: s.titulo,
                child: const Icon(Icons.location_on, color: Colors.red, size: 40),
              ),
            ));
          }

          // Si no hay solicitudes con ubicación, se centra en Bogotá
          final centro = marcadores.isNotEmpty
              ? marcadores.first.point
              : const LatLng(4.7110, -74.0721);

          return FlutterMap(
            options: MapOptions(initialCenter: centro, initialZoom: 14),
            children: [
              TileLayer(
                urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
                userAgentPackageName: 'com.example.soporte_app',
              ),
              MarkerLayer(markers: marcadores),
              const SimpleAttributionWidget(source: Text('Teselas © Esri, HERE, Garmin, OpenStreetMap contributors')),
            ],
          );
        },
      ),
    );
  }
}
