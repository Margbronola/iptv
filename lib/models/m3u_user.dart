import 'package:seizhiptv/m3u/credential_provider.dart';

class M3uUser {
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String uid;
  const M3uUser({
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.uid,
  });
  factory M3uUser.fromProvider(CredentialProvider provider) => M3uUser(
    // factory M3uUser.fromProvider(UserCredential provider) => M3uUser(
    uid: provider.user.uid,
    displayName: provider.user.displayName,
    email: provider.user.email,
    photoUrl: provider.user.photoURL,
  );
  Map<String, dynamic> toJson() => {
    "uid": uid,
    "displayName": displayName,
    "email": email,
    "photoUrl": photoUrl,
  };
  @override
  String toString() => "${toJson()}";
}
