import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/helper/helper_function.dart';
import 'package:flutter_chat/screens/chat_page.dart';
import 'package:flutter_chat/services/database_services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Search extends StatefulWidget {
  Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController _searchController = TextEditingController();

  bool isLoading = false;
  QuerySnapshot? _searchSnapshot;
  bool hasUserSearched = false;
  String userName = '';
  bool isJoined = false;
  User? user;
  @override
  void initState() {
    getCurrentUserAndId();
    super.initState();
  }

  getCurrentUserAndId() async {
    await HelperFunction.getUserName().then((value) {
      setState(() {
        userName = value!;
      });
    });
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Search'),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                  controller: _searchController,
                  cursorColor: Colors.white,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(10),
                      border: InputBorder.none,
                      hintText: 'Search group...',
                      hintStyle: TextStyle(color: Colors.white)),
                )),
                GestureDetector(
                  onTap: () {
                    initiateSearchMethod();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : groupList()
        ],
      ),
    );
  }

  groupList() {
    return hasUserSearched
        ? Expanded(
            child: ListView.builder(
                itemCount: _searchSnapshot!.docs.length,
                itemBuilder: (context, index) {
                  return searchGroupTile(
                    userName,
                    _searchSnapshot!.docs[index]['groupId'],
                    _searchSnapshot!.docs[index]['groupName'],
                    _searchSnapshot!.docs[index]['admin'],
                  );
                }),
          )
        : Container();
  }

  getName(String res) {
    return res.substring(res.indexOf('_') + 1);
  }

  isJoinedOrNot(
      String userName, String groupId, String groupName, String admin) async {
    DatabaseServices(uId: FirebaseAuth.instance.currentUser!.uid)
        .isJoinedOrNot(groupId, groupName, admin)
        .then((snapshot) {
      setState(() {
        isJoined = snapshot;
      });
    });
  }

  Widget searchGroupTile(
      String userName, String groupId, String groupName, String admin) {
    isJoinedOrNot(userName, groupId, groupName, admin);
    return ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            groupName.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(groupName,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text("Admin: ${getName(admin)}"),
        trailing: GestureDetector(
          onTap: () async {
            print(isJoined);
            await DatabaseServices(uId: user!.uid)
                .toggleGroupJoin(groupId, userName, groupName);
            if (isJoined) {
              setState(() {
                isJoined = !isJoined;
              });
              Fluttertoast.showToast(
                  msg: 'Group Joined Succefully',
                  backgroundColor: Colors.green);
              Future.delayed(const Duration(seconds: 2), () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return ChatPage(
                      groupId: groupId,
                      groupName: groupName,
                      userName: userName);
                }));
              });
            } else {
              setState(() {
                isJoined = !isJoined;
                Fluttertoast.showToast(
                    msg: 'left the group succefully',
                    backgroundColor: Colors.red);
              });
            }
          },
          child: isJoined
              ? Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: const Text(
                    "Joined",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).primaryColor,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: const Text("Join Now",
                      style: TextStyle(color: Colors.white)),
                ),
        ));
  }

  initiateSearchMethod() async {
    if (_searchController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      DatabaseServices(uId: FirebaseAuth.instance.currentUser!.uid)
          .searchByName(_searchController.text.trim())
          .then((snapshot) {
        setState(() {
          isLoading = false;
          _searchSnapshot = snapshot;
          if (kDebugMode) {
            print(_searchSnapshot!.docs);
          }
          hasUserSearched = true;
        });
      });
    }
  }
}
