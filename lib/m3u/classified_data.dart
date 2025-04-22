import 'package:seizhiptv/m3u/m3u_entry.dart';

class ClassifiedData {
  final String name;
  final List<M3uEntry> data;
  const ClassifiedData({required this.name, required this.data});

  Map<String, dynamic> toMap() => {
    "name": name,
    "data": data.map((e) => e.toString()).toList(),
  };
  @override
  String toString() => "${toMap()}";
}
