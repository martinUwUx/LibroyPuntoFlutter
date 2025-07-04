// lib/auth_screens.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Necesario para guardar el RUT

// Este es el gestor de pantallas de autenticación.
// Decide qué pantalla mostrar (login o registro)
class AuthScreenManager extends StatefulWidget {
  const AuthScreenManager({super.key});

  @override
  State<AuthScreenManager> createState() => _AuthScreenManagerState();
}

class _AuthScreenManagerState extends State<AuthScreenManager> {
  bool _showLoginScreen = true; // Controla qué pantalla se muestra

  void _toggleScreen() {
    setState(() {
      _showLoginScreen = !_showLoginScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Icono de flecha hacia atrás si no es la pantalla de inicio de sesión
        leading: _showLoginScreen
            ? null // No hay botón de retroceso en la pantalla de inicio de sesión principal
            : IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _toggleScreen, // Retrocede a la pantalla anterior
        ),
        title: const Text('¡Bienvenido de vuelta!'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'Bienvenido a la App de Libro y Punto, tu nueva forma de disfrutar tus lecturas en la biblioteca en una sola App. ¡Iniciemos sesión y comencemos la aventura!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _showLoginScreen ? null : _toggleScreen,
                    child: Text(
                      'Iniciar sesión',
                      style: TextStyle(
                        color: _showLoginScreen ? Theme.of(context).colorScheme.primary : Colors.grey,
                        fontWeight: _showLoginScreen ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: _showLoginScreen ? _toggleScreen : null,
                    child: Text(
                      'Crear cuenta',
                      style: TextStyle(
                        color: _showLoginScreen ? Colors.grey : Theme.of(context).colorScheme.primary,
                        fontWeight: _showLoginScreen ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Divider(
              color: Theme.of(context).colorScheme.primary,
              thickness: 2,
            ),
            const SizedBox(height: 30),
            // Muestra la pantalla de inicio de sesión o la de creación de cuenta
            _showLoginScreen
                ? LoginScreen(onForgotPassword: (type) {
              if (type == 'password') {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()));
              } else if (type == 'email') {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotEmailScreen()));
              }
            })
                : const CreateAccountScreen(),
          ],
        ),
      ),
    );
  }
}

// Pantalla de Inicio de Sesión
class LoginScreen extends StatefulWidget {
  final ValueChanged<String> onForgotPassword;

  const LoginScreen({super.key, required this.onForgotPassword});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Si el inicio de sesión es exitoso, Firebase AuthListener en main.dart navegará.
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'No se encontró un usuario con ese email.';
      } else if (e.code == 'wrong-password') {
        message = 'Contraseña incorrecta.';
      } else if (e.code == 'invalid-email') {
        message = 'El formato del email es incorrecto.';
      } else {
        message = 'Error de inicio de sesión: ${e.message}';
      }
      _showSnackBar(message);
    } catch (e) {
      _showSnackBar('Ocurrió un error inesperado: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Iniciar sesión',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Correo institucional',
            hintText: 'Correo@lasalle-francia.cl',
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(
            labelText: 'Contraseña',
            hintText: '********',
          ),
          obscureText: true,
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordFlowScreen()));
            },
            child: const Text('Olvidé mis credenciales'),
          ),
        ),
        const SizedBox(height: 20),
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton.icon(
          onPressed: _login,
          icon: const Icon(Icons.check),
          label: const Text('Iniciar sesión'),
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
    );
  }
}

// Pantalla de Creación de Cuenta
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _rutController = TextEditingController(); // Controlador para el RUT
  bool _isLoading = false;

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _register() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _confirmPasswordController.text.trim().isEmpty ||
        _rutController.text.trim().isEmpty) {
      _showSnackBar('Por favor, completa todos los campos.');
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_emailController.text.trim())) {
      _showSnackBar('Por favor, ingresa un correo electrónico válido.');
      return;
    }

    if (_passwordController.text.trim().length < 6) {
      _showSnackBar('La contraseña debe tener al menos 6 caracteres.');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('Las contraseñas no coinciden.');
      return;
    }

    // Obtener el RUT y limpiarlo (quitar puntos y guiones)
    final String rut = _rutController.text.trim().replaceAll('.', '').replaceAll('-', '');
    if (rut.isEmpty) {
      _showSnackBar('Por favor, ingresa tu RUT.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Guardar información adicional del usuario en Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'email': _emailController.text.trim(),
        'rut': rut, // ¡Aquí se guarda el RUT en Firestore!
        'createdAt': FieldValue.serverTimestamp(),
        // Puedes añadir más campos como nombre, nivel, etc.
      });

      _showSnackBar('Cuenta creada exitosamente. Inicia sesión para continuar.', isError: false);

      // Opcional: Enviar verificación de email inmediatamente
      // await userCredential.user?.sendEmailVerification();
      // _showSnackBar('Cuenta creada. Por favor, verifica tu email para iniciar sesión.', isError: false);

    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = 'La contraseña es demasiado débil.';
      } else if (e.code == 'email-already-in-use') {
        message = 'El email ya está en uso para otra cuenta.';
      } else if (e.code == 'invalid-email') {
        message = 'El formato del email es incorrecto.';
      } else {
        message = 'Error de registro: ${e.message}';
      }
      _showSnackBar(message);
    } catch (e) {
      _showSnackBar('Ocurrió un error inesperado: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Crear cuenta',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Correo institucional',
            hintText: 'Correo@lasalle-francia.cl',
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(
            labelText: 'Contraseña',
            hintText: '********',
          ),
          obscureText: true,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _confirmPasswordController,
          decoration: const InputDecoration(
            labelText: 'Confirmar contraseña',
            hintText: '********',
          ),
          obscureText: true,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _rutController,
          decoration: const InputDecoration(
            labelText: 'RUT',
            hintText: 'Sin puntos ni guion',
          ),
          keyboardType: TextInputType.text, // O TextInputType.number si solo esperas dígitos
        ),
        const SizedBox(height: 20),
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton.icon(
          onPressed: _register,
          icon: const Icon(Icons.check),
          label: const Text('Crear cuenta'),
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
    );
  }
}

// ---- Pantallas de Recuperación de Credenciales (Flujo completo) ----

class ForgotPasswordFlowScreen extends StatelessWidget {
  const ForgotPasswordFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Olvidé mis credenciales'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vamos a recuperar tus datos',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF673AB7),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text('Olvidé mi contraseña'),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotEmailScreen()));
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF673AB7),
                side: const BorderSide(color: Color(0xFF673AB7)),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text('Olvidé mi Correo institucional'),
            ),
          ],
        ),
      ),
    );
  }
}


// Pantalla de Olvidé Contraseña
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.trim().isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_emailController.text.trim())) {
      _showSnackBar('Por favor, ingresa un correo electrónico válido.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());
      _showSnackBar('Se ha enviado un enlace de restablecimiento a tu correo.', isError: false);
      Navigator.pop(context); // Vuelve a la pantalla anterior
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'No se encontró un usuario con ese correo.';
      } else {
        message = 'Error al restablecer contraseña: ${e.message}';
      }
      _showSnackBar(message);
    } catch (e) {
      _showSnackBar('Ocurrió un error inesperado: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Olvidé mi Contraseña'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vamos a recuperar tu contraseña',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Correo institucional',
                hintText: 'Correo@lasalle-francia.cl',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF673AB7),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text('Enviar'),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ForgotEmailScreen()));
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF673AB7),
                side: const BorderSide(color: Color(0xFF673AB7)),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text('Olvidé mi Correo institucional'),
            ),
          ],
        ),
      ),
    );
  }
}

// Pantalla de Olvidé Correo Institucional (simulado, necesitaría lógica de backend real)
class ForgotEmailScreen extends StatefulWidget {
  const ForgotEmailScreen({super.key});

  @override
  State<ForgotEmailScreen> createState() => _ForgotEmailScreenState();
}

class _ForgotEmailScreenState extends State<ForgotEmailScreen> {
  final TextEditingController _rutController = TextEditingController(); // Controlador para el RUT
  bool _isLoading = false;

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _recoverEmail() async {
    final String rut = _rutController.text.trim().replaceAll('.', '').replaceAll('-', '');
    if (rut.isEmpty) {
      _showSnackBar('Por favor, ingresa tu RUT.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // --- LÓGICA DE RECUPERACIÓN DE CORREO (Backend necesario) ---
      // Aquí necesitarías una función en tu backend (Cloud Functions, etc.)
      // que reciba el RUT y devuelva el correo electrónico asociado.
      // Firebase Authentication por sí solo no permite recuperar el email por RUT.

      // Simulamos la recuperación exitosa para fines de demostración
      await Future.delayed(const Duration(seconds: 2)); // Simula una llamada a la API
      _showSnackBar('Si tu RUT está registrado, te hemos enviado tu correo a tu canal de recuperación.', isError: false);
      Navigator.pop(context); // Vuelve a la pantalla anterior

    } catch (e) {
      _showSnackBar('Ocurrió un error al intentar recuperar el correo: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Olvidé mi Correo institucional'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vamos a recuperar tu Correo institucional',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _rutController,
              decoration: const InputDecoration(
                labelText: 'RUT',
                hintText: 'Sin puntos ni guion',
              ),
              keyboardType: TextInputType.text, // O TextInputType.number
            ),
            const SizedBox(height: 20),
            Text(
              'Si necesitas ayuda, contacta a x@gmail.com', // Placeholder
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _recoverEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF673AB7),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text('Enviar'),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()));
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF673AB7),
                side: const BorderSide(color: Color(0xFF673AB7)),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text('Olvidé mi Contraseña'),
            ),
          ],
        ),
      ),
    );
  }
}

// Pantalla de Verificación de Email (Opcional)
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificar Email'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Te hemos enviado un código a tu correo institucional',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 30),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Código',
                hintText: '****',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Lógica para verificar el código
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Código verificado (simulado)')),
                );
                // Si la verificación es exitosa, se podría navegar a la Home Screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF673AB7),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text('Enviar'),
            ),
          ],
        ),
      ),
    );
  }
}