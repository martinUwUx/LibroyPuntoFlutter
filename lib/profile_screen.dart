
// lib/profile_screen.dart
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'), // Título de la pestaña
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Contenido de la Pantalla de Perfil',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}