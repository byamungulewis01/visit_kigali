import 'package:intl/intl.dart';

class Tourist {
  final int? id;
  final String fname;
  final String lname;
  final String email;
  final String phone;
  final DateTime dateOfBirth;
  final String nationality;

  Tourist({
    this.id,
    required this.fname,
    required this.lname,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.nationality,
  });

  factory Tourist.fromJson(Map<String, dynamic> json) {
    return Tourist(
      id: json['id'],
      fname: json['fname'],
      lname: json['lname'],
      email: json['email'],
      phone: json['phone'],
      dateOfBirth: DateTime.parse(json['date_of_birth']),
      nationality: json['nationality'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fname': fname,
      'lname': lname,
      'email': email,
      'phone': phone,
      'date_of_birth': DateFormat('yyyy-MM-dd').format(dateOfBirth),
      'nationality': nationality,
    };
  }
}