import 'package:firebase_auth/firebase_auth.dart';
import '../helper/helper_function.dart';
import '../services/database_services.dart';

class AuthServices {
  //this will create an object of firebase authentication
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future registerUserWithEmailAndPassword(
      String fullName, String email, String password) async {
//here we will create a new user with email and password

    try {
      User user = (await firebaseAuth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user!;
      if (user != null) {
        DatabaseServices(uId: user.uid).updateUserData(fullName, email);
        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future logInUserWithEmailAndPassword(String email, String password) async {
    try {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      User user = (await firebaseAuth.signInWithEmailAndPassword(
              email: email, password: password))
          .user!;
      if (user != null) {
        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future logOut() async {
    try {
      await HelperFunction.saveUserEmailSf('');
      await HelperFunction.saveUserLoggedInStatus(false);
      await HelperFunction.saveUserNameSf('');
      await firebaseAuth.signOut();
    } catch (er) {
      return null;
    }
  }
}

/*
these exceptions can be thrown if something goes wrong
email-already-in-use:
Thrown if there already exists an account with the given email address.
invalid-email:
Thrown if the email address is not valid.
operation-not-allowed:
Thrown if email/password accounts are not enabled. Enable email/password accounts in the Firebase Console, under the Auth tab.
weak-password:
Thrown if the password is not strong enough.

*/