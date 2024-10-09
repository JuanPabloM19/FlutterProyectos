class Equipment {
  final int id;
  final String nameE;
  final Set<String> reservedDates;

  Equipment({
    required this.id,
    required this.nameE,
    required this.reservedDates,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['id'],
      nameE: json['nameE'],
      reservedDates: (json['reservedDates'] as String).isEmpty
          ? {}
          : (json['reservedDates'] as String)
              .split(',')
              .where((element) => element.isNotEmpty)
              .toSet(),
    );
  }
}
