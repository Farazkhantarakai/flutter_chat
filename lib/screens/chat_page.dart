import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/provider/change.dart';
import 'package:flutter_chat/services/database_services.dart';
import 'package:flutter_chat/widgets/chat_tile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../screens/info_page.dart';
import 'package:uuid/uuid.dart';
import './videoconference.dart';

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

  final scrollController = ScrollController();
  Uint8List? image;

  @override
  void initState() {
    getGroupAdmin();
    getingChats();

    // SchedulerBinding.instance.addPostFrameCallback((_) {
    //   jumptoLast();
    // });
    super.initState();
  }

  @override
  didChangeDependencies() {
    // FocusScope.of(context).unfocus();
    super.didChangeDependencies();
  }

  jumptoLast() {
    if (scrollController.hasClients) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    }
  }

  @override
  dispose() {
    scrollController.dispose();
    super.dispose();
  }

  getingChats() async {
    await DatabaseServices(uId: FirebaseAuth.instance.currentUser!.uid)
        .getChats(widget.groupId!)
        .then((snapshot) {
      setState(() {
        chat = snapshot;
        if (kDebugMode) {
          print(chat);
        }
      });
    });
  }

  pickImage() async {
    XFile? pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 5,
    );
    if (pickedImage == null) return null;
    final bytes = await pickedImage.readAsBytes();
    setState(() {
      image = Uint8List.view(bytes.buffer);
    });
  }

  getGroupAdmin() async {
    DatabaseServices(uId: FirebaseAuth.instance.currentUser!.uid)
        .getGroupAdmin(widget.groupId!)
        .then((value) => admin = value);
  }

  @override
  Widget build(BuildContext context) {
    var change = Provider.of<Change>(context);
    return WillPopScope(
      onWillPop: () async {
        if (change.getIsItemSelected) {
          change.changFalseItemSelected();
          change.doFalseValue();
          change.removeMessageItem();
          return false;
        }

        return true;
      },
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text('${widget.groupName}'),
            actions: [
              change.getChange == false || change.getMessageIds.isEmpty
                  ? IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, VideoConference.routName,
                            arguments: {
                              'groupId': widget.groupId,
                              'groupName': widget.groupName,
                              'userName': widget.userName,
                              'userId': FirebaseAuth.instance.currentUser!.uid,
                            });
                      },
                      icon: const Icon(
                        Icons.video_call,
                        color: Colors.white,
                      ))
                  : Container(),
              change.getChange == false || change.getMessageIds.isEmpty
                  ? IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.phone,
                        color: Colors.white,
                      ))
                  : IconButton(
                      onPressed: () {
                        change.deleteItems(widget.groupId!).then((_) {
                          change.doFalseValue();
                        });
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      )),
              IconButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
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
                      decoration: InputDecoration(
                        suffixIcon: GestureDetector(
                          onTap: pickImage,
                          child: const Icon(
                            Icons.image,
                            color: Colors.white,
                          ),
                        ),
                        hintText: "Send a message...",
                        hintStyle:
                            const TextStyle(color: Colors.white, fontSize: 16),
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
          ))),
    );
  }

  chatMessage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // scrollController.animateTo(
      //   scrollController.position.maxScrollExtent,
      //   duration: const Duration(milliseconds: 1),
      //   curve: Curves.easeOut,
      // );
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });

    return StreamBuilder(
        stream: chat,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  controller: scrollController,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return ChatTile(
                        messageId: snapshot.data!.docs[index]['messageId'],
                        message: snapshot.data!.docs[index]['message'],
                        senderName: snapshot.data!.docs[index]['sendername'],
                        imageUrl: snapshot.data!.docs[index]['imageUrl'] ?? "",
                        sentByMe: snapshot.data!.docs[index]['senderId']
                                .toString() ==
                            FirebaseAuth.instance.currentUser!.uid.toString());
                  })
              : Container();
        });
  }

  sendMessage() async {
    Map<String, dynamic> chatMessage = {
      'messageId': const Uuid().v4(),
      "message": messageController.text.trim(),
      'senderName': widget.userName,
      "senderId": FirebaseAuth.instance.currentUser!.uid,
      'time': DateTime.now().millisecondsSinceEpoch
    };
    FocusScope.of(context).unfocus();
    if (image != null) {
      await DatabaseServices(uId: FirebaseAuth.instance.currentUser!.uid)
          .sendMessage(
              groupId: widget.groupId!,
              message: messageController.text.trim(),
              messageId: const Uuid().v4(),
              senderName: widget.userName!,
              senderId: FirebaseAuth.instance.currentUser!.uid,
              time: DateTime.now().microsecondsSinceEpoch,
              image: image!);
    } else {
      await DatabaseServices(uId: FirebaseAuth.instance.currentUser!.uid)
          .sendMessage(
        groupId: widget.groupId!,
        message: messageController.text.trim(),
        messageId: const Uuid().v4(),
        senderName: widget.userName!,
        senderId: FirebaseAuth.instance.currentUser!.uid,
        time: DateTime.now().microsecondsSinceEpoch,
      );
    }
    image = null;
    setState(() {
      messageController.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 1),
        curve: Curves.easeOut,
      );
    });
  }
}
