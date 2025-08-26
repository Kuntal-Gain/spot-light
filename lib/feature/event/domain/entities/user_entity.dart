// lib/features/auth/domain/entities/user_entity.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String avatar;
  final List<String> events;
  final Timestamp createdAt;

  const UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.avatar,
    required this.events,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [uid, name, email, avatar, events, createdAt];
}
