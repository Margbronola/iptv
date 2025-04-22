import 'package:seizhiptv/m3u/classified_data.dart';
import 'package:seizhiptv/m3u/db.regex.dart';
import 'package:seizhiptv/m3u/m3u_entry.dart';
import 'package:seizhiptv/m3u/parser.dart';

extension SORTER on List<M3uEntry> {
  static final DBRegX dbRegX = DBRegX();
  List<ClassifiedData> sortedCategories({
    required String attributeName,
    String defaultAttribute = 'other',
  }) {
    final List<M3uEntry> entries = List.from(this);
    final Map<String, List<M3uEntry>> sorted = M3uParser.sortedCategories(
      entries: entries,
      attributeName: attributeName,
      defaultAttribute: defaultAttribute,
    );
    final List<ClassifiedData> f = [];
    // for (MapEntry entry in _sorted.entries) {}
    sorted.forEach((key, value) {
      f.add(ClassifiedData(name: key, data: value));
    });
    return f;
  }

  Map<String, List<M3uEntry>> categorize({
    bool fromTitle = false,
    required String needle,
  }) {
    return fold(<String, List<M3uEntry>>{}, (acc, current) {
      // if (fromTitle) {
      //   return;
      // }
      final String property =
          fromTitle
              ? current.title
                  .toString()
                  .replaceAll(dbRegX.season, "")
                  .replaceAll(dbRegX.episode, "")
                  .replaceAll(dbRegX.epAndSe, "")
                  .trim()
              : current.attributes[needle] ?? current.attributes["tvg-id"]!;

      if (!acc.containsKey(property)) {
        acc[property] = [current];
      } else {
        acc[property]!.add(current);
      }
      return acc;
    });
  }

  // List<M3uEntry> categorizeType(int type) =>
  //     where((element) => element.type == type).toList();

  List<ClassifiedData> classify({bool fromTitle = false}) {
    try {
      Map<String, List<M3uEntry>> folded = categorize(
        needle: 'title-clean',
        fromTitle: fromTitle,
      );
      final List<ClassifiedData> res =
          folded.entries
              .map((e) => ClassifiedData(name: e.key, data: e.value))
              .toList();
      return res;
    } catch (e) {
      return [];
    }
  }
}

extension STR on String {
  bool containsUrl(String url, String needle) =>
      url.contains(needle) || url.contains("${needle}s");
  int get getType {
    final String finUrl = toLowerCase();
    if (containsUrl(finUrl, "movie")) {
      return 2;
    } else if (containsUrl(finUrl, "serie")) {
      return 3;
    } else if (containsUrl(finUrl, "live")) {
      return 1;
    }
    return 1;
  }
}

extension INT on int {
  String get contentStringify {
    switch (this) {
      case 2:
        return "movie";
      case 3:
        return "series";
      case 1:
        return "live";
      default:
        return "live";
    }
  }
}
