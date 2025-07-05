import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Importa el archivo generado automáticamente
import 'package:lypflutter2/firebase_options.dart'; // <--- ¡ASEGÚRATE QUE ESTA RUTA SEA CORRECTA!
// Si tu proyecto se llama diferente, ajusta 'libroypunto_app'
// Por ejemplo, si tu proyecto es 'mi_app', sería:
// import 'package:mi_app/firebase_options.dart';

import 'home_screen.dart';
import 'news_screen.dart';
import 'explore_screen.dart';
import 'challenges_screen.dart';
import 'profile_screen.dart';
import 'auth_screens.dart';
import 'admin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // <--- ¡AQUÍ SE USAN LAS OPCIONES GENERADAS!
  );
  runApp(const MyApp());
}

final ColorScheme customColorSchemeLight = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF6C4DFF),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFEADDFF),
  onPrimaryContainer: Color(0xFF21005D),
  secondary: Color(0xFF625B71),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFE8DEF8),
  onSecondaryContainer: Color(0xFF1D192B),
  tertiary: Color(0xFF7D5260),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFFFD8E4),
  onTertiaryContainer: Color(0xFF31111D),
  error: Color(0xFFB3261E),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFF9DEDC),
  onErrorContainer: Color(0xFF410E0B),
  background: Color(0xFFFFFBFE),
  onBackground: Color(0xFF1C1B1F),
  surface: Color(0xFFFFFBFE),
  onSurface: Color(0xFF1C1B1F),
  surfaceVariant: Color(0xFFE7E0EC),
  onSurfaceVariant: Color(0xFF49454F),
  outline: Color(0xFF79747E),
  outlineVariant: Color(0xFFCAC4D0),
  inverseSurface: Color(0xFF313033),
  onInverseSurface: Color(0xFFF4EFF4),
  inversePrimary: Color(0xFFD0BCFF),
);

