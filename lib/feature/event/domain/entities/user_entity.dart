// lib/features/auth/domain/entities/user_entity.dart
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final List<String> events;
  final String createdAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    required this.events,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, email, avatar, events, createdAt];
}
