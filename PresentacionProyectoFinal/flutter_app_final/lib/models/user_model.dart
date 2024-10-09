class User {
  final String userId;
  final String name;
  final String email;
  final bool isAdmin; // Agregar si es administrador

  User(
      {required this.userId,
      required this.name,
      required this.email,
      required this.isAdmin});
}
