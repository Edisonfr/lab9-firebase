import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../modelos/solicitud.dart';
import '../servicios/solicitudes_servicio.dart';

class PantallaNueva extends StatefulWidget {
  const PantallaNueva({super.key});

  @override
  State<PantallaNueva> createState() => _PantallaNuevaState();
}

class _PantallaNuevaState extends State<PantallaNueva> {
  final _formKey = GlobalKey<FormState>();
  final _titulo = TextEditingController();
  final _descripcion = TextEditingController();
  Prioridad _prioridad = Prioridad.media;
  bool _guardando = false;

  @override
  void dispose() {
    _titulo.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  /// Flujo de permisos de ubicación (dominio F). Devuelve null si no se pudo obtener.
  Future<GeoPoint?> _ubicacion() async {
    if (!await Geolocator.isLocationServiceEnabled()) return null;
    var permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }
    if (permiso == LocationPermission.denied ||
        permiso == LocationPermission.deniedForever) {
      return null;
    }
    final p = await Geolocator.getCurrentPosition();
    return GeoPoint(p.latitude, p.longitude);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    GeoPoint? punto;
    try {
      punto = await _ubicacion();
    } catch (_) {
      punto = null;
    }

    final solicitud = Solicitud(
      id: '',
      titulo: _titulo.text.trim(),
      descripcion: _descripcion.text.trim(),
      prioridad: _prioridad,
      estado: Estado.pendiente,
      creadoPor: FirebaseAuth.instance.currentUser!.uid,
      ubicacion: punto,
    );
    await SolicitudesServicio().crear(solicitud);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(punto == null
          ? 'Guardada sin ubicación (permiso denegado o desactivado)'
          : 'Solicitud guardada con ubicación'),
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva solicitud')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titulo,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Escribe un título' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descripcion,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Escribe una descripción' : null,
            ),
            const SizedBox(height: 16),
            const Text('Prioridad'),
            const SizedBox(height: 8),
            SegmentedButton<Prioridad>(
              segments: Prioridad.values
                  .map((p) => ButtonSegment<Prioridad>(value: p, label: Text(p.name)))
                  .toList(),
              selected: {_prioridad},
              onSelectionChanged: (sel) => setState(() => _prioridad = sel.first),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: const Icon(Icons.my_location),
              label: Text(_guardando ? 'Guardando...' : 'Guardar con mi ubicación'),
            ),
          ],
        ),
      ),
    );
  }
}
