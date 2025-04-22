import 'package:seizhiptv/m3u/db.regex.dart';
import 'package:seizhiptv/m3u/entry_info.dart';
import 'package:seizhiptv/m3u/m3u_handler.dart';

class M3uEntry {
  static final DBRegX _regX = DBRegX();
  static final M3uFirestoreServices _fserve = M3uFirestoreServices();
  M3uEntry({
    required this.title,
    required this.attributes,
    required this.link,
    required this.duration,
    required this.type,
  });

  ///refId is representation of userId
  Future<void> addToFavorites(String refId) async {
    await _fserve.appendDataIn(
      this,
      collection: "user-favorites",
      refId: refId,
    );
  }

  Future<void> removeFromFavorites(String refId) async {
    await _fserve.removeDataIn(
      this,
      collection: "user-favorites",
      refId: refId,
    );
  }

  Future<void> addToHistory(String refId) async {
    await _fserve.appendDataIn(this, collection: "user-history", refId: refId);
  }

  Future<void> removeFromHistory(String refId) async {
    await _fserve.removeDataIn(this, collection: "user-history", refId: refId);
  }

  factory M3uEntry.fromFirestore(Map<String, dynamic> json, int type) {
    return M3uEntry(
      title: json['name'],
      attributes: json['attributes'],
      link: json['url'],
      duration: json['duration'].toInt(),
      type: type,
    );
  }
  factory M3uEntry.fromEntryInformation({
    required EntryInfo information,
    required String link,
    int type = 0,
  }) => M3uEntry(
    title: information.title,
    duration: information.duration,
    attributes:
        information.attributes..addAll({
          "title-clean":
              information.title
                  .replaceAll(_regX.season, "")
                  .replaceAll(_regX.episode, "")
                  .replaceAll(_regX.epAndSe, "")
                  .trim(),
        }),
    link: link,
    type: type,
  );

  String title;

  Map<String, dynamic> attributes;

  String link;

  int duration;
  int type;

  @override
  String toString() => '${toJson()}';

  Map<String, dynamic> toJson() => {
    "title": title,
    "link": link,
    "duration": duration,
    "type": type,
    "attributes": attributes,
  };
  Map<String, dynamic> toFireObj() => {
    "name": title,
    "url": link,
    "duration": duration,
    "attributes": attributes,
  };
}
