// lib/profile_screen.dart
import 'package:flutter/material.dart';
import 'widgets/search_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Avatar y nombre
                    CircleAvatar(radius: 48, child: Icon(Icons.person, size: 48)),
                    const SizedBox(height: 16),
                    Text('Martín Ávila', style: Theme.of(context).textTheme.titleLarge),
                    Text('8°A / 8°B', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {},
                      child: Text('Activar QR-ID'),
                    ),
                    const SizedBox(height: 20),
                    // Card de alerta
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: Icon(Icons.warning, color: Theme.of(context).colorScheme.error),
                        title: Text('Tienes un libro vencido', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                        subtitle: Text('Desde el 29/6/2025'),
                        trailing: Icon(Icons.category, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Puntos y nivel
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        title: Text('Nivel 8', style: Theme.of(context).textTheme.titleMedium),
                        subtitle: Text('Tienes 298 puntos'),
                        trailing: FilledButton(
                          onPressed: () {},
                          child: Text('Tus beneficios'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Estadísticas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(children: [Text('16', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)), Text('Préstamos', style: Theme.of(context).textTheme.bodyMedium)]),
                        Column(children: [Text('10', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)), Text('Reseñas', style: Theme.of(context).textTheme.bodyMedium)]),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}