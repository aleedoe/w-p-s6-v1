// main.dart
import 'package:flutter/material.dart';
import 'views/login_screen.dart';
import 'models/auth_models.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modern Business App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF2196F3),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        fontFamily: 'Roboto',
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Auth Wrapper untuk mengecek status login
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool isAuthenticated = false;
  User? currentUser;

  @override
  Widget build(BuildContext context) {
    if (isAuthenticated && currentUser != null) {
      return MainApp(user: currentUser!);
    } else {
      return LoginScreen();
    }
  }

  // bisa dipanggil setelah login sukses
  void authenticate(User user) {
    setState(() {
      isAuthenticated = true;
      currentUser = user;
    });
  }
}

// Halaman utama setelah login
class MainApp extends StatelessWidget {
  final User user;
  const MainApp({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Selamat datang, ${user.name}"),
      ),
      body: Center(
        child: Text(
          "Halo ${user.name}, ini halaman utama aplikasi!",
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
