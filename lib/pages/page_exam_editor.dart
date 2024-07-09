import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:optiread/locale/tr_TR.dart';
import 'package:optiread/models/exam/exam.dart';
import 'package:optiread/pages/controller_question.dart';
import 'package:optiread/pages/list_item_exam_editor_answers.dart';
import 'package:optiread/pages/page_exam_home.dart';
import 'package:optiread/utils/io.dart';
import 'package:optiread/utils/toast.dart';

class ExamEditorPage extends StatefulWidget {
  final String? examKey;
  final Exam? exam;

  const ExamEditorPage({super.key, this.examKey, this.exam});


  @override
  ExamEditorPageState createState() => ExamEditorPageState();
}

class ExamEditorPageState extends State<ExamEditorPage> {

  final List<QuestionController> _questionControllers = List.generate(5, (index) => QuestionController(
    numberController: TextEditingController(text: (index + 1).toString()),
    answerController: TextEditingController(),
  ));
  final FToast _toast = FToast();
  bool _isExamActive = true;

  final TextEditingController _examNameController = TextEditingController();
  final TextEditingController _examSubjectController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  String? examName;
  String? examSubject;

  Exam? get exam => widget.exam;
  String? get examKey => widget.examKey;


  @override
  void initState() {
    super.initState();
    _toast.init(context);

    final exam = this.exam;
    if (exam != null) {
      _examNameController.text = exam.name;
      _examSubjectController.text = exam.subject;
      _isExamActive = exam.isEnabled;
      if (exam.startDate != null) {
        _startDateController.text = DateFormat(dateFormat).format(exam.startDate!);
      }
      if (exam.endDate != null) {
        _endDateController.text = DateFormat(dateFormat).format(exam.endDate!);
      }
      for (var i = 0; i < exam.answers.length; i++) {
        if (i < _questionControllers.length) {
          _questionControllers[i].answerController.text = exam.answers[i];
        } else {
          _questionControllers.add(QuestionController(
            numberController: TextEditingController(text: (i + 1).toString()),
            answerController: TextEditingController(text: exam.answers[i]),
          ));
        }
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _questionControllers) {
      controller.numberController.dispose();
      controller.answerController.dispose();
    }
    _examNameController.dispose();
    _examSubjectController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Exam _getExam() {
    DateFormat format = DateFormat(dateFormat);
    String name = _examNameController.text;
    String subject = _examSubjectController.text;
    DateTime? startDate = _startDateController.text.isNotEmpty ? format.parse(_startDateController.text) : null;
    DateTime? endDate = _endDateController.text.isNotEmpty ? format.parse(_endDateController.text) : null;
    List<String> answers = [];
    for (var controller in _questionControllers) {
      answers.add(controller.answerController.text);
    }
    bool isEnabled = _isExamActive;

    return Exam(name: name, subject: subject, startDate: startDate, endDate: endDate, isEnabled: isEnabled, answers: answers);
  }

  void _deleteExam() {
    final database = FirebaseDatabase.instance.ref();
    final exams = database.child('exams');
    exams.child(examKey!).remove();
  }

  Map<String, dynamic>? _saveExam() {
    Exam exam = _getExam();
    if (exam.name.isEmpty) {
      showErrorToast(_toast, stringExamNameNullError);
      return null;
    }
    if (exam.subject.isEmpty) {
      showErrorToast(_toast, stringExamTopicNullError);
      return null;
    }
    if (exam.answers.isEmpty) {
      showErrorToast(_toast, stringExamOpinionsNullError);
      return null;
    }

    for (var i = 0; i < exam.answers.length; i++) {
      if (exam.answers[i].isEmpty) {
        showWarningToast(_toast, stringExamNoOpinionQuestionError);
        return null;
      }
      if (exam.answers[i] == '-') {
        showWarningToast(_toast, stringExamEmptyQuestionError);
        return null;
      }
    }

    Map<String, dynamic> result = exam.toJson();

    final database = FirebaseDatabase.instance.ref();
    final exams = database.child('exams');

    String key;
    if (examKey != null) {
      key = examKey!;
      exams.child(key).set(result);
    } else {
      key = exams.push().key!;
      exams.child(key).set(result);
    }

    return {
      'key': key,
      'exam': exam
    };
  }

  void _showConfirmationDialog(String title, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          actions: <Widget>[
            TextButton(
              child: const Text(stringNo),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(stringYes),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDateTime(TextEditingController controller) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      confirmText: stringChoose,
      cancelText: stringCancel,
      helpText: stringPickDate,
      errorFormatText: stringDateFormatNotValid,
      errorInvalidText: stringDateNotValid,
    );
    if (selectedDate != null) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
        confirmText: stringChoose,
        cancelText: stringCancel,
        helpText: stringPickTime,
        errorInvalidText: stringTimeNotValid,
      );

      if (selectedTime != null) {
        final DateTime fullDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
        controller.text = DateFormat(dateFormat).format(fullDateTime);
      }
    }
  }

  void _onUploadComplete(List<String> answers) {
    for (var i = 0; i < answers.length; i++) {
      if (i < _questionControllers.length) {
        _questionControllers[i].answerController.text = answers[i].toString();
      } else {
        _questionControllers.add(QuestionController(
          numberController: TextEditingController(text: (i + 1).toString()),
          answerController: TextEditingController(text: answers[i].toString()),
        ));
      }
    }
    setState(() {});
  }


  void orderControllers(QuestionController questionController) {

    for (var i = 0; i < _questionControllers.length; i++) {
      for (var j = i + 1; j < _questionControllers.length; j++) {
        if (_questionControllers[i].numberController.text == _questionControllers[j].numberController.text) {
          if (_questionControllers[i] == questionController) {
            _questionControllers[j].numberController.text = (int.parse(_questionControllers[j].numberController.text) + 1).toString();
          } else {
            _questionControllers[i].numberController.text = (int.parse(_questionControllers[i].numberController.text) + 1).toString();
          }
        }
      }
    }

    _questionControllers.sort((a, b) {
      if (a.numberController.text.isEmpty) {
        return 0;
      }
      if (b.numberController.text.isEmpty) {
        return 1;
      }
      int aNumber = int.parse(a.numberController.text);
      int bNumber = int.parse(b.numberController.text);
      return aNumber.compareTo(bNumber);
    });

    setState(() {});
  }


  void removeController(int index) {
    _questionControllers.removeAt(index);
    for (var i = index; i < _questionControllers.length; i++) {
      _questionControllers[i].numberController.text = i.toString();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(stringPrepareExam),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: TextField(
                  controller: _examNameController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: stringExamName,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: TextField(
                  controller: _examSubjectController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: stringExamTopic,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: TextField(
                  controller: _startDateController,
                  readOnly: true,
                  onTap: () => _selectDateTime(_startDateController),
                  decoration: InputDecoration(
                    hintText: stringExamStartDateTime,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: TextField(
                  controller: _endDateController,
                  readOnly: true,
                  onTap: () => _selectDateTime(_endDateController),
                  decoration: InputDecoration(
                    hintText: stringExamEndDateTime,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _buildAnswerKeySection(context),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text(stringExamStatus),
                value: _isExamActive,
                onChanged: (bool value) {
                  setState(() {
                    _isExamActive = !_isExamActive;
                  });
                },
              ),
              const SizedBox(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        _showConfirmationDialog(
                            stringCancelConfirm, () {
                              showInfoToast(_toast, stringCanceled);
                          Navigator.pop(context);
                        });
                      },
                      style: ButtonStyle(
                        backgroundColor:
                        WidgetStateProperty.all(Colors.grey[600]),
                      ),
                      child:
                      const Text(stringCancel, style: TextStyle(color: Colors.white))),

                  if (examKey != null)
                  ElevatedButton(
                    onPressed: () {
                      _showConfirmationDialog(
                          stringDeleteConfirm, () {
                        _deleteExam();
                        showDeletedToast(_toast, stringDeleted);
                        Navigator.pop(context);
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.red[600]),
                    ),
                    child: const Text(' $stringDelete ', style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Map<String, dynamic>? result = _saveExam();
                      if (result == null) {
                        return;
                      }
                      showSuccessToast(_toast, stringSaved);
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                      backgroundColor:
                      WidgetStateProperty.all(Colors.green[600]),
                    ),
                    child:
                    const Text(stringSave, style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Map<String, dynamic>? result = _saveExam();
                      if (result == null) {
                        return;
                      }
                      showSuccessToast(_toast, stringSavedAndContinuing);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExamHomePage(
                            examKey: result['key'],
                          ),
                        ),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor:
                      WidgetStateProperty.all(Colors.blue[600]),
                    ),
                    child: const Text(stringSaveAndContinue, style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerKeySection(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: IconButton(
                icon: const Icon(Icons.camera_alt),
                onPressed: () {
                  pickCameraImage().then((value) {
                    uploadImage(value).then((answers) {
                      _onUploadComplete(answers);
                    }).catchError((error) {
                      showErrorToast(_toast, error.toString());
                    });
                  }).catchError((error) {
                    showErrorToast(_toast, error.toString());
                  });
                },
              ),
            ),
            Expanded(
              child: IconButton(
                icon: const Icon(Icons.photo),
                onPressed: () {
                  pickImage().then((value) {
                    uploadImage(value).then((answers) {
                      _onUploadComplete(answers);
                    }).catchError((error) {
                      showErrorToast(_toast, error.toString());
                    });
                  }).catchError((error) {
                    showErrorToast(_toast, error.toString());
                  });
                },
              ),
            ),
            Expanded(
              child: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    _questionControllers.insert(0, QuestionController(
                      numberController: TextEditingController(),
                      answerController: TextEditingController(),
                    ));
                  });
                },
              ),
            ),
          ],
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
            itemCount: _questionControllers.length,
            itemBuilder: (context, index) {
              return QuestionListItem(
                parent: this,
                questionNumber: index + 1,
                questionController: _questionControllers[index],
              );
            },
          ),
        ),
      ],
    );
  }
}

