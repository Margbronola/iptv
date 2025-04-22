class EntryInfo {
  const EntryInfo({
    required this.title,
    required this.attributes,
    required this.duration,
  });

  /// Hold the information about the track.
  /// This is a raw string there are some formats specific to playlists, but
  /// this is the raw string check EX: `#EXTINF:191,Artist Name - Track Title`
  final String title;

  /// this is the raw number check EX: `#EXTINF:191,Artist Name - Track Title`
  final int duration;

  /// Attributes parsed from the line of metadata
  /// Ex:
  /// `#EXTINF:-1 tvg-id="identifier" group-title="The Only one",A TV channel`
  final Map<String, String?> attributes;
}
