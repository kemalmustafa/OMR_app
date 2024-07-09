import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:optiread/locale/tr_TR.dart';
import 'package:optiread/models/application/application.dart';
import 'package:optiread/models/exam/exam.dart';
import 'package:optiread/pages/controller_question.dart';
import 'package:optiread/utils/toast.dart';
import 'package:optiread/utils/io.dart';

class ExamApplicationPage extends StatefulWidget {

  final String? examKey;
  final String? applicationKey;
  final Exam? exam;

  const ExamApplicationPage({super.key, this.exam, this.examKey, this.applicationKey});

  @override
  ExamApplicationPageState createState() => ExamApplicationPageState();

}


class ExamApplicationPageState extends State<ExamApplicationPage>  {

  String? get examKey => widget.examKey;
  String? get applicationKey => widget.applicationKey;
  Exam? get exam => widget.exam;
  late Application? application;
  late StreamSubscription<DatabaseEvent> event;



  final List<QuestionController> _questionControllers = [];
  final TextEditingController _applyNameController = TextEditingController();
  final TextEditingController _applySurnameController = TextEditingController();
  final TextEditingController _applyNumberController = TextEditingController();
  final FToast _toast = FToast();


  @override
  void initState() {
    super.initState();
    _toast.init(context);
    application = null;

    if (applicationKey == null) {
      application = const Application(
        name: '',
        surname: '',
        number: '',
        answers: [],
      );
      for (int i = 0; i < exam!.answers.length; i++) {
        _questionControllers.add(QuestionController(
          numberController: TextEditingController(text: (i + 1).toString()),
          answerController: TextEditingController(),
        ));
      }

    } else {
      _fetchApplication();
    }
  }

  void _onUploadComplete(List<String> answers) {
    _questionControllers.clear();

    var targetAnswers = 0;
    if (answers.length > exam!.answers.length) {
      targetAnswers = exam!.answers.length;
      showWarningToast(_toast, stringUploadImageExtraQuestionError);
    } else if (answers.length < exam!.answers.length) {
      targetAnswers = answers.length;
      showWarningToast(_toast, stringUploadImageMissingQuestionError);
    } else {
      targetAnswers = answers.length;
    }
    for (var i = 0; i < targetAnswers; i++) {
      if (i < _questionControllers.length) {
        _questionControllers[i].answerController.text = answers[i].toString();
      } else {
        _questionControllers.add(QuestionController(
          numberController: TextEditingController(text: (i + 1).toString()),
          answerController: TextEditingController(text: answers[i].toString()),
        ));
      }
    }

    for (var i = targetAnswers; i < exam!.answers.length; i++) {
      _questionControllers.add(QuestionController(
        numberController: TextEditingController(text: (i + 1).toString()),
        answerController: TextEditingController(),
      ));
    }

    setState(() {});
  }

  void _fetchApplication() {
    event = FirebaseDatabase.instance.ref().child('exams').child(examKey!).child('applications').child(applicationKey!).onValue.listen((event) {
      final snapshot = event.snapshot;
      if (snapshot.value == null) {
        return;
      }
      final Map<String, dynamic> data = (snapshot.value as Map<Object?, Object?>).cast<String, dynamic>();
      application = Application.fromJson(data);

      for (int i = 0; i < application!.answers.length; i++) {
        _questionControllers.add(QuestionController(
          numberController: TextEditingController(text: (i + 1).toString()),
          answerController: TextEditingController(text: application?.answers[i]),
        ));
      }

      _applyNameController.text = application!.name;
      _applySurnameController.text = application!.surname;
      _applyNumberController.text = application!.number;
      setState(() {});
    });
  }


  @override
  void dispose() {
    for (var controller in _questionControllers) {
      controller.numberController.dispose();
      controller.answerController.dispose();
    }
    if (applicationKey != null) event.cancel();
    super.dispose();
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

  bool _saveApplication() {
    if (_applyNameController.text.isEmpty || _applySurnameController.text.isEmpty || _applyNumberController.text.isEmpty) {
      showErrorToast(_toast, stringFillAllFieldsError);
      return false;
    }
    if (_questionControllers.any((element) => element.answerController.text.isEmpty)) {
      showErrorToast(_toast, stringFillAllFieldsError);
      return false;
    }
    String name = _applyNameController.text;
    String surname = _applySurnameController.text;
    String number = _applyNumberController.text;
    List<String> answers = _questionControllers.map((e) => e.answerController.text).toList();
    Application application = Application(
      name: name,
      surname: surname,
      number: number,
      answers: answers,
    );
    if (applicationKey == null) {
      FirebaseDatabase.instance.ref().child('exams').child(examKey!).child('applications').push().set(application.toJson());
    } else {
      FirebaseDatabase.instance.ref().child('exams').child(examKey!).child('applications').child(applicationKey!).set(application.toJson());
    }
    return true;
  }

  void _deleteApplication() {
    FirebaseDatabase.instance.ref().child('exams').child(examKey!).child('applications').child(applicationKey!).remove();
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
                icon: const Icon(Icons.image),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(stringApplicationDetails),
        centerTitle: true,
      ),
      body: application != null ? Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: TextField(
                  controller: _applyNameController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: stringName,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: TextField(
                  controller: _applySurnameController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: stringSurname,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: TextField(
                  controller: _applyNumberController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: stringNumber,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _buildAnswerKeySection(context),
              const SizedBox(height: 10),
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
                  if (applicationKey != null) ElevatedButton(
                    onPressed: () {
                      _showConfirmationDialog(
                          stringDeleteConfirm, () {
                        _deleteApplication();
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
                      final result = _saveApplication();
                      if (result) {
                        showSavedToast(_toast, stringSaved);
                        Navigator.pop(context);
                      }

                    },
                    style: ButtonStyle(
                      backgroundColor:
                      WidgetStateProperty.all(Colors.green[600]),
                    ),
                    child:
                    const Text(stringSave, style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],



          ),
        ),
      ) : const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class QuestionListItem extends StatelessWidget {
  final ExamApplicationPageState parent;
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
        ],
      ),
    );
  }
}
