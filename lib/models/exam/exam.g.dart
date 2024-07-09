// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExamImpl _$$ExamImplFromJson(Map<String, dynamic> json) => _$ExamImpl(
      name: json['name'] as String,
      subject: json['subject'] as String,
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      isEnabled: json['isEnabled'] as bool,
      answers: (json['answers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      applications: json['applications'] != null ? (json['applications'] as Map<Object?, Object?>).cast<String,dynamic>().map(
            (key, value) =>
                MapEntry(key, Application.fromJson((value as Map<Object?, Object?>).cast<String, dynamic>())),
          ) :
          const {},
    );

Map<String, dynamic> _$$ExamImplToJson(_$ExamImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'subject': instance.subject,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'isEnabled': instance.isEnabled,
      'answers': instance.answers,
      'applications':
          instance.applications.map((k, e) => MapEntry(k, e.toJson())),
    };
