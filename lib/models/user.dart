class User {
  final String email;
  final String displayName;
  final bool hasFamily;

  User({
    required this.email,
    required this.displayName,
    this.hasFamily = false,
  });
}