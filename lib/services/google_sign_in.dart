// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:seizhiptv/globals/data.dart';
import 'package:seizhiptv/globals/data_cacher.dart';
import 'package:seizhiptv/m3u/credential_provider.dart';
import 'package:seizhiptv/m3u/m3u_handler.dart';

class GoogleSignInService {
  GoogleSignInService._pr();
  static final GoogleSignInService _instance = GoogleSignInService._pr();
  static GoogleSignInService get instance => _instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final M3uFirestoreServices services = M3uFirestoreServices();
  static final FirebaseAuth auth = FirebaseAuth.instance;
  final DataCacher _cacher = DataCacher.instance;

  Future<void> handleGetContact(GoogleSignInAccount user) async {
    final http.Response response = await http.get(
      Uri.parse(
        'https://people.googleapis.com/v1/people/me/connections'
        '?requestMask.includeField=person.names',
      ),
      headers: await user.authHeaders,
    );
    if (response.statusCode != 200) {
      return;
    }
  }

  Future<void> signOut() async {
    await googleSignIn.signOut();
  }

  Future<CredentialProvider?> signIn() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;
      handleGetContact(googleUser);
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print("GOGGLE AUTH: $googleUser");
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final authResult = await auth.signInWithCredential(credential);
      final firebaseUser = authResult.user;
      print("USER DATA: $firebaseUser");
      refId = firebaseUser!.uid;
      _cacher.saveRefID(refId!);
      await services.addUser(firebaseUser.uid, "");
      await services.createFavoriteXHistory(firebaseUser.uid);
      return CredentialProvider(url: "", user: firebaseUser);
      // return authResult;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Fluttertoast.showToast(msg: "User not found");
      } else if (e.code == 'wrong-password') {
        Fluttertoast.showToast(msg: "Incorrect password");
      } else if (e.code == "account-exists-with-different-credential") {
        Fluttertoast.showToast(
          msg: "Account exists, but with different credentials",
        );
      }
      return null;
    } on SocketException {
      Fluttertoast.showToast(msg: "No Internet Connection");
      return null;
    } on HttpException {
      Fluttertoast.showToast(
        msg: "An error has occured while processing your request",
      );
      return null;
    } on FormatException {
      Fluttertoast.showToast(msg: "Format error: Contact Developer");
      return null;
    } on TimeoutException {
      Fluttertoast.showToast(
        msg: "No Internet Connection : Connection Timeout",
      );
      return null;
    } catch (e) {
      print("ERROR IN GOOGLE SIGN IN: $e");
    }
    return null;
  }
}
