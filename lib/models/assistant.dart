import 'package:cloud_firestore/cloud_firestore.dart';

class Assistant {
  final String id; // Firebase Auth UID
  final String email;
  final String fullName;
  final String schoolName;
  final String? phone;

  Assistant({
    required this.id,
    required this.email,
    required this.fullName,
    required this.schoolName,
    this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'schoolName': schoolName,
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory Assistant.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return Assistant(
      id: doc.id,
      email: data['email'] as String,
      fullName: data['fullName'] as String,
      schoolName: data['schoolName'] as String,
      phone: data['phone'] as String?,
    );
  }

  Assistant copyWith({
    String? id,
    String? email,
    String? fullName,
    String? schoolName,
    String? phone,
  }) {
    return Assistant(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      schoolName: schoolName ?? this.schoolName,
      phone: phone ?? this.phone,
    );
  }

  factory Assistant.fromMap(Map<String, dynamic> map, {String? id}) {
    return Assistant(
      id: id ?? '',
      email: map['email'] as String,
      fullName: map['fullName'] as String,
      schoolName: map['schoolName'] as String,
      phone: map['phone'] as String?,
    );
  }
}

