import 'package:cloud_firestore/cloud_firestore.dart';

import '../modelos/solicitud.dart';

/// Acceso a la colección `solicitudes` de Cloud Firestore.
class SolicitudesServicio {
  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('solicitudes');

  /// Solicitudes del usuario, de la más reciente a la más antigua.
  /// Se ordena en el cliente para no requerir un índice compuesto.
  Stream<List<Solicitud>> mias(String uid) {
    return _col.where('creadoPor', isEqualTo: uid).snapshots().map((q) {
      final lista = q.docs.map((d) => Solicitud.desdeDoc(d)).toList();
      final ahora = DateTime.now();
      lista.sort((a, b) => (b.creada ?? ahora).compareTo(a.creada ?? ahora));
      return lista;
    });
  }

  Stream<Solicitud?> una(String id) {
    return _col.doc(id).snapshots().map((d) => d.exists ? Solicitud.desdeDoc(d) : null);
  }

  Future<void> crear(Solicitud s) => _col.add(s.aMapa());

  Future<void> cambiarEstado(String id, Estado estado) {
    return _col.doc(id).update({
      'estado': estado.texto,
      if (estado == Estado.atendida) 'atendida': FieldValue.serverTimestamp(),
    });
  }
}
