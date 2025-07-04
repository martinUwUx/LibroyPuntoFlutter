// lib/challenges_screen.dart
import 'package:flutter/material.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Desafíos'), // Título de la pestaña
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Contenido de la Pantalla de Desafíos',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}