import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart'; // Asegúrate de que esta pantalla esté importada

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _codeController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para obtener el nombre del usuario
  Future<String?> _getUserName() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      return userDoc['name']; // Asegúrate de que 'name' exista en la colección 'users'
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fiestas y Discotecas"),
      ),
      body: Column(
        children: [
          // Mostrar lista de eventos desde Firestore
          Expanded(
            child: StreamBuilder(
              stream: _firestore.collection('eventos').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No hay eventos disponibles."));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    return ListTile(
                      title: Text(doc['nombre']),
                      subtitle: Text(doc['ubicacion']),
                      onTap: () {
                        // Autocompletar el código del chat al tocar un evento
                        _codeController.text = doc['codigo_chat'];
                        // Navegar al chat con el código del evento
                        Navigator.pushNamed(
                          context,
                          '/chat',
                          arguments: doc['codigo_chat'], // Pasa el código del chat
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Campo para ingresar código
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: "Código de acceso al chat",
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // Botón para entrar al chat
          ElevatedButton(
            onPressed: () async {
              String codigo = _codeController.text.trim();
              if (codigo.isNotEmpty) {
                String? userName = await _getUserName();
                if (userName != null) {
                  // Al pasar el nombre del usuario, se navega a la pantalla de chat
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        chatId: codigo,
                        userName: userName, // Pasamos el nombre del usuario
                      ),
                    ),
                  );
                } else {
                  // Si el nombre del usuario no está disponible
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("No se pudo obtener el nombre del usuario.")),
                  );
                }
              }
            },
            child: Text("Entrar al chat"),
          ),
        ],
      ),
    );
  }
}



