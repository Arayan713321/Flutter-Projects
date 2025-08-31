import 'dart:convert';


class UserModel {
final String id;
final String name;
final String? email;
final String? phone;
final int createdAt;


UserModel({required this.id, required this.name, this.email, this.phone, required this.createdAt});


Map<String, dynamic> toMap() {
return {
'id': id,
'name': name,
'email': email,
'phone': phone,
'createdAt': createdAt,
};
}


factory UserModel.fromMap(Map<String, dynamic> map) {
return UserModel(
id: map['id'] ?? '',
name: map['name'] ?? '',
email: map['email'],
phone: map['phone'],
createdAt: map['createdAt'] ?? 0,
);
}


String toJson() => json.encode(toMap());


factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source));
}