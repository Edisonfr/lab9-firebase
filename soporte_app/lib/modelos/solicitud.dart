import 'package:cloud_firestore/cloud_firestore.dart';

enum Estado { pendiente, enProceso, atendida }

enum Prioridad { baja, media, alta }

extension EstadoTexto on Estado {
  /// Texto que se guarda en Firestore.
  String get texto => switch (this) {
        Estado.pendiente => 'pendiente',
        Estado.enProceso => 'en_proceso',
        Estado.atendida => 'atendida',
      };
}

Estado estadoDesde(String? texto) {
  return Estado.values.firstWhere(
    (e) => e.texto == texto,
    orElse: () => Estado.pendiente,
  );
}

Prioridad prioridadDesde(String? texto) {
  return Prioridad.values.firstWhere(
    (p) => p.name == texto,
    orElse: () => Prioridad.media,
  );
}

class Solicitud {
  final String id;
  final String titulo;
  final String descripcion;
  final Prioridad prioridad;
  final Estado estado;
  final GeoPoint? ubicacion;
  final String creadoPor;
  final DateTime? creada;

  const Solicitud({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.prioridad,
    required this.estado,
    required this.creadoPor,
    this.ubicacion,
    this.creada,
  });

  factory Solicitud.desdeDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data() ?? <String, dynamic>{};
    return Solicitud(
      id: doc.id,
      titulo: (m['titulo'] ?? '') as String,
      descripcion: (m['descripcion'] ?? '') as String,
      prioridad: prioridadDesde(m['prioridad'] as String?),
      estado: estadoDesde(m['estado'] as String?),
      ubicacion: m['ubicacion'] as GeoPoint?,
      creadoPor: (m['creadoPor'] ?? '') as String,
      creada: (m['creada'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> aMapa() => {
        'titulo': titulo,
        'descripcion': descripcion,
        'prioridad': prioridad.name,
        'estado': estado.texto,
        'ubicacion': ubicacion,
        'creadoPor': creadoPor,
        'creada': FieldValue.serverTimestamp(),
      };
}
