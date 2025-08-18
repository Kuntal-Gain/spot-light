// lib/features/auth/data/models/user_model.dart
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.avatar,
    required super.events,
    required super.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['\$id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      avatar: map['avatar'] ?? '',
      events: List.from(map['events'] ?? []),
      createdAt: map['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '\$id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'events': events,
    };
  }
}
