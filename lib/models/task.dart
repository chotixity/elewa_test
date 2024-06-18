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
    required DateTime dueDate,
    @Default(Progress.assigned) Progress progress,
    @Default(false) bool isRecurring,
    Duration? interval,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}
