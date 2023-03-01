import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/screens/info_page.dart';
import './helper/helper_function.dart';
import './screens/auth/log_in.dart';
import 'package:flutter/foundation.dart';
import './screens/home_page.dart';
import './shared/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: Constants.apiKey,
            appId: Constants.appId,
            messagingSenderId: Constants.messagingSenderId,
            projectId: Constants.projectId));
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isUserLogedIn = false;

  @override
  void initState() {
    super.initState();
    getUserLogedInStatus();
  }

  getUserLogedInStatus() async {
    await HelperFunction.getUserLogedInStatus().then((value) {
      if (kDebugMode) {
        print('loged in value  $value');
      }
      if (value != null) {
        setState(() {
          _isUserLogedIn = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        routes: {
          HomePage.routeName: (context) => const HomePage(),
          LogIn.routName: (context) => const LogIn(),
          Info.routName: (context) => Info(
                adminName: '',
                groupId: '',
                groupName: '',
              )
        },
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primaryColor: Constants.primaryColor,
            scaffoldBackgroundColor: Colors.white),
        home: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(
                  color: Constants.primaryColor,
                );
              } else {
                if (snapshot.hasData) {
                  return const HomePage();
                } else {
                  return const LogIn();
                }
              }
            }));
  }
}
