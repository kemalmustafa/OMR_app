import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:optiread/locale/tr_TR.dart';
import 'package:optiread/utils/toast.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:ui' as ui;
import 'dart:async';

class OpticsSupportedPage extends StatelessWidget {
  final FToast toast = FToast();

  OpticsSupportedPage({super.key});


  @override
  Widget build(BuildContext context) {
    toast.init(context);

    final List<String> imagePaths = [
      'assets/sheets/5.jpg',
      'assets/sheets/10.jpg',
      'assets/sheets/15.jpg',
      'assets/sheets/20.jpg',
    ];

    final List<String> imageTitles = [
      '5 $stringLowerCaseQuestion 5 $stringLowerCaseOpinions $stringLowerCaseOptical',
      '10 $stringLowerCaseQuestion 5 $stringLowerCaseOpinions $stringLowerCaseOptical',
      '15 $stringLowerCaseQuestion 5 $stringLowerCaseOpinions $stringLowerCaseOptical',
      '20 $stringLowerCaseQuestion 5 $stringLowerCaseOpinions $stringLowerCaseOptical',
    ];

    final PageController pageController = PageController();

    return Scaffold(
      appBar: AppBar(
        title: const Text(stringSupportedOptics),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
            child: ValueListenableBuilder<int>(
              valueListenable: pageController.pageNotifier,
              builder: (context, value, _) {
                return Text(
                  imageTitles[value],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                );
              },
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: pageController,
              itemCount: imagePaths.length,
              itemBuilder: (context, index) {
                return FutureBuilder<ui.Image>(
                  future: _loadImage(imagePaths[index]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                      final image = snapshot.data!;
                      final aspectRatio = image.width / image.height;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                        child: AspectRatio(
                          aspectRatio: aspectRatio,
                          child: Image.asset(
                            imagePaths[index],
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                );
              },
              onPageChanged: (index) {
                pageController.pageNotifier.value = index;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: SmoothPageIndicator(
              controller: pageController,
              count: imagePaths.length,
              effect: ScrollingDotsEffect(
                activeDotColor: Theme.of(context).primaryColor,
                dotColor: Colors.grey,
                dotHeight: 8,
                dotWidth: 8,
                activeDotScale: 1.3,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _downloadImage(context, imagePaths[pageController.pageNotifier.value]);
                },
                child: const Text(stringDownloadImage),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<ui.Image> _loadImage(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final bytes = byteData.buffer.asUint8List();
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(bytes, completer.complete);
    return completer.future;
  }

  Future<void> _downloadImage(BuildContext context, String assetPath) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      final bytes = byteData.buffer.asUint8List();
      final result = await ImageGallerySaver.saveImage(bytes, name: assetPath.split('/').last);

      if (result['isSuccess']) {
        showSuccessToast(toast, stringDownloadSuccess);
      } else {
        showErrorToast(toast, stringDownloadError);
      }
    } catch (e) {
      showErrorToast(toast, stringDownloadError);
    }
  }
}

extension on PageController {
  ValueNotifier<int> get pageNotifier {
    final notifier = ValueNotifier<int>(initialPage);
    addListener(() {
      notifier.value = page?.round() ?? initialPage;
    });
    return notifier;
  }
}
