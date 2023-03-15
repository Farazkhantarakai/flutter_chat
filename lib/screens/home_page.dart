import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/provider/settingtheme.dart';
import 'package:flutter_chat/helper/helper_function.dart';
import 'package:flutter_chat/screens/profile.dart';
import 'package:flutter_chat/screens/search.dart';
import 'package:flutter_chat/services/database_services.dart';
import 'package:flutter_chat/shared/constants.dart';
import 'package:flutter_chat/widgets/group_tile.dart';
import 'package:flutter_chat/widgets/nowidget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../widgets/maindrawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  static const routeName = 'HomePage';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? name = '';
  String? email = '';
  Stream? groups;
  bool isLoading = false;
  String groupName = '';
  String? imageUrl = '';
  @override
  void initState() {
    getData();

    super.initState();
  }

  getData() async {
    await DatabaseServices(uId: FirebaseAuth.instance.currentUser!.uid)
        .getUsersGroups()
        .then((snapshot) {
      setState(() {
        groups = snapshot;
      });
    });
    await DatabaseServices(uId: FirebaseAuth.instance.currentUser!.uid)
        .getProfilePic();

    await DatabaseServices(uId: FirebaseAuth.instance.currentUser!.uid)
        .getName()
        .then((value) {
      setState(() {
        name = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            popUpDialogue(context);
          },
          child: const Icon(Icons.add),
        ),
        drawer: const MyDrawer(
            // name: name!,
            // email: email!,
            ),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text('Groups'),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: ((context) => Search())));
                },
                icon: const Icon(Icons.search))
          ],
        ),
        body: groupList());
  }

  popUpDialogue(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                title: Text(
                  'Create Group',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    isLoading == false
                        ? TextFormField(
                            cursorColor: Theme.of(context).primaryColor,
                            onChanged: (value) {
                              setState(() {
                                groupName = value;
                              });
                            },
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                        width: 3),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20))),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                        width: 3),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20)))),
                          )
                        : CircularProgressIndicator(
                            color: Theme.of(context).primaryColor,
                          ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).primaryColor),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Discard')),
                        const SizedBox(
                          width: 10,
                        ),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).primaryColor),
                            onPressed: () async {
                              if (groupName.isNotEmpty) {
                                setState(() {
                                  isLoading = true;
                                });
                                await DatabaseServices(
                                        uId: FirebaseAuth
                                            .instance.currentUser!.uid)
                                    .creatGroups(
                                        name!.trim(),
                                        FirebaseAuth.instance.currentUser!.uid,
                                        groupName.trim())
                                    .whenComplete(() {
                                  setState(() {
                                    isLoading = false;
                                  });
                                });
                                Fluttertoast.showToast(
                                    msg: 'Groups Created Succefully',
                                    backgroundColor: Constants.primaryColor);
                                // ignore: use_build_context_synchronously
                                Navigator.pop(context);
                              }
                            },
                            child: const Text('create'))
                      ],
                    )
                  ],
                ));
          });
        });
  }

  getId(String res) {
    return res.substring(0, res.indexOf('_'));
  }

  getName(String res) {
    return res.substring(res.indexOf('_') + 1);
  }

  groupList() {
    return StreamBuilder(
      stream: groups,
      builder: (context, snapshot) {
        print(snapshot);
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(
            color: Constants.primaryColor,
          ));
        }
        // if (!snapshot.hasData) {
        //   return const NoWidget();
        // }
        // make some checks
        if (snapshot.hasData) {
          if (snapshot.data['groups'] != null) {
            if (snapshot.data['groups'].length != 0) {
              return ListView.builder(
                itemCount: snapshot.data['groups'].length,
                itemBuilder: (context, index) {
                  int reverseIndex = snapshot.data['groups'].length - index - 1;

                  return GroupTile(
                    userName: snapshot.data['fullName'],
                    groupName: getName(snapshot.data['groups'][reverseIndex]),
                    groupId: getId(snapshot.data['groups'][reverseIndex]),
                  );
                },
              );
            } else {
              return const NoWidget();
            }
          } else {
            return const NoWidget();
          }
        } else {
          return const NoWidget();
        }
      },
    );
  }
}
