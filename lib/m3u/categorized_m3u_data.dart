import 'package:seizhiptv/m3u/classified_data.dart';

class CategorizedM3UData {
  final List<ClassifiedData> series;
  final List<ClassifiedData> movies;
  final List<ClassifiedData> live;

  const CategorizedM3UData({
    required this.live,
    required this.movies,
    required this.series,
  });
  factory CategorizedM3UData.empty() =>
      const CategorizedM3UData(live: [], movies: [], series: []);
  @override
  String toString() => "${toJson()}";
  Map<String, dynamic> toJson() => {
    "series": series,
    "movies": movies,
    "live": live,
  };
}
