import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/services/database_services.dart';
import 'package:flutter_chat/widgets/chat_tile.dart';
import '../screens/info_page.dart';

class ChatPage extends StatefulWidget {
  ChatPage(
      {super.key,
      required this.groupId,
      required this.groupName,
      required this.userName});

  static const routName = 'chatpage';
  String? groupId;

  String? userName;

  String? groupName;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String? admin = '';
  TextEditingController messageController = TextEditingController();
  Stream<QuerySnapshot>? chat;

  @override
  void initState() {
    getGroupAdmin();
    getingChats();
    super.initState();
  }

  getingChats() async {
    await DatabaseServices(uId: FirebaseAuth.instance.currentUser!.uid)
        .getChats(widget.groupId!)
        .then((snapshot) {
      setState(() {
        chat = snapshot;
        print(chat);
      });
    });
  }

  getGroupAdmin() async {
    DatabaseServices(uId: FirebaseAuth.instance.currentUser!.uid)
        .getGroupAdmin(widget.groupId!)
        .then((value) => admin = value);
  }

  @override
  Widget build(BuildContext context) {
    // var data =
    //     ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    // final mdq = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Text('${widget.groupName}'),
          actions: [
            IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.video_call,
                  color: Colors.white,
                )),
            IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.phone,
                  color: Colors.white,
                )),
            IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return Info(
                        groupName: widget.groupName!,
                        groupId: widget.groupId!,
                        adminName: admin!);
                  }));
                },
                icon: const Icon(
                  Icons.info,
                  color: Colors.white,
                ))
          ],
        ),
        body: SafeArea(
            child: Stack(
          children: [
            // chat message
            chatMessage(),
            Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                width: MediaQuery.of(context).size.width,
                color: Colors.grey[700],
                child: Row(children: [
                  Expanded(
                      child: TextFormField(
                    controller: messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      suffixIcon: Icon(
                        Icons.image,
                        color: Colors.white,
                      ),
                      hintText: "Send a message...",
                      hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                      border: InputBorder.none,
                    ),
                  )),
                  const SizedBox(
                    width: 12,
                  ),
                  GestureDetector(
                    onTap: () {
                      sendMessage();
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                          child: Icon(
                        Icons.send,
                        color: Colors.white,
                      )),
                    ),
                  )
                ]),
              ),
            )
          ],
        )));
  }

  chatMessage() {
    return StreamBuilder(
        stream: chat,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return ChatTile(
                        message: snapshot.data!.docs[index]['message'],
                        senderName: snapshot.data!.docs[index]['senderName'],
                        sentByMe: snapshot.data!.docs[index]['senderId']
                                .toString() ==
                            FirebaseAuth.instance.currentUser!.uid.toString());
                  })
              : Container();
        });
  }

  sendMessage() async {
    Map<String, dynamic> chatMessage = {
      "message": messageController.text.trim(),
      'senderName': widget.userName,
      "senderId": FirebaseAuth.instance.currentUser!.uid,
      'time': DateTime.now().millisecondsSinceEpoch
    };

    await DatabaseServices(uId: FirebaseAuth.instance.currentUser!.uid)
        .sendMessage(widget.groupId, chatMessage);
    setState(() {
      messageController.clear();
    });
  }
}
