import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  final String chatId; // ID del chat para identificar cuál es el chat en Firestore
  final String userName; // Recibe el nombre del usuario

  const ChatScreen({super.key, required this.chatId, required this.userName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Método para enviar el mensaje al chat
  void _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
        'usuario': widget.userName, // Usa el nombre real del usuario
        'mensaje': _messageController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
      _scrollToBottom();
    }
  }

  // Método para desplazarse al final del chat (mostrar los últimos mensajes)
  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  // Método para reportar un mensaje
  void _reportMessage(String messageId) {
    FirebaseFirestore.instance.collection('reported_messages').add({
      'messageId': messageId,
      'reportedAt': FieldValue.serverTimestamp(),
      'reportedBy': widget.userName,
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Mensaje reportado"),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat en Vivo")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No hay mensajes aún."));
                }

                return ListView(
                  reverse: true, // Para que los mensajes más recientes estén abajo
                  controller: _scrollController,
                  children: snapshot.data!.docs.map((doc) {
                    return ListTile(
                      title: Text(doc['usuario']), // Muestra el nombre del usuario
                      subtitle: Text(doc['mensaje']),
                      trailing: IconButton(
                        icon: Icon(Icons.report),
                        onPressed: () => _reportMessage(doc.id), // Reportar el mensaje
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),

          // Campo de texto y botón de enviar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Escribe un mensaje...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}




