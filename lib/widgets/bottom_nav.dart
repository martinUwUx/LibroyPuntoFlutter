import 'package:flutter/material.dart';
class BottomNavigation extends StatelessWidget {
  const BottomNavigation();

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: 2,
      onDestinationSelected: (_) {},
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.mail), label: 'Noticias'),
        NavigationDestination(icon: Icon(Icons.search), label: 'Explorar'),
        NavigationDestination(icon: Icon(Icons.flag), label: 'Desafíos'),
        NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
      ],
    );
  }
}
