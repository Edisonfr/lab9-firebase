import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PantallaAuth extends StatefulWidget {
  const PantallaAuth({super.key});

  @override
  State<PantallaAuth> createState() => _PantallaAuthState();
}

class _PantallaAuthState extends State<PantallaAuth> {
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _clave = TextEditingController();
  String? _error;
  bool _cargando = false;

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _clave.dispose();
    super.dispose();
  }

  Future<void> _entrar({required bool registrar}) async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      if (registrar) {
        final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _correo.text.trim(),
          password: _clave.text.trim(),
        );
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(cred.user!.uid)
            .set({
          'nombre': _nombre.text.trim(),
          'correo': _correo.text.trim(),
          'creado': FieldValue.serverTimestamp(),
        });
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _correo.text.trim(),
          password: _clave.text.trim(),
        );
      }
    } on FirebaseAuthException catch (e) {
      _error = e.message;
    }
    if (mounted) setState(() => _cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solicitudes de soporte')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            controller: _nombre,
            decoration: const InputDecoration(labelText: 'Nombre (solo al registrarse)'),
          ),
          TextField(
            controller: _correo,
            decoration: const InputDecoration(labelText: 'Correo electrónico'),
          ),
          TextField(
            controller: _clave,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Contraseña (mínimo 6 caracteres)'),
          ),
          const SizedBox(height: 16),
          if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 8),
          if (_cargando)
            const Center(child: CircularProgressIndicator())
          else ...[
            ElevatedButton(
              onPressed: () => _entrar(registrar: true),
              child: const Text('Registrarme'),
            ),
            OutlinedButton(
              onPressed: () => _entrar(registrar: false),
              child: const Text('Iniciar sesión'),
            ),
          ],
        ],
      ),
    );
  }
}
