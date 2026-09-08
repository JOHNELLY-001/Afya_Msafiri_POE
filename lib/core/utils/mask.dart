String maskPassport(String id) {
  if (id.length <= 4) return id;
  final visible = id.substring(id.length - 4);
  return '*' * (id.length - 4) + visible;
}