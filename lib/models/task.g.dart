// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TaskImpl _$$TaskImplFromJson(Map<String, dynamic> json) => _$TaskImpl(
      userId: json['userId'] as String,
      taskId: json['taskId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      progress: $enumDecodeNullable(_$ProgressEnumMap, json['progress']) ??
          Progress.assigned,
    );

Map<String, dynamic> _$$TaskImplToJson(_$TaskImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'taskId': instance.taskId,
      'title': instance.title,
      'description': instance.description,
      'dueDate': instance.dueDate.toIso8601String(),
      'progress': _$ProgressEnumMap[instance.progress]!,
    };

const _$ProgressEnumMap = {
  Progress.assigned: 'assigned',
  Progress.started: 'started',
  Progress.done: 'done',
};
