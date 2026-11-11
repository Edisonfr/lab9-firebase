import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MapaApp());
}

class MapaApp extends StatelessWidget {
  const MapaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lab 10 - GPS y Mapa',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const PantallaMapa(),
    );
  }
}

class PantallaMapa extends StatefulWidget {
  const PantallaMapa({super.key});

  @override
  State<PantallaMapa> createState() => _PantallaMapaState();
}

class _PantallaMapaState extends State<PantallaMapa> {
  final MapController controladorMapa = MapController();
  Position? miPosicion;
  bool cargando = true;
  String? error;

  // Posición por defecto mientras carga (Bogotá)
  LatLng centroMapa = const LatLng(4.7110, -74.0721);

  @override
  void initState() {
    super.initState();
    obtenerUbicacion();
  }

  Future<void> obtenerUbicacion() async {
    setState(() { cargando = true; error = null; });

    // 1. Verificar que el servicio de ubicación esté activo
    bool servicioActivo = await Geolocator.isLocationServiceEnabled();
    if (!servicioActivo) {
      setState(() { error = 'El servicio de ubicación está desactivado'; cargando = false; });
      return;
    }

    // 2. Verificar y pedir permiso
    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission(); // el navegador muestra el popup aquí
      if (permiso == LocationPermission.denied) {
        setState(() { error = 'Permiso de ubicación denegado'; cargando = false; });
        return;
      }
    }
    if (permiso == LocationPermission.deniedForever) {
      setState(() {
        error = 'Permiso denegado permanentemente. Habilítalo en la configuración del navegador.';
        cargando = false;
      });
      return;
    }

    // 3. Capturar la posición actual
    try {
      final posicion = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        miPosicion = posicion;
        centroMapa = LatLng(posicion.latitude, posicion.longitude);
        cargando = false;
      });

      // Centrar el mapa en la nueva ubicación
      controladorMapa.move(centroMapa, 16);
    } catch (e) {
      setState(() { error = 'No se pudo obtener la ubicación: $e'; cargando = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi ubicación'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: obtenerUbicacion,
            tooltip: 'Actualizar ubicación',
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: controladorMapa,
            options: MapOptions(
              initialCenter: centroMapa,
              initialZoom: 12,
            ),
            children: [
              // Capa de "calles" (tiles de OpenStreetMap, gratis, sin clave)
TileLayer(
  urlTemplate: 'https://maps.wikimedia.org/osm-intl/{z}/{x}/{y}.png',
  userAgentPackageName: 'com.example.lab10_mapa',
),
              // Capa de marcadores
              if (miPosicion != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: centroMapa,
                      width: 60,
                      height: 60,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 45),
                    ),
                  ],
                ),
            ],
          ),
          if (cargando)
            const Center(child: CircularProgressIndicator()),
          if (error != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Card(
                color: Colors.red.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(error!, style: const TextStyle(color: Colors.red)),
                ),
              ),
            ),
          if (miPosicion != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Lat: ${miPosicion!.latitude.toStringAsFixed(5)}, '
                    'Lng: ${miPosicion!.longitude.toStringAsFixed(5)}',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}