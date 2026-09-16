class Aprendiz {
  final int id;
  final String nombre1;
  final String? nombre2;
  final String apellido1;
  final String? apellido2;
  final String genero;
  final DateTime fechaNacimiento;
  final String celular;
  final String email;

  const Aprendiz({
    required this.id,
    required this.nombre1,
    this.nombre2,
    required this.apellido1,
    this.apellido2,
    required this.genero,
    required this.fechaNacimiento,
    required this.celular,
    required this.email,
  });

  factory Aprendiz.fromMap(Map<String, dynamic> map) {
    return Aprendiz(
      id: (map['id'] as num).toInt(),
      nombre1: map['nombre1'] as String,
      nombre2: map['nombre2'] as String?,
      apellido1: map['apellido1'] as String,
      apellido2: map['apellido2'] as String?,
      genero: map['genero'] as String,
      fechaNacimiento: DateTime.parse(map['fecha_nacimiento'] as String),
      celular: map['celular'] as String,
      email: map['email'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre1': nombre1,
      'nombre2': _nullable(nombre2),
      'apellido1': apellido1,
      'apellido2': _nullable(apellido2),
      'genero': genero,
      'fecha_nacimiento':
          '${fechaNacimiento.year.toString().padLeft(4, '0')}-'
          '${fechaNacimiento.month.toString().padLeft(2, '0')}-'
          '${fechaNacimiento.day.toString().padLeft(2, '0')}',
      'celular': celular,
      'email': email,
    };
  }

  static String? _nullable(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }
}
