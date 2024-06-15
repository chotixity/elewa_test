import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';
part 'task.g.dart';

enum Progress {
  assigned,
  started,
  done,
}

@freezed
class Task with _$Task {
  const factory Task({
    required String userId,
    required String taskId,
    required String title,
    required String description,
    @Default(Progress.assigned) Progress progress,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}