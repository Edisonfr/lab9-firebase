import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'pantallas/auth.dart';
import 'pantallas/lista.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SoporteApp());
}

class SoporteApp extends StatelessWidget {
  const SoporteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Solicitudes de soporte',
      theme: ThemeData(colorSchemeSeed: Colors.teal),
      // Si hay sesión se muestra la lista; si no, el registro / inicio de sesión
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return snap.hasData ? const PantallaLista() : const PantallaAuth();
        },
      ),
    );
  }
}
