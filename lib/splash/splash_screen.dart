import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:optiread/locale/tr_TR.dart';
import 'package:optiread/utils/constants.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(
              imageSplashScreen,
              fit: BoxFit.fitHeight,
            ),
          ),
          const Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: CircularProgressIndicator(
              color: colorWhite,
              strokeWidth: 6,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: Colors.blueGrey,
                    width: 1,
                  ),
                ),
                child: const Text(
                  stringORMLoading,
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
