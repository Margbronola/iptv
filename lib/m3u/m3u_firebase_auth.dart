// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:seizhiptv/m3u/credential_provider.dart';
import 'package:seizhiptv/m3u/m3u_handler.dart';

class M3uFirebaseAuthService {
  M3uFirebaseAuthService._pr();
  static final M3uFirebaseAuthService _instance = M3uFirebaseAuthService._pr();
  static M3uFirebaseAuthService get instance => _instance;
  final M3uFirestoreServices _services = M3uFirestoreServices();

  // Future<User> login
  Future<CredentialProvider?> register(
    String emailAddress,
    String password,
    String url,
  ) async {
    try {
      final UserCredential credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailAddress,
            password: password,
          );
      if (credential.user == null) return null;
      // fireuserId = credential.user!.uid;
      // cacher.setUID(credential.user!.uid);
      final User? user = credential.user;
      if (user == null) return null;
      await _services.addUser(credential.user!.uid, url);
      await _services.createFavoriteXHistory(credential.user!.uid);
      return CredentialProvider(user: user, url: url);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Fluttertoast.showToast(msg: "Password provided is too weak");
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        Fluttertoast.showToast(msg: "The account provided is already existing");
      } else {
        Fluttertoast.showToast(
          msg: "An undefined authentication error has occurred.",
        );
      }

      return null;
    } catch (e) {
      print("ERROR IN REGISTER ACCOUNT: $e");
      Fluttertoast.showToast(msg: "An error has occurred while processing");
      return null;
    }
  }

  Future<bool> forgotPassword(String emailAddress) async {
    try {
      final credential = await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailAddress,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('User not found');
        Fluttertoast.showToast(msg: "User not found");
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        Fluttertoast.showToast(msg: "Incorrect password");
      }
      return false;
    } catch (e) {
      print(e);
      Fluttertoast.showToast(msg: "An error has occurred while processing");
      return false;
    }
  }

  Future<CredentialProvider?> login(
    String emailAddress,
    String password,
  ) async {
    try {
      print("LOGIN USING FIREBASE");
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: "test1@gmail.com",
        password: "123123123",
      );
      var token = await credential.user!.getIdToken();

      print("LOGIN TOKEN: $token");
      final User? user = credential.user;
      if (user == null) return null;
      // fireuserId = credential.user!.uid;
      // cacher.setUID(credential.user!.uid);
      String? url = await _services.getUrl(user.uid);
      if (url == null) return null;
      return CredentialProvider(url: url, user: user);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('User not found');
        Fluttertoast.showToast(msg: "User not found");
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        Fluttertoast.showToast(msg: "Incorrect password");
      }
      return null;
    } catch (e, s) {
      print("ERROR ON LOGIN: $e");
      print("STACK TRACE: $s");
      Fluttertoast.showToast(msg: "An error has occurred while processing");
      return null;
    }
  }

  Future<bool> deleteAccount({User? current}) async {
    try {
      if (current == null) {
        final FirebaseAuth auth = FirebaseAuth.instance;
        if (auth.currentUser == null) {
          Fluttertoast.showToast(msg: "No logged user found!");
          return false;
        }
        await auth.currentUser!.delete();
        Fluttertoast.showToast(msg: "Account deleted!");
        return true;
      }
      await current.delete();
      Fluttertoast.showToast(msg: "Account deleted!");
      return true;
    } catch (e) {
      return false;
    }
  }

  Future signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
