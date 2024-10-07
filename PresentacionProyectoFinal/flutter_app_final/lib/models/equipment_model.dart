class Equipment {
  final int id; // Añadido el id
  final String nameE;
  final Set<String> reservedDates;

  Equipment(
      {required this.id, required this.nameE, required this.reservedDates});

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json[
          'id'], // Asegúrate de que esto coincida con la estructura de tu base de datos
      nameE: json['nameE'],
      reservedDates: (json['reservedDates'] as List).cast<String>().toSet(),
    );
  }
}
