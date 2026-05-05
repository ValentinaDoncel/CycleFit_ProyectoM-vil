import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String nombre;
  final String email;
  final String? fotoPerfil;
  final DateTime? fechaNacimiento;
  final DateTime? ultimaPeriodo;
  final String? periodoRegular;
  final String? notas;
  final DateTime fechaRegistro;

  UserModel({
    required this.id,
    required this.nombre,
    required this.email,
    this.fotoPerfil,
    this.fechaNacimiento,
    this.ultimaPeriodo,
    this.periodoRegular,
    this.notas,
    DateTime? fechaRegistro,
  }) : fechaRegistro = fechaRegistro ?? DateTime.now();

  /// Crear UserModel desde JSON (Firebase)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fotoPerfil: json['fotoPerfil'] as String?,
      fechaNacimiento: json['fechaNacimiento'] != null
          ? (json['fechaNacimiento'] as Timestamp).toDate()
          : null,
      ultimaPeriodo: json['ultimaPeriodo'] != null
          ? (json['ultimaPeriodo'] as Timestamp).toDate()
          : null,
      periodoRegular: json['periodoRegular'] as String?,
      notas: json['notas'] as String?,
      fechaRegistro: json['fechaRegistro'] != null
          ? (json['fechaRegistro'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Convertir UserModel a JSON para guardar en Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'fotoPerfil': fotoPerfil,
      'fechaNacimiento': fechaNacimiento != null ? Timestamp.fromDate(fechaNacimiento!) : null,
      'ultimaPeriodo': ultimaPeriodo != null ? Timestamp.fromDate(ultimaPeriodo!) : null,
      'periodoRegular': periodoRegular,
      'notas': notas,
      'fechaRegistro': Timestamp.fromDate(fechaRegistro),
    };
  }

  /// Copiar con cambios
  UserModel copyWith({
    String? id,
    String? nombre,
    String? email,
    String? fotoPerfil,
    DateTime? fechaNacimiento,
    DateTime? ultimaPeriodo,
    String? periodoRegular,
    String? notas,
    DateTime? fechaRegistro,
  }) {
    return UserModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      fotoPerfil: fotoPerfil ?? this.fotoPerfil,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      ultimaPeriodo: ultimaPeriodo ?? this.ultimaPeriodo,
      periodoRegular: periodoRegular ?? this.periodoRegular,
      notas: notas ?? this.notas,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, nombre: $nombre, email: $email, fechaRegistro: $fechaRegistro)';
  }
}