final ColorScheme customColorSchemeDark = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFD0BCFF),
  onPrimary: Color(0xFF381E72),
  primaryContainer: Color(0xFF4F378B),
  onPrimaryContainer: Color(0xFFEADDFF),
  secondary: Color(0xFFCCC2DC),
  onSecondary: Color(0xFF332D41),
  secondaryContainer: Color(0xFF4A4458),
  onSecondaryContainer: Color(0xFFE8DEF8),
  tertiary: Color(0xFFEFB8C8),
  onTertiary: Color(0xFF492532),
  tertiaryContainer: Color(0xFF633B48),
  onTertiaryContainer: Color(0xFFFFD8E4),
  error: Color(0xFFF2B8B5),
  onError: Color(0xFF601410),
  errorContainer: Color(0xFF8C1D18),
  onErrorContainer: Color(0xFFF9DEDC),
  background: Color(0xFF1C1B1F),
  onBackground: Color(0xFFE6E1E5),
  surface: Color(0xFF1C1B1F),
  onSurface: Color(0xFFE6E1E5),
  surfaceVariant: Color(0xFF49454F),
  onSurfaceVariant: Color(0xFFCAC4D0),
  outline: Color(0xFF938F99),
  outlineVariant: Color(0xFF49454F),
  inverseSurface: Color(0xFFE6E1E5),
  onInverseSurface: Color(0xFF313033),
  inversePrimary: Color(0xFF6C4DFF),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Libro y Punto',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: customColorSchemeLight,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.normal, letterSpacing: 0),
          displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.normal, letterSpacing: 0),
          displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.normal, letterSpacing: 0),
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.normal, letterSpacing: 0),
          headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.normal, letterSpacing: 0),
          headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.normal, letterSpacing: 0),
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.normal, letterSpacing: 0),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.1),
          titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
          labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
          labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, letterSpacing: 0.5),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, letterSpacing: 0.25),
          bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, letterSpacing: 0.4),
        ),
        scaffoldBackgroundColor: customColorSchemeLight.background,

        // --- Configuración de AppBar ---
        appBarTheme: AppBarTheme(
          backgroundColor: customColorSchemeLight.primary, // Color de fondo del AppBar
          foregroundColor: customColorSchemeLight.onPrimary, // Color de iconos y texto en AppBar
          elevation: 0, // Sin sombra
          centerTitle: true,
        ),

        // --- Configuración de NavigationBar (barra inferior) ---
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: customColorSchemeLight.surface, // Fondo de la barra
          indicatorColor: customColorSchemeLight.primaryContainer, // Color de la "píldora"
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return TextStyle(color: customColorSchemeLight.primary, fontSize: 12); // Texto activo
            }
            return TextStyle(color: customColorSchemeLight.onSurfaceVariant, fontSize: 12); // Texto inactivo
          }),
          iconTheme: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return IconThemeData(color: customColorSchemeLight.primary); // Icono activo
            }
            return IconThemeData(color: customColorSchemeLight.onSurfaceVariant); // Icono inactivo
          }),
          height: 60, // Ajusta la altura si es necesario
          elevation: 5, // Ligera sombra
        ),

        // --- Configuración de ElevatedButton (botón principal, lleno) ---
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: customColorSchemeLight.primary, // Fondo del botón
            foregroundColor: customColorSchemeLight.onPrimary, // Color del texto/icono
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0), // Bordes redondeados
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Relleno
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            elevation: 2, // Ligera sombra
          ),
        ),

        // --- Configuración de OutlinedButton (botón con contorno) ---
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: customColorSchemeLight.primary, // Color del texto/icono
            side: BorderSide(color: customColorSchemeLight.primary, width: 1.5), // Color y ancho del borde
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0), // Bordes redondeados
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),

        // --- Configuración de Card ---
        cardTheme: CardThemeData( // ¡CORREGIDO ANTERIORMENTE!
          color: customColorSchemeLight.surface, // Fondo de la tarjeta (blanco/gris claro)
          elevation: 3, // Sombra sutil
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0), // Bordes redondeados
          ),
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), // Margen alrededor de la tarjeta
        ),

        // --- Configuración de TextField/InputDecoration (campos de texto) ---
        inputDecorationTheme: InputDecorationTheme(
          fillColor: customColorSchemeLight.surface, // Color de fondo del campo
          filled: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0), // Bordes redondeados
            borderSide: BorderSide(color: customColorSchemeLight.outline, width: 1.0), // Borde normal
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: customColorSchemeLight.primary, width: 2.0), // Borde cuando está enfocado
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: customColorSchemeLight.error, width: 2.0), // Borde con error
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: customColorSchemeLight.error, width: 2.0),
          ),
          labelStyle: TextStyle(color: customColorSchemeLight.onSurfaceVariant), // Color de la etiqueta
          hintStyle: TextStyle(color: customColorSchemeLight.onSurfaceVariant.withOpacity(0.6)), // Color del hint
        ),

        // --- Configuración de Chip ---
        chipTheme: ChipThemeData(
          backgroundColor: customColorSchemeLight.primaryContainer, // Fondo del chip no seleccionado
          selectedColor: customColorSchemeLight.primary, // Fondo del chip seleccionado
          labelStyle: TextStyle(color: customColorSchemeLight.onPrimaryContainer), // Color del texto del chip no seleccionado
          secondaryLabelStyle: TextStyle(color: customColorSchemeLight.onPrimary), // Color del texto del chip seleccionado
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0), // Bordes muy redondeados
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: customColorSchemeDark,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.normal, letterSpacing: 0),
          displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.normal, letterSpacing: 0),
          displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.normal, letterSpacing: 0),
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.normal, letterSpacing: 0),
          headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.normal, letterSpacing: 0),
          headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.normal, letterSpacing: 0),
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.normal, letterSpacing: 0),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.1),
          titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
          labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
          labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, letterSpacing: 0.5),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, letterSpacing: 0.25),
          bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, letterSpacing: 0.4),
        ),
        scaffoldBackgroundColor: customColorSchemeDark.background,
      ),
      themeMode: ThemeMode.system,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            return const MainNavigation();
          } else {
            return const AuthScreenManager();
          }
        },
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  bool _isAdmin = false;

  static final List<Widget> _screens = <Widget>[
    HomeScreen(),
    NewsScreen(),
    ExploreScreen(),
    ChallengesScreen(),
    ProfileScreen(),
    AdminScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkAdminRole();
  }

  Future<void> _checkAdminRole() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (userDoc.exists) {
          String? role = userDoc.get('role');
          setState(() {
            _isAdmin = role == 'DLS';
          });
        }
      }
    } catch (e) {
      // Error al verificar rol, mantener como no admin
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
          child: _screens[_selectedIndex],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          const NavigationDestination(icon: Icon(Icons.mail), label: 'Noticias'),
          const NavigationDestination(icon: Icon(Icons.search), label: 'Explorar'),
          const NavigationDestination(icon: Icon(Icons.flag), label: 'Desafíos'),
          const NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
          if (_isAdmin) const NavigationDestination(icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
        ],
      ),
    );
  }
}
