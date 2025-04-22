import 'package:seizhiptv/m3u/m3u_entry.dart';

extension ENTRY on List<M3uEntry> {
  List<M3uEntry> unique() {
    Set<M3uEntry> uniqueEntries = Set<M3uEntry>.from(this);
    return uniqueEntries.toList();
  }
}
