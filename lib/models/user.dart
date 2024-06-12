import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart'; // For JSON serialization

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String fullName,
    required String position,
    String? department, // Optional, null for managers
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
