import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Método para registrar a un usuario
  Future<void> register(String email, String password, String name) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Puedes guardar el nombre u otros detalles adicionales en Firestore si lo deseas
      // Ejemplo: await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
      //   'name': name,
      // });
    } on FirebaseAuthException catch (e) {
      print('Error al registrar: $e');
    }
  }

  // Método para iniciar sesión
  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      print('Error al iniciar sesión: $e');
    }
  }

  // Método para cerrar sesión
  Future<void> logout() async {
    await _auth.signOut();
  }
}
