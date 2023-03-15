import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/services/database_services.dart';
import 'package:flutter_chat/widgets/maindrawer.dart';
import 'package:flutter_chat/widgets/widget.dart';
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
        drawer: const MyDrawer(),
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text('Profile'),
        ),
        body: Padding(
            padding: const EdgeInsets.all(20),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              const SizedBox(
                height: 30,
              ),
              Stack(
                children: [
                  // if (imageUrl != null)
                  (imageUrl != '' && image == null)
                      ? CircleAvatar(
                          maxRadius: 50,
                          backgroundImage: NetworkImage(imageUrl!),
                        )
                      : image == null && imageUrl == ''
                          ? const CircleAvatar(
                              maxRadius: 50,
                              backgroundImage:
                                  AssetImage('asset/icons/user.png'),
                            )
                          : CircleAvatar(
                              maxRadius: 50,
                              backgroundImage: MemoryImage(image!),
                            ),

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
              Form(
                // key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      initialValue: email,
                      readOnly: true,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'email cannot be empty';
                        } else if (!value.contains('@')) {
                          return '@ is missing';
                        } else if (!value.endsWith('.com')) {
                          return '.com is missing';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        // _email = value;
                      },
                      decoration: inputDecoration.copyWith(
                        hintText: 'Email',
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                        initialValue: name,
                        keyboardType: TextInputType.text,
                        readOnly: true,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Field can not be null';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          // _fullName = value;
                        },
                        decoration: inputDecoration.copyWith(
                          hintText: 'Name',
                        )),
                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      width: 300,
                      height: 60,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                          onPressed: () {
                            setState(() {
                              FirebaseAuth.instance.signOut();
                            });
                          },
                          child: const Text(
                            'LogOut',
                            style: TextStyle(fontSize: 15),
                          )),
                    )
                  ],
                ),
              )
            ])));
  }
}
