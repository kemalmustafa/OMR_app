import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
part 'application.freezed.dart';
part 'application.g.dart';

@freezed
class Application with _$Application {
  const factory Application({
    required String name,
    required String surname,
    required String number,
    required List<String> answers,
  }) = _Application;

  factory Application.fromJson(Map<String, dynamic> json) => _$ApplicationFromJson(json);
}