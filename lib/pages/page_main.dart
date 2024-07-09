import 'package:flutter/material.dart';
import 'package:optiread/locale/tr_TR.dart';
import 'package:optiread/utils/constants.dart';
import 'package:optiread/pages/page_exam_editor.dart';
import 'package:optiread/pages/page_exams_list.dart';
import 'package:optiread/pages/page_optics_supported.dart';
import 'package:optiread/pages/page_instructions.dart';




class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(mainPageTitle), centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: mainPageIconPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ExamEditorPage()),
                          );
                        },
                        icon: mainPageExamEditorIcon,
                        iconSize: mainPageIconSize,
                      ),
                      mainPageExamEditorLabel,

                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ExamsListPage()),
                          );
                        },
                        icon: mainPageExamListIcon,
                        iconSize: mainPageIconSize,
                      ),
                      mainPageExamListLabel,
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: mainPageIconPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => OpticsSupportedPage()),
                          );
                        },
                        icon: mainPageSupportedOpticsIcon,
                        iconSize: mainPageIconSize,
                      ),
                      mainPageSupportedOpticsLabel,
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const InstructionsPage()),
                          );
                        },
                        icon: mainPageInstructionsIcon,
                        iconSize: mainPageIconSize,
                      ),
                      mainPageInstructionsLabel,
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
