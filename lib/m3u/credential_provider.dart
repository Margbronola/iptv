import 'package:firebase_auth/firebase_auth.dart';

///[user] is from firebase
///it contains firebase data
///including email, id, and some functions
///[url] is the provided ul for the user
///upon registration.
class CredentialProvider {
  final User user;
  final String url;
  const CredentialProvider({required this.user, required this.url});
}
