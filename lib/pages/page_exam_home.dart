import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:optiread/locale/tr_TR.dart';
import 'package:optiread/pages/list_item_application.dart';
import 'package:optiread/pages/page_exam_editor.dart';
import 'package:optiread/models/exam/exam.dart';
import 'package:optiread/utils/application_statistics.dart';
import 'page_exam_application.dart';

class ExamHomePage extends StatefulWidget {
  final String? examKey;

  const ExamHomePage({this.examKey, super.key});

  @override
  ExamHomePageState createState() => ExamHomePageState();
}

class ExamHomePageState extends State<ExamHomePage> {

  String? get examKey => widget.examKey;

  late StreamSubscription<DatabaseEvent> event;
  late Exam? exam;

  final List<ApplicationListItem> applicationList = [];


  final bool _isGraphsEnabled = false;
  bool _isGraphsExpanded = false;
  bool _isApplicationsExpanded = true;
  bool _isStatisticsExpanded = true;


  @override
  void initState() {
    super.initState();
    exam = null;
    fetchExam();
    waitStatistics();
  }



  @override
  void dispose() {
    super.dispose();
    event.cancel();
  }

  Future<void> fetchExam() async {
    event = FirebaseDatabase.instance.ref().child('exams').child(examKey!).onValue.listen((event) {
      final snapshot = event.snapshot;
      if (snapshot.value == null) {
        return;
      }
      final Map<String, dynamic> data = (snapshot.value as Map<Object?, Object?>).cast<String, dynamic>();
      final row = data.cast<String, dynamic>();
      setState(() {
        exam = Exam.fromJson(row);
        applicationList.clear();
        exam!.applications.forEach((key, value) {
          applicationList.add(ApplicationListItem(examKey!, exam!, key, value, this));
        });
      });
    });
  }

  void waitStatistics() {
    Timer.periodic(const Duration(milliseconds: 20), (timer) {
      if (getAverageScore(applicationList) != 0) {
        setState(() {});
        timer.cancel();
      }
    });
  }

  void editExam() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ExamEditorPage(examKey: examKey, exam: exam),
      ),
    );
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text(widget.exam.name),
        // centerTitle: true,
      ),
      body: exam != null ? SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                exam!.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24),
              ),
              Text(
                exam!.subject,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              buildStatisticRow(label: stringQuestionAmount, value: '${exam!.answers.length}'),
              buildStatisticRow(label: stringOpinionAmount, value: '5'),
              buildStatisticRow(label: stringApplicationAmount, value: '${exam!.applications.length}'),
              buildStatisticRow(label: stringExamStartDateTime, value: Exam.getStartDateString(exam)),
              buildStatisticRow(label: stringExamEndDateTime, value: Exam.getEndDateString(exam)),
              buildStatisticRow(label: stringExamStatus, value: Exam.isApplicable(exam) ? stringYes : stringNo),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: ExpansionTile(
                  title: const Text(
                    stringApplications,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  initiallyExpanded: _isApplicationsExpanded,
                  trailing: Icon(
                    _isApplicationsExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                  onExpansionChanged: (bool expanded) {
                    setState(() {
                      _isApplicationsExpanded = expanded;
                    });
                  },
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ExamApplicationPage(exam: exam, examKey: examKey, applicationKey: null)
                            ),
                          );
                        },
                        child: const Text(
                          stringAddApplication,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: applicationList.length,
                        itemBuilder: (context, index) {
                          return applicationList[index];
                        },
                      ),
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: ExpansionTile(
                  title: const Text(
                    stringStatistics,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  initiallyExpanded: _isStatisticsExpanded,
                  trailing: Icon(
                    _isStatisticsExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                  onExpansionChanged: (bool expanded) {
                    setState(() {
                      _isStatisticsExpanded = expanded;
                    });
                  },
                  children: [
                    buildStatisticRow(
                      label: '$stringAverage:',
                      value: getAverageScore(applicationList).toStringAsFixed(2),
                    ),
                    buildStatisticRow(
                      label: '$stringHighestScore:',
                      value: getMaxScore(applicationList).toStringAsFixed(2),
                    ),
                    buildStatisticRow(
                      label: '$stringLowestScore:',
                      value: getMinScore(applicationList).toStringAsFixed(2),
                    ),
                    buildStatisticRow(
                      label: '$stringStandardDeviation:',
                      value: getStandardDeviation(applicationList).toStringAsFixed(2),
                    ),
                    buildStatisticRow(
                      label: '$stringMedian:',
                      value: getMedianScore(applicationList).toStringAsFixed(2),
                    ),
                    buildStatisticRow(
                      label: '$stringMode:',
                      value: getModeScore(applicationList).toStringAsFixed(2),
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              ),
              if (_isGraphsEnabled) Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: ExpansionTile(
                  title: const Text(
                    stringGraphics,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  initiallyExpanded: _isGraphsExpanded,
                  trailing: Icon(
                    _isGraphsExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                  onExpansionChanged: (bool expanded) {
                    setState(() {
                      _isGraphsExpanded = expanded;
                    });
                  },
                  children: [
                    buildGraphRow(),
                    const SizedBox(height: 10),
                    buildGraphRow(),
                    const SizedBox(height: 10),
                    buildGraphRow(),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: editExam,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Text(stringEditExam),
                ),
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ) : const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget buildGraphRow() {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.purple[100],
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: const Center(child: Icon(Icons.image, size: 50, color: Colors.purple)),
              ),
              const SizedBox(height: 5),
              const Text(
                'Graph 1',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            children: [
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.purple[100],
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: const Center(child: Icon(Icons.image, size: 50, color: Colors.purple)),
              ),
              const SizedBox(height: 5),
              const Text(
                'Graph 2',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildStatisticRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 16)),
          ),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}