import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/chat_screen.dart'; // Asegúrate de tener esta pantalla

void main() async {
  // Asegúrate de que Flutter haya inicializado todos los widgets
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa Firebase
  await Firebase.initializeApp();
  // Ejecuta la app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'B2B',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return HomeScreen(); // Si el usuario está autenticado, muestra HomeScreen
          }
          return AuthScreen(); // Si el usuario no está autenticado, muestra AuthScreen
        },
      ),
      routes: {
        '/home': (context) => HomeScreen(), // Pantalla de inicio después de autenticación
        '/chat': (context) {
          final chatId = ModalRoute.of(context)!.settings.arguments as String;
          return ChatScreen(chatId: chatId, userName: AutofillHints.username,); // Pantalla de chat que creamos anteriormente
        },
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Controladores de texto para el formulario de registro
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  // Método para incrementar el contador
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
    _saveData(_counter);  // Guarda el contador en Firestore
  }

  // Método para guardar datos en Firestore
  void _saveData(int count) async {
    await _firestore.collection('counter').doc('current_count').set({
      'count': count,
    });
  }

  // Método para leer datos desde Firestore
  Stream<DocumentSnapshot> _getData() {
    return _firestore.collection('counter').doc('current_count').snapshots();
  }

  // Método para registrar el usuario
  Future<User?> _registerUser(String email, String password, String name) async {
    try {
      // Registra al usuario en Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        // Almacena el nombre y otros detalles en Firestore
        await _firestore.collection("users").doc(user.uid).set({
          "name": name,
          "email": email,
          "profilePic": "",
          "attendingEvents": [],
        });
      }
      return user;
    } catch (e) {
      print("Error en registro: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Formulario de registro de usuario
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                var email = _emailController.text;
                var password = _passwordController.text;
                var name = _nameController.text;
                var user = await _registerUser(email, password, name);
                if (user != null) {
                  // Si se registra correctamente, navega a la pantalla de inicio
                  print("Usuario registrado: ${user.email}");
                  Navigator.pushReplacementNamed(context, '/home');
                } else {
                  // Si ocurre un error al registrar
                  print("Error al registrar el usuario");
                }
              },
              child: Text("Registrar"),
            ),

            // Contador
            const SizedBox(height: 20),
            Text(
              'Has pulsado el botón demasiadas veces:',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            StreamBuilder<DocumentSnapshot>( 
              stream: _getData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                }

                if (!snapshot.hasData) {
                  return Text("No data found");
                }

                var data = snapshot.data?.data() as Map<String, dynamic>;
                var count = data['count'] ?? 0;

                return Text(
                  '$count',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}






