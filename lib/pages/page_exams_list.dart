import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:optiread/locale/tr_TR.dart';
import 'package:optiread/models/exam/exam.dart';
import 'package:optiread/pages/page_exam_home.dart';


class ExamsListPage extends StatefulWidget {
  const ExamsListPage({super.key});

  @override
  ExamsListPageState createState() => ExamsListPageState();

}

class ExamsListPageState extends State<ExamsListPage> {
  late StreamSubscription<DatabaseEvent> event;
  late Timer timer;
  Map<String, Exam> exams = {};

  @override
  void initState() {
    super.initState();
    _fetchExams();
    timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      setState(() {});
    });
  }


  @override
  void dispose() {
    super.dispose();
    event.cancel();
    timer.cancel();
  }


  Future<void> _fetchExams() async {

    event = FirebaseDatabase.instance.ref().child('exams').onValue.listen((event) {
      final snapshot = event.snapshot;
      if (snapshot.value == null) {
        return;
      }
      final Map<String, dynamic> data = (snapshot.value as Map<Object?, Object?>).cast<String, dynamic>();
      exams.clear();
      data.forEach((key, value) {
        final row = (value as Map<Object?, Object?>).cast<String, dynamic>();
        exams[key] = Exam.fromJson(row);
      });

      setState(() {});

    });


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: examsListPageTitle,
        centerTitle: true,
      ),
      body: exams.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(stringSearching),
            Text(stringWaitDuringSearch),
          ],
        ),
      )
          : ListView(
        children: exams.entries
            .map((entry) => ExamListItem(examKey: entry.key, exam: entry.value))
            .toList(),
      ),
    );
  }
}

class ExamListItem extends StatelessWidget {
  final String examKey;
  final Exam exam;

  const ExamListItem({super.key, required this.examKey, required this.exam});

  @override
  Widget build(BuildContext context) {
    Color availabilityColor = Exam.isApplicable(exam) ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExamHomePage(examKey: examKey),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(Icons.circle, color: availabilityColor),
              const SizedBox(width: 8.0),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(exam.subject),
                  ],
                ),
              ),
              Column(
                children: [
                  Text('$stringExamsListPageExamQuestionAmount${exam.answers.length}'),
                  Text('$stringExamsListPageExamAnswerAmount${exam.applications.length}'),
                ],
              ),
              const Icon(Icons.arrow_forward),
            ],
          ),
        ),
      ),
    );
  }
}