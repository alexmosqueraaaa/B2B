import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool isLogin = true;

  void _submitAuthForm() async {
    try {
      final auth = FirebaseAuth.instance;
      UserCredential userCredential;

      if (isLogin) {
        // Iniciar sesión
        userCredential = await auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        // Registrar usuario
        userCredential = await auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Guardar nombre del usuario en Firestore
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
        });
      }

      // Navegar a HomeScreen
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx) => HomeScreen()));
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? "Iniciar Sesión" : "Registro")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            if (!isLogin) 
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Nombre"),
              ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Correo"),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Contraseña"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitAuthForm,
              child: Text(isLogin ? "Iniciar Sesión" : "Registrarse"),
            ),
            TextButton(
              onPressed: () => setState(() => isLogin = !isLogin),
              child: Text(isLogin ? "Crear una cuenta" : "Ya tengo una cuenta"),
            ),
          ],
        ),
      ),
    );
  }
}

