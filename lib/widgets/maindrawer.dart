import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/provider/settingtheme.dart';
import 'package:flutter_chat/screens/home_page.dart';
import 'package:flutter_chat/screens/profile.dart';
import 'package:flutter_chat/services/database_services.dart';
import 'package:provider/provider.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({
    super.key,
    // required this.name, required this.email
  });

  // final String name;
  // final String email;

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  String imageUrl = '';
  bool isLoading = false;
  String name = '';
  String email = '';
  @override
  void initState() {
    getProfile();
    super.initState();
  }

  getProfile() async {
    if (kDebugMode) {
      print('i am called');
    }
    isLoading = true;
    DatabaseServices(uId: FirebaseAuth.instance.currentUser!.uid)
        .getProfilePic()
        .then((value) {
      setState(() {
        isLoading = false;
        imageUrl = value['profilePic'];
        name = value['fullName'];
        email = value['email'];
        if (kDebugMode) {
          print(imageUrl);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var changTheme = Provider.of<ChangeTheme>(context);
    return Drawer(
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    : imageUrl == ''
                        ? const CircleAvatar(
                            maxRadius: 50,
                            child: Icon(
                              Icons.person,
                              size: 50,
                            ),
                          )
                        : CircleAvatar(
                            maxRadius: 50,
                            backgroundImage: NetworkImage(imageUrl, scale: 100),
                          ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),

                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      email,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                ),

                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    changTheme.getTheme
                        ? Text('Light Mode',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor))
                        : Text('Dark Mode',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor)),
                    const SizedBox(
                      width: 20,
                    ),
                    IconButton(
                        onPressed: () {
                          changTheme.doDark();
                        },
                        icon: changTheme.getTheme
                            ? const Icon(
                                Icons.light_mode,
                                color: Colors.white,
                              )
                            : const Icon(Icons.dark_mode, color: Colors.black)),
                  ],
                ),

                ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, Profile.routName,
                        arguments: {'email': email, 'name': name});
                  },
                  leading: Icon(
                    Icons.person,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: const Text('Profile'),
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const HomePage();
                    }));
                  },
                  leading: Icon(
                    Icons.group,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: const Text('Group'),
                ),
                // SwitchListTile(
                //     title:
                //         ? const Text('Change to Light Mode')
                //         : const Text('Change to Dark Mode'),
                //     value: changTheme.getTheme,
                //     activeColor: Theme.of(context).primaryColor,
                //     onChanged: (val) {

                //     }),
                ListTile(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: ((context) {
                          return AlertDialog(
                            title: const Text('Exit'),
                            content: const Text('Are you Sure'),
                            actions: [
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      FirebaseAuth.instance.signOut();
                                      Navigator.pop(context);
                                    });
                                  },
                                  icon: Icon(
                                    Icons.check,
                                    color: Theme.of(context).primaryColor,
                                  )),
                              IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(
                                    Icons.dangerous,
                                    color: Theme.of(context).primaryColor,
                                  ))
                            ],
                          );
                        }));
                  },
                  leading: Icon(
                    Icons.exit_to_app,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: const Text('Exit'),
                )
              ],
            )));
  }
}
