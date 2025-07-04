// lib/news_screen.dart
import 'package:flutter/material.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Noticias'), // Título de la pestaña
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Contenido de la Pantalla de Noticias',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}