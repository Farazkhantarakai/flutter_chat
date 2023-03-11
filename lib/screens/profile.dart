import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/screens/home_page.dart';
import 'package:flutter_chat/services/database_services.dart';
import 'package:image_picker/image_picker.dart';

class Profile extends StatefulWidget {
  const Profile({
    super.key,
  });

  static const routName = 'Profile';

  // final String email;
  // final String name;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Uint8List? image;
  String? imageUrl;
  bool isLoading = true;
  void pickImage() async {
    final picker = ImagePicker();
    XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedImage == null) return null;
    final bytes = await pickedImage.readAsBytes();
    setState(() {
      image = Uint8List.view(bytes.buffer);
    });
    String imageUrl =
        await DatabaseServices(uId: FirebaseAuth.instance.currentUser!.uid)
            .uploadImage(image!);
    await DatabaseServices(uId: FirebaseAuth.instance.currentUser!.uid)
        .uploadProfile(imageUrl);
  }

  @override
  void initState() {
    getProfile();
    super.initState();
  }

  getProfile() async {
    if (kDebugMode) {
      print('i am called');
    }
    DatabaseServices(uId: FirebaseAuth.instance.currentUser!.uid)
        .getProfilePic()
        .then((value) {
      setState(() {
        isLoading = true;
        imageUrl = value['profilePic'];
        if (kDebugMode) {
          print(imageUrl);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var data =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    String email = data['email'];
    String name = data['name'];

    return Scaffold(
        drawer: Drawer(
            child: Padding(
                padding: const EdgeInsets.all(20),
                child: ListView(
                  children: [
                    Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.pushNamed(context, Profile.routName,
                              arguments: {'email': email, 'name': name});
                        },
                        leading: const Icon(
                          Icons.person,
                          color: Colors.deepOrange,
                        ),
                        title: const Text('Profile'),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const HomePage();
                          }));
                        },
                        leading: const Icon(
                          Icons.group,
                          color: Colors.deepOrange,
                        ),
                        title: const Text('Group'),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: ((context) {
                                return AlertDialog(
                                  title: const Text('Exit'),
                                  content: const Text('Are you Sure'),
                                  actions: [
                                    IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                          Icons.check,
                                          color: Colors.deepOrange,
                                        )),
                                    IconButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        icon: const Icon(
                                          Icons.dangerous,
                                          color: Colors.deepOrange,
                                        ))
                                  ],
                                );
                              }));
                        },
                        leading: const Icon(
                          Icons.exit_to_app,
                          color: Colors.deepOrange,
                        ),
                        title: const Text('Exit'),
                      ),
                    )
                  ],
                ))),
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text('Profile'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 30,
              ),
              Stack(
                children: [
                  // if (imageUrl != null)
                  (imageUrl != null && image == null)
                      ? CircleAvatar(
                          maxRadius: 50,
                          backgroundImage: NetworkImage(imageUrl!),
                        )
                      : image == null
                          ? const CircleAvatar(
                              maxRadius: 50,
                              backgroundImage:
                                  AssetImage('asset/icons/user.png'),
                            )
                          : CircleAvatar(
                              maxRadius: 50,
                              backgroundImage: MemoryImage(image!),
                            ),
                  // : image == null const CircleAvatar(
                  //   maxRadius: 50,
                  //   backgroundImage:AssetImage('asset/icons/user.png'),
                  // ) :
                  // ,
                  // image != null
                  //     ? CircleAvatar(
                  //         maxRadius: 50,
                  //         backgroundImage: MemoryImage(image!),
                  //       )
                  //     : const CircleAvatar(
                  //         maxRadius: 50,
                  //         backgroundImage: AssetImage('asset/icons/user.png'),
                  //       ),

                  Positioned(
                      right: -10,
                      bottom: -10,
                      child: IconButton(
                        onPressed: pickImage,
                        icon: const Icon(Icons.add_a_photo),
                      ))
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Email',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                  ),
                  Text(
                    email,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Name',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                  ),
                  Text(
                    name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
