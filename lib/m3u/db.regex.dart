class DBRegX {
  final RegExp season = RegExp(
    r"((\b(s|S))(\d+))|((\b(season|SEASON|Season))((\d+)|( \d+)))",
    multiLine: true,
  );

  final RegExp episode = RegExp(
    r"((\b(e|E))(\d+))|((\b(episode|EPISODE|Episode|ep|EP|Ep))((\d+)|( \d+)))",
  );
  final epAndSe = RegExp(
    r"\b(s|S|SEASON|season|Season)(\d+(E|e|EPISODE|episode|Episode(\d+)))",
  );
}
