import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat/provider/change.dart';
import 'package:flutter_chat/provider/settingtheme.dart';
import 'package:flutter_chat/screens/info_page.dart';
import 'package:flutter_chat/screens/profile.dart';
import './screens/auth/log_in.dart';
import 'package:flutter/foundation.dart';
import './screens/home_page.dart';
import './shared/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import './screens/videoconference.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    // Map<String, dynamic> firebaseConfig = {
    //   "apiKey": "AIzaSyBaWT4P_AuJSWn-aeR6l6IdVk1BmomzjPw",
    //   "authDomain": "fir-chat-f9085.firebaseapp.com",
    //   "projectId": "fir-chat-f9085",
    //   "storageBucket": "fir-chat-f9085.appspot.com",
    //   "messagingSenderId": "57293197254",
    //   "appId": "1:57293197254:web:e0251f1c261c3b363b6cc7",
    //   "measurementId": "G-ET9F6VMP11"
    // };

    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: Constants.apiKey,
            appId: Constants.appId,
            messagingSenderId: Constants.messagingSenderId,
            storageBucket: Constants.storageBucket,
            measurementId: Constants.measurementId,
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
  // bool _isUserLogedIn = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) {
          return ChangeTheme();
        }),
        ChangeNotifierProvider(create: (context) {
          return Change();
        }),
      ],
      child: Consumer<ChangeTheme>(
        builder: (context, change, child) {
          return MaterialApp(
              routes: {
                HomePage.routeName: (context) => const HomePage(),
                LogIn.routName: (context) => const LogIn(),
                Profile.routName: (context) => const Profile(),
                VideoConference.routName: (context) => VideoConference(),
                Info.routName: (context) => Info(
                      adminName: '',
                      groupId: '',
                      groupName: '',
                    )
              },
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                  primaryColor: Constants.primaryColor,
                  appBarTheme: const AppBarTheme(
                      iconTheme: IconThemeData(color: Colors.white),
                      systemOverlayStyle: SystemUiOverlayStyle(
                          statusBarIconBrightness: Brightness.light)),
                  brightness:
                      change.getTheme ? Brightness.dark : Brightness.light),
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
        },
      ),
    );
  }
}
