import 'package:flutter/material.dart';

import '../modelos/solicitud.dart';
import '../servicios/solicitudes_servicio.dart';

class PantallaDetalle extends StatelessWidget {
  final String id;

  const PantallaDetalle({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final servicio = SolicitudesServicio();

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de la solicitud')),
      body: StreamBuilder<Solicitud?>(
        stream: servicio.una(id),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final s = snap.data;
          if (s == null) return const Center(child: Text('La solicitud ya no existe'));

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.titulo, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(s.descripcion),
                const SizedBox(height: 8),
                Text('Prioridad: ${s.prioridad.name}'),
                Text(s.ubicacion != null
                    ? 'Ubicación: ${s.ubicacion!.latitude.toStringAsFixed(5)}, ${s.ubicacion!.longitude.toStringAsFixed(5)}'
                    : 'Sin ubicación'),
                const SizedBox(height: 20),
                const Text('Estado'),
                const SizedBox(height: 8),
                SegmentedButton<Estado>(
                  segments: Estado.values
                      .map((e) => ButtonSegment<Estado>(value: e, label: Text(e.texto)))
                      .toList(),
                  selected: {s.estado},
                  onSelectionChanged: (sel) async {
                    await servicio.cambiarEstado(s.id, sel.first);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Estado actualizado')),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
