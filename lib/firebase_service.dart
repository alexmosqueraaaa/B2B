// lib/firebase_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
 
  // Registrar nuevo usuario en Firestore
  Future<void> registerUser(String email, String password, String username) async {
    try {
      // Crear usuario con Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Guardar usuario en Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'username': username,
      });

      print('Usuario registrado y guardado en Firestore');
    } catch (e) {
      print('Error registrando el usuario: $e');
    }
  }
}
