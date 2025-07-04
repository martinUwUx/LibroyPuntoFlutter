// lib/home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lypflutter2/qr_id_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    // Usamos el color principal del tema para el fondo del Scaffold si es necesario
    // Scaffold(backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1), ...
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: TextField(
          decoration: InputDecoration(
            hintText: '¿Buscas algo rápido?',
            hintStyle: TextStyle(color: Colors.grey[600]),
            prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
            // Ya no necesitas border: InputBorder.none; si lo controlas con inputDecorationTheme
            // Ya no necesitas contentPadding; si lo controlas con inputDecorationTheme
            // Ya no necesitas filled: true, fillColor: Colors.white; si lo controlas con inputDecorationTheme
          ),
          onSubmitted: (query) {
            print('Búsqueda rápida en Home: $query');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout), // Icono de logout, ya con color de Theme
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
        // background y foreground color ya vienen de Theme.of(context).appBarTheme
        // elevation también viene de Theme.of(context).appBarTheme
        toolbarHeight: 70,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¡Esto es Libro y Punto!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '¡Hola!, ¿Qué quieres hacer hoy ${user?.email?.split('@')[0] ?? 'Usuario'}?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            // ElevatedButton ya usa el estilo del tema
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QrIdScreen()),
                );
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Activar QR-ID'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                // Ya no necesitas backgroundColor ni foregroundColor aquí si los definiste en el tema
                // Ya no necesitas shape si lo definiste en el tema
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      print('Ir a Desafíos');
                    },
                    icon: const Icon(Icons.emoji_events),
                    label: const Text('Desafíos'),
                    style: OutlinedButton.styleFrom(
                      // Ya no necesitas foregroundColor ni side si los definiste en el tema
                      // Ya no necesitas shape si lo definiste en el tema
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      print('Ir a Echo');
                    },
                    icon: const Icon(Icons.volume_up),
                    label: const Text('Echo'),
                    style: OutlinedButton.styleFrom(
                      // Ya no necesitas foregroundColor ni side si los definiste en el tema
                      // Ya no necesitas shape si lo definiste en el tema
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Card ya usa el estilo del tema
            Card(
              // elevation y shape ya vienen de Theme.of(context).cardTheme
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Theme.of(context).colorScheme.error, size: 40),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tienes un libro vencido',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.error),
                          ),
                          Text(
                            'Desde el 30/6/2025',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.category, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              '¿Buscas algo nuevo?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Dona un libro',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Participa en el programa "Donemos un libro" de Libro y Punto y gana puntos por cada donación.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 15),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          print('Donar un libro');
                        },
                        child: const Text('Donar un libro'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '1ro',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Libro destacado',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            'assets/el_libro_salvaje.jpg',
                            width: 100,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'El libro salvaje',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Juan Villoro / FCE',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Juan ya tiene planeadas las vacaciones de verano. Sin embargo, su madre ignora sus planes y lo deja en casa de tío Tito, un bibliófilo empedernido que hace ruido cuando come y que le teme a los osos de peluche. Ahí, escondido entre los miles ejemplares de la biblioteca de su tío...',
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: OutlinedButton(
                                  onPressed: () {
                                    print('Ver detalles de El libro salvaje');
                                  },
                                  child: const Text('Ver'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Explorar',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Explora nuestra colección de libros disponibles para retiro en el CRA, descubre los títulos destacados y accede a los digitales.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 15),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Implementar navegación a la pestaña Explorar
                          print('Navegar a Explorar');
                        },
                        child: const Text('Explorar'),
                      ),
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