class RoleplayLine {
  final String speaker;
  final String text;

  const RoleplayLine({
    required this.speaker,
    required this.text,
  });
}

class RoleplayScenario {
  final String id;
  final String title;
  final String description;
  final List<RoleplayLine> lines;

  const RoleplayScenario({
    required this.id,
    required this.title,
    required this.description,
    required this.lines,
  });
}
