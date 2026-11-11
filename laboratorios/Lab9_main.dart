import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const PerfilApp());
}

class PerfilApp extends StatelessWidget {
  const PerfilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lab 9 - Firebase',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PantallaAuth(),
    );
  }
}

// ---------- Pantalla de registro / inicio de sesión ----------
class PantallaAuth extends StatefulWidget {
  const PantallaAuth({super.key});

  @override
  State<PantallaAuth> createState() => _PantallaAuthState();
}

class _PantallaAuthState extends State<PantallaAuth> {
  final correoCtrl = TextEditingController();
  final claveCtrl = TextEditingController();
  final nombreCtrl = TextEditingController();
  bool cargando = false;
  String? error;

  Future<void> registrar() async {
    setState(() { cargando = true; error = null; });
    try {
      final credencial = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: correoCtrl.text.trim(),
        password: claveCtrl.text.trim(),
      );

      await FirebaseFirestore.instance.collection('usuarios').doc(credencial.user!.uid).set({
        'nombre': nombreCtrl.text.trim(),
        'correo': correoCtrl.text.trim(),
        'creado': FieldValue.serverTimestamp(),
      });

      irAPerfil(credencial.user!);
    } on FirebaseAuthException catch (e) {
      setState(() => error = e.message);
    } finally {
      setState(() => cargando = false);
    }
  }

  Future<void> iniciarSesion() async {
    setState(() { cargando = true; error = null; });
    try {
      final credencial = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: correoCtrl.text.trim(),
        password: claveCtrl.text.trim(),
      );
      irAPerfil(credencial.user!);
    } on FirebaseAuthException catch (e) {
      setState(() => error = e.message);
    } finally {
      setState(() => cargando = false);
    }
  }

  void irAPerfil(User usuario) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PantallaPerfil(usuario: usuario)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro / Inicio de sesión')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre (solo para registro)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: correoCtrl,
              decoration: const InputDecoration(labelText: 'Correo electrónico'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: claveCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña (mín. 6 caracteres)'),
            ),
            const SizedBox(height: 20),
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            if (cargando)
              const Center(child: CircularProgressIndicator())
            else ...[
              ElevatedButton(onPressed: registrar, child: const Text('Registrarme')),
              const SizedBox(height: 8),
              OutlinedButton(onPressed: iniciarSesion, child: const Text('Iniciar sesión')),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------- Pantalla de perfil (ya autenticado) ----------
class PantallaPerfil extends StatelessWidget {
  final User usuario;
  const PantallaPerfil({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const PantallaAuth()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('usuarios').doc(usuario.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final datos = snapshot.data!.data() as Map<String, dynamic>?;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
                const SizedBox(height: 16),
                Text(datos?['nombre'] ?? 'Sin nombre', style: const TextStyle(fontSize: 22)),
                Text(usuario.email ?? ''),
                Text('UID: ${usuario.uid}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          );
        },
      ),
    );
  }
}