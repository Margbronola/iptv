import 'package:seizhiptv/m3u/categorized_m3u_data.dart';

extension CAT on CategorizedM3UData {
  CategorizedM3UData clone() => CategorizedM3UData(
    live: List.from(live),
    movies: List.from(movies),
    series: List.from(series),
  );
}
