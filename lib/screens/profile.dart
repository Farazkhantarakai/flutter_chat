import 'package:flutter/material.dart';
import 'package:flutter_chat/screens/home_page.dart';

class Profile extends StatelessWidget {
  const Profile({super.key, required this.email, required this.name});

  final String email;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawer(
            child: Padding(
                padding: const EdgeInsets.all(20),
                child: ListView(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.person,
                          size: 100,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text('Name'),
                        Text(name),
                      ],
                    ),
                    ListTile(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return Profile(email: email, name: name);
                        }));
                      },
                      leading: const Icon(
                        Icons.person,
                        color: Colors.deepOrange,
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
                      leading: const Icon(
                        Icons.group,
                        color: Colors.deepOrange,
                      ),
                      title: const Text('Group'),
                    ),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Center(
                child: Icon(
                  Icons.person,
                  color: Colors.grey,
                  size: 100,
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Email',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    email,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
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
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              // Text(name)
            ],
          ),
        ));
  }
}
