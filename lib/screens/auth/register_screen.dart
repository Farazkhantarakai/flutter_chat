import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/helper/helper_function.dart';
import 'package:flutter_chat/screens/auth/log_in.dart';
import 'package:flutter_chat/screens/home_page.dart';
import 'package:flutter_chat/services/auth_services.dart';
import 'package:flutter_chat/shared/constants.dart';
import 'package:flutter_chat/widgets/widget.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _fullName = '';
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          'Groupie',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const Text('create group to talk with each other'),
                        Image.asset('asset/icons/register.png'),
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
                              prefix: Icon(
                                Icons.email,
                                color: Theme.of(context).primaryColor,
                              )),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Field can not be null';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            _fullName = value;
                          },
                          decoration: inputDecoration.copyWith(
                              label: const Text(
                                'FullName',
                                style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    color: Colors.black),
                              ),
                              prefix: Icon(
                                Icons.email,
                                color: Theme.of(context).primaryColor,
                              )),
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
                              prefix: Icon(
                                Icons.lock,
                                color: Theme.of(context).primaryColor,
                              )),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: signUp,
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).primaryColor),
                            child: const Text('SignUp'),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text.rich(TextSpan(
                            text: 'Already have an Account',
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w300),
                            children: [
                              TextSpan(
                                  text: 'Sign Up now!',
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      nextScreen(context, const LogIn());
                                    })
                            ]))
                      ],
                    )),
              ),
            ),
    ));
  }

  void signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      await AuthServices()
          .registerUserWithEmailAndPassword(_fullName, _email, _password)
          .then((value) async {
        if (value == true) {
          //save the value through sharedPreferences
          await HelperFunction.saveUserLoggedInStatus(true);
          await HelperFunction.saveUserEmailSf(_email);
          await HelperFunction.saveUserNameSf(_fullName);
          Fluttertoast.showToast(
              msg: 'Account Created Succefully',
              backgroundColor: Constants.primaryColor);
          setState(() {
            _isLoading = false;
          });
        } else {
          showSnackBar(context, Colors.red, value);
          setState(() {
            _isLoading = false;
          });
        }
      }).catchError((onError) {
        showYourDialog(context, 'Error', onError);
        setState(() {
          _isLoading = false;
        });
      });
    }
  }
}
