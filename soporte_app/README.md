# Solicitudes de soporte — Caso aplicado (Flutter + Firebase)

Trabajo de grado, modalidad Certificación (Flutter Certified Application Developer, AFD-200).
Autor: Edison Andrés Forero Riaño — Escuela Tecnológica Instituto Técnico Central.

## ¿Qué hace?
Aplicación para registrar, consultar y dar seguimiento a solicitudes de soporte técnico en sitio:
registro e inicio de sesión, creación de solicitudes con ubicación GPS, lista, detalle con cambio de estado
y mapa de atenciones.

## Dominios del examen que integra
A (modelos y enumeraciones en Dart) · B (widgets y layouts) · C (navegación) · D (formularios y validaciones) ·
E (Firebase Authentication y Cloud Firestore) · F (permisos y ubicación, mapa y pruebas).

## Cómo ejecutarla
```bash
flutter pub get
flutter run -d web-server --web-port=8080
```
Requiere un proyecto de Firebase con Authentication (correo y contraseña) y Cloud Firestore.
Las reglas están en `firestore.rules`. La configuración se genera con `flutterfire configure`.

## Estructura
- `lib/modelos/` — clase `Solicitud` y enumeraciones.
- `lib/servicios/` — acceso a Firestore.
- `lib/pantallas/` — autenticación, lista, nueva, detalle y mapa.
- `test/` — pruebas unitarias.

## Pruebas
(Tabla CP1–CP8 con resultados y capturas)

## Mapa
Usa `flutter_map` con teselas de Wikimedia (sin clave de API ni facturación).
