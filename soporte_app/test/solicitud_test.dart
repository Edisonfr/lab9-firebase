import 'package:flutter_test/flutter_test.dart';
import 'package:soporte_app/modelos/solicitud.dart';

void main() {
  test('estadoDesde convierte el texto de Firestore al enum', () {
    expect(estadoDesde('en_proceso'), Estado.enProceso);
    expect(estadoDesde('atendida'), Estado.atendida);
  });

  test('estadoDesde usa pendiente si el texto es desconocido o nulo', () {
    expect(estadoDesde('algo_raro'), Estado.pendiente);
    expect(estadoDesde(null), Estado.pendiente);
  });

  test('el texto de cada estado coincide con el guardado en Firestore', () {
    expect(Estado.pendiente.texto, 'pendiente');
    expect(Estado.enProceso.texto, 'en_proceso');
    expect(Estado.atendida.texto, 'atendida');
  });

  test('prioridadDesde usa media si el texto es desconocido', () {
    expect(prioridadDesde('alta'), Prioridad.alta);
    expect(prioridadDesde('xyz'), Prioridad.media);
  });
}
