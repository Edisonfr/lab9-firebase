# Solicitudes de soporte — Caso aplicado (Flutter + Firebase)

Trabajo de grado, modalidad Certificación (Flutter Certified Application Developer, AFD-200).
Autor: Edison Andrés Forero Riaño — Escuela Tecnológica Instituto Técnico Central.

## Qué hace
Aplicación para registrar, consultar y dar seguimiento a solicitudes de soporte técnico en sitio:
registro e inicio de sesión, creación de solicitudes con ubicación GPS, lista, detalle con cambio
de estado y mapa de atenciones.

## Dominios del examen que integra
A (modelos y enumeraciones en Dart) · B (widgets y layouts) · C (navegación) · D (formularios y
validaciones) · E (Firebase Authentication y Cloud Firestore) · F (permisos, ubicación, mapa y pruebas).

## Cómo ejecutarla
    cd soporte_app
    flutter pub get
    flutter run -d web-server --web-port=8080
Requiere un proyecto de Firebase con Authentication (correo y contraseña) y Cloud Firestore.
La configuración se genera con `flutterfire configure` (archivo `lib/firebase_options.dart`).

## Estructura
- `lib/modelos/` — clase `Solicitud` y enumeraciones de estado y prioridad.
- `lib/servicios/` — acceso a Firestore.
- `lib/pantallas/` — autenticación, lista, nueva solicitud, detalle y mapa.
- `test/` — pruebas unitarias del modelo.
- `firestore.rules` — reglas de seguridad publicadas el 11/11/2026.

## Seguridad
Cada usuario solo lee y escribe su propio perfil y sus propias solicitudes. Con las reglas
publicadas, un usuario nuevo no ve las solicitudes de otro (verificado el 11/11/2026).

## Pruebas
Análisis estático: `flutter analyze` sin problemas. Pruebas unitarias: `flutter test`, 4 pruebas aprobadas.

| ID | Caso | Resultado | Estado |
|---|---|---|---|
| CP1 | Registro válido | Usuario en Authentication y perfil en Firestore | Cumple |
| CP2 | Clave incorrecta | Mensaje de error (en inglés, texto de Firebase), sin acceso | Cumple |
| CP3 | Solicitud con campos vacíos | La validación impide el envío | Cumple |
| CP4 | Solicitud con ubicación permitida | Guardada con coordenadas | Cumple |
| CP5 | Ubicación denegada | Guardada sin ubicación, con aviso | Cumple |
| CP6 | Cambiar el estado | Se actualiza en lista, detalle y Firestore | Cumple |
| CP7 | Mapa | Un marcador por solicitud con ubicación | Cumple, tras cambiar el proveedor de teselas |
| CP8 | Cerrar sesión | Vuelve a la pantalla de inicio | Cumple |

## Hallazgos del desarrollo
- Teselas del mapa: Wikimedia respondió "uso restringido" y OpenStreetMap respondió 403 al servir la app
  web; se usan teselas de Esri con atribución.
- Los mensajes de error de Firebase Authentication llegan en inglés.

## Alcance
Solo versión web. No incluye APK, publicación en tiendas ni notificaciones push.
