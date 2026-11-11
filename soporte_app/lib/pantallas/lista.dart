import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../modelos/solicitud.dart';
import '../servicios/solicitudes_servicio.dart';
import 'detalle.dart';
import 'mapa.dart';
import 'nueva.dart';

class PantallaLista extends StatelessWidget {
  const PantallaLista({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final servicio = SolicitudesServicio();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis solicitudes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            tooltip: 'Mapa de atenciones',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PantallaMapa()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const PantallaNueva()));
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva'),
      ),
      body: StreamBuilder<List<Solicitud>>(
        stream: servicio.mias(uid),
        builder: (context, snap) {
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final lista = snap.data!;
          if (lista.isEmpty) return const Center(child: Text('Aún no hay solicitudes'));
          return ListView.builder(
            itemCount: lista.length,
            itemBuilder: (context, i) {
              final s = lista[i];
              return Card(
                child: ListTile(
                  leading: Icon(s.ubicacion != null ? Icons.location_on : Icons.location_off),
                  title: Text(s.titulo),
                  subtitle: Text('${s.prioridad.name} · ${s.estado.texto}'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => PantallaDetalle(id: s.id)));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
