class Officer {
  final String name;
  final String role;
  final String? username;

  const Officer({
    required this.name,
    required this.role,
    this.username,
  });
}