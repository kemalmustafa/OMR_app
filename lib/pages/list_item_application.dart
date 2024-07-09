import 'package:flutter/material.dart';
import 'package:optiread/locale/tr_TR.dart';
import 'package:optiread/models/application/application.dart';
import 'package:optiread/models/exam/exam.dart';
import 'package:optiread/pages/page_exam_application.dart';
import 'package:optiread/pages/page_exam_home.dart';

class ApplicationData {
  double score = 0;
  int questionAmount = 0;
  int correctAnswers = 0;
  int wrongAnswers = 0;
  int blankAnswers = 0;
}

class ApplicationListItem extends StatelessWidget {
  final String examKey;
  final Exam exam;
  final String applicationKey;
  final Application application;
  final ExamHomePageState? parent;

  final ApplicationData data = ApplicationData();

  ApplicationListItem(this.examKey, this.exam, this.applicationKey, this.application, this.parent, {super.key});

  String getFormattedScore() {
    return data.score.ceil().toString();
  }

  @override
  Widget build(BuildContext context) {
    data.score = 0;
    data.correctAnswers = 0;
    data.wrongAnswers = 0;
    data.blankAnswers = 0;
    data.questionAmount = exam.answers.length;

    for (int i = 0; i < data.questionAmount; i++) {
      if (application.answers[i] == exam.answers[i]) {
        data.correctAnswers++;
      } else if (application.answers[i].isEmpty || application.answers[i] == "-") {
        data.blankAnswers++;
      } else {
        data.wrongAnswers++;
      }
    }

    data.score = (100 / data.questionAmount) * data.correctAnswers;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${application.name} ${application.surname}',
                  style: const TextStyle(fontSize: 18.0, color: Colors.black),
                  overflow: TextOverflow.ellipsis, // Prevent overflow
                ),
                Text(
                  application.number,
                  style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                  overflow: TextOverflow.ellipsis, // Prevent overflow
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'D${data.correctAnswers} ',
                      style: const TextStyle(color: Colors.green),
                    ),
                    TextSpan(
                      text: 'B${data.blankAnswers} ',
                      style: const TextStyle(color: Colors.blueGrey),
                    ),
                    TextSpan(
                      text: 'Y${data.wrongAnswers}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
                overflow: TextOverflow.ellipsis, // Prevent overflow
              ),
              Text(
                '$stringScore: ${getFormattedScore()}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
                overflow: TextOverflow.ellipsis, // Prevent overflow
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_right),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ExamApplicationPage(
                        exam: exam, examKey: examKey, applicationKey: applicationKey)
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
