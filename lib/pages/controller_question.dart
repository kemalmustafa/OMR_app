import 'package:flutter/widgets.dart';

class QuestionController {
  final TextEditingController answerController;
  final TextEditingController numberController;

  const QuestionController({
    required this.answerController,
    required this.numberController,
  });
}
