import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:optiread/locale/tr_TR.dart';
import 'package:optiread/pages/controller_question.dart';
import 'package:optiread/pages/page_exam_editor.dart';



class QuestionListItem extends StatelessWidget {
  final ExamEditorPageState parent;
  final int questionNumber;
  final QuestionController questionController;


  const QuestionListItem({
    super.key,
    required this.parent,
    required this.questionNumber,
    required this.questionController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: Row(
        children: [
          IntrinsicWidth(
            child: TextField(
              controller: questionController.numberController,
              textAlign: TextAlign.center,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],

              onTapOutside: (value) {
                parent.orderControllers(questionController);
              },

              onEditingComplete: () {
                parent.orderControllers(questionController);
              },

              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: TextField(
              controller: questionController.answerController,
              decoration: InputDecoration(
                hintText: stringEnterOpinion,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              parent.removeController(questionNumber - 1);
            },
          ),
        ],
      ),
    );
  }
}