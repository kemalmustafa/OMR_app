import 'package:intl/intl.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:optiread/models/application/application.dart';
part 'exam.freezed.dart';
part 'exam.g.dart';


@freezed
class Exam with _$Exam {
  @JsonSerializable(explicitToJson: true)
  const factory Exam({
    required String name,
    required String subject,
    DateTime? startDate,
    DateTime? endDate,
    required bool isEnabled,
    @Default([]) List<String> answers,
    @Default({}) Map<String, Application> applications,
  }) = _Exam;


  static bool isApplicable(exam) {
    if (exam.startDate == null && exam.endDate == null) {
      return exam.isEnabled;
    }
    final now = DateTime.now();
    if (exam.startDate == null) {
      return now.isAfter(exam.endDate) && exam.isEnabled;
    }
    return now.isAfter(exam.startDate) &&
        now.isBefore(exam.endDate) &&
        exam.isEnabled;
  }

  static String getStartDateString(exam) {
    if (exam.startDate == null) {
      return 'Belirtilmedi';
    }
    return DateFormat('hh:mm dd/MM/yyyy').format(exam.startDate);
  }

  static String getEndDateString(exam) {
    if (exam.endDate == null) {
      return 'Belirtilmedi';
    }
    return DateFormat('hh:mm dd/MM/yyyy').format(exam.endDate);
  }

  factory Exam.fromJson(Map<String, dynamic> json) => _$ExamFromJson(json);
}


// _$ExamImpl _$$ExamImplFromJson(Map<String, dynamic> json) => _$ExamImpl(
//   name: json['name'] as String,
//   subject: json['subject'] as String,
//   startDate: json['startDate'] == null
//       ? null
//       : DateTime.parse(json['startDate'] as String),
//   endDate: json['endDate'] == null
//       ? null
//       : DateTime.parse(json['endDate'] as String),
//   isEnabled: json['isEnabled'] as bool,
//   answers: (json['answers'] as List<dynamic>?)
//       ?.map((e) => e as String)
//       .toList() ??
//       const [],
//   applications: (json['applications'] as List<dynamic>?)
//       ?.map((e) => Application.fromJson((e as Map<Object?, Object?>).cast<String, dynamic>().map(
//         (k, e) => MapEntry(k, e as Object),
//   )))
//       .toList() ??
//       const [],
// );
