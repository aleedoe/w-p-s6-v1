// main.dart
import 'package:flutter/material.dart';
import 'views/login_screen.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modern Business App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Color(0xFF2196F3),
        scaffoldBackgroundColor: Color(0xFFF5F5F5),
        fontFamily: 'Roboto',
      ),
      home: AuthWrapper(),
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

  @override
  Widget build(BuildContext context) {
    return isAuthenticated ? MainApp() : LoginScreen();
  }

  void authenticate() {
    setState(() {
      isAuthenticated = true;
    });
  }
}