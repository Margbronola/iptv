import 'dart:io';
import 'package:seizhiptv/globals/data.dart';
import 'package:seizhiptv/models/m3u_user.dart';
import 'package:seizhiptv/services/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataCacher {
  DataCacher._private();
  static final DataCacher _instance = DataCacher._private();
  static final GoogleSignInService _google = GoogleSignInService.instance;
  static DataCacher get instance => _instance;
  static late final SharedPreferences sharedPreferences;
  // final Favorites _favVm = Favorites.instance;
  // final History _hisVm = History.instance;
  Future<void> saveLoginType(int i) async =>
      await sharedPreferences.setInt("login-type", i);
  Future<void> saveDate(String data) async =>
      await sharedPreferences.setString("date", data);
  Future<void> removeData() async => await sharedPreferences.remove("date");
  DateTime? get date {
    final String? d = sharedPreferences.getString("date");
    if (d == null) return null;
    return DateTime.parse(d);
  }

  Future<void> removeLoginType() async =>
      await sharedPreferences.remove("login-type");
  int? get savedLoginType => sharedPreferences.getInt("login-type");
  Future<void> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  Future<void> saveFile(File file) async =>
      await sharedPreferences.setString("file", file.path);
  String? get filePath => sharedPreferences.getString("file");
  Future<void> removeFile() async => await sharedPreferences.remove('file');

  Future<void> clearData() async {
    // _favVm.dispose();
    // _hisVm.dispose();
    if (savedLoginType == 1) {
      await _google.signOut();
    }
    user = null;
    await Future.wait([
      removePlaylistName(),
      removeRefID(),
      removeUrl(),
      removeFile(),
      removeLoginType(),
      removeSource(),
      removeM3uUser(),
      removePassword(),
    ]);
  }

  Future<void> saveUrl(String url) async =>
      await sharedPreferences.setString("url", url);
  String? get savedUrl => sharedPreferences.getString("url");
  Future<void> removeUrl() async => await sharedPreferences.remove("url");
  Future<bool> removeM3uUser() async =>
      await sharedPreferences.remove("m3u-user");
  Future<void> saveM3uUser(M3uUser user) async {
    await sharedPreferences.setStringList("m3u-user", [
      user.uid,
      user.email ?? "",
      user.displayName ?? "",
      user.photoUrl ?? "",
    ]);
  }

  M3uUser? get m3uUser {
    final List<String>? d = sharedPreferences.getStringList("m3u-user");
    if (d == null) return null;
    return M3uUser(
      displayName: d[2].isEmpty ? null : d[2],
      email: d[1].isEmpty ? null : d[1],
      photoUrl: d[3].isEmpty ? null : d[3],
      uid: d[0],
    );
  }

  /// REFERENCE ID FUNCTIONS
  Future<bool> saveRefID(String ref) async =>
      await sharedPreferences.setString("ref_id", ref);

  String? get refId => sharedPreferences.getString("ref_id");

  Future<bool> removeRefID() async => await sharedPreferences.remove("ref_id");

  /// REFERENCE ID FUNCTIONS
  Future<bool> saveLanguage(String language) async =>
      await sharedPreferences.setString("language", language);

  String? get language => sharedPreferences.getString("language");

  Future<bool> removeLanguage() async =>
      await sharedPreferences.remove("language");

  /// Playlist functions
  Future<bool> savePlaylistName(String n) async =>
      await sharedPreferences.setString("playlist_name", n);

  String? get playlistName => sharedPreferences.getString("playlist_name");

  Future<bool> removePlaylistName() async =>
      await sharedPreferences.remove("playlist_name");

  // /// Exp. Date functions
  // Future<bool> saveExpDate(String date) async =>
  //     await sharedPreferences.setString("exp_date", date);

  // String? get expDate => sharedPreferences.getString("exp_date");

  // Future<bool> removeExpDate() async =>
  //     await sharedPreferences.remove("exp_date");

  Future<bool> saveSource(String source) async =>
      await sharedPreferences.setString("source", source);

  String? get source => sharedPreferences.getString("source");

  Future<bool> removeSource() async => await sharedPreferences.remove("source");

  Future<bool> savePassword(String password) async =>
      await sharedPreferences.setString("password", password);

  String? get password => sharedPreferences.getString("password");

  Future<bool> removePassword() async =>
      await sharedPreferences.remove("password");
}
