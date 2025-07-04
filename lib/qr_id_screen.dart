// lib/qr_id_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Importa el paquete QR

class QrIdScreen extends StatefulWidget {
  const QrIdScreen({super.key});

  @override
  State<QrIdScreen> createState() => _QrIdScreenState();
}

class _QrIdScreenState extends State<QrIdScreen> {
  String? _userRut; // Para almacenar el RUT del usuario
  String _qrData = 'Cargando QR...'; // Datos que contendrá el QR
  bool _hasOverdueBook = false; // Simula si el usuario tiene un libro vencido
  String _overdueBookDate = '29/6/2025'; // Fecha del libro vencido (simulada)

  // Dominio base para la URL del QR
  final String _baseDomain = 'https://tudominio.com/admin/user?id='; // ¡CAMBIA ESTO POR TU DOMINIO REAL!

  @override
  void initState() {
    super.initState();
    _fetchUserRutAndGenerateQR();
    // En una aplicación real, _hasOverdueBook se cargaría de Firestore también
    // _fetchOverdueBookStatus();
  }

  Future<void> _fetchUserRutAndGenerateQR() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final userData = userDoc.data();
          setState(() {
            _userRut = userData?['rut'];
            if (_userRut != null && _userRut!.isNotEmpty) {
              _qrData = '$_baseDomain$_userRut';
            } else {
              _qrData = 'RUT no encontrado. Por favor, completa tu perfil.';
            }
          });
        } else {
          setState(() {
            _qrData = 'Datos de usuario no encontrados.';
          });
        }
      } catch (e) {
        setState(() {
          _qrData = 'Error al cargar el RUT: $e';
        });
        print('Error fetching user RUT: $e');
      }
    } else {
      setState(() {
        _qrData = 'Usuario no autenticado.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.email?.split('@').first ?? 'Usuario';

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR-ID'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'El QR-ID facilita encontrar tu perfil para agregar tus puntos.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),

            // Banner "Tienes un libro vencido/arrendado"
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    _hasOverdueBook ? Icons.error_outline : Icons.add_circle_outline,
                    color: _hasOverdueBook ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _hasOverdueBook ? 'Tienes un libro vencido' : 'Tienes un libro arrendado',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Hasta el $_overdueBookDate', // Esto debe ser dinámico
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Stack( // Iconos superpuestos
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // Contenedor del QR
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: _qrData.startsWith('http')
                  ? QrImageView(
                data: _qrData,
                version: QrVersions.auto,
                size: 250.0,
                gapless: false,
                embeddedImage: const AssetImage('assets/your_logo.png'), // Opcional: añade un logo en el centro
                embeddedImageStyle: const QrEmbeddedImageStyle(
                  size: Size(50, 50),
                ),
              )
                  : Text(
                _qrData, // Muestra el mensaje de error o carga
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.red),
              ),
            ),
            const SizedBox(height: 24.0),
            Text(
              'QR-ID de $userName',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24.0),
            ElevatedButton.icon(
              onPressed: () {
                // Lógica para "Desactivar" o alguna otra acción con el QR
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Función de Desactivar/Activar QR-ID')),
                );
              },
              icon: const Icon(Icons.close), // O Icons.check para "Activar"
              label: const Text('Desactivar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF673AB7),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}