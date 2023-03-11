import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/helper/helper_function.dart';
import 'package:flutter_chat/screens/auth/register_screen.dart';
import 'package:flutter_chat/screens/home_page.dart';
import 'package:flutter_chat/services/auth_services.dart';
import 'package:flutter_chat/services/database_services.dart';
import 'package:flutter_chat/widgets/widget.dart';

class LogIn extends StatefulWidget {
  const LogIn({Key? key}) : super(key: key);

  static const routName = 'logIn';

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool? isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: isLoading!
            ? Center(
                child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ))
            : SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 30),
                    child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const SizedBox(
                              height: 30,
                            ),
                            const Text(
                              'Talkie',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const Text('create group to talk with each other'),
                            Image.asset('asset/icons/login.jpg'),
                            TextFormField(
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
                                _email = value;
                              },
                              decoration: inputDecoration.copyWith(
                                label: const Text(
                                  'Email',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            TextFormField(
                              obscureText: true,
                              validator: (value) {
                                if (value!.length < 6) {
                                  return 'value cannot be less than six  characters';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                _password = value;
                              },
                              decoration: inputDecoration.copyWith(
                                label: const Text(
                                  'Password',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w300),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  // setState(() {
                                  //   isLoading = true;
                                  // });

                                  if (_formKey.currentState!.validate()) {
                                    AuthServices authServices = AuthServices();

                                    setState(() {
                                      isLoading = true;
                                    });
                                    await authServices
                                        .logInUserWithEmailAndPassword(
                                            _email, _password)
                                        .then((value) async {
                                      if (value == true) {
                                        QuerySnapshot snapshot =
                                            await DatabaseServices(
                                                    uId: FirebaseAuth.instance
                                                        .currentUser!.uid)
                                                .gettingUserData(_email);
                                        if (kDebugMode) {
                                          print(snapshot.toString());
                                        }
                                        // saving the values to our shared preferences
                                        await HelperFunction
                                            .saveUserLoggedInStatus(true);
                                        await HelperFunction.saveUserEmailSf(
                                            _email);
                                        await HelperFunction.saveUserNameSf(
                                            snapshot.docs[0]['fullName']);

                                        // ignore: use_build_context_synchronously
                                        Navigator.pushAndRemoveUntil(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return const HomePage();
                                        }), (route) => false);
                                      } else {
                                        showSnackBar(
                                            context, Colors.red, value);
                                        setState(() {
                                          isLoading = false;
                                        });
                                      }
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).primaryColor),
                                child: const Text('LogIn'),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text.rich(TextSpan(
                                text: 'Donot have an account',
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w300),
                                children: [
                                  TextSpan(
                                      text: 'Register now!',
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          nextScreen(
                                              context, const RegisterScreen());
                                        })
                                ]))
                          ],
                        )),
                  ),
                ),
              ));
  }
}
