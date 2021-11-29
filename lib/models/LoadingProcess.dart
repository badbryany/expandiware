import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingProcess extends StatelessWidget {
  const LoadingProcess({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int index = (DateTime.now().month / 4).round() + 1;

    return Container(
      width: 100,
      height: 200,
      child: Lottie.asset(
        'assets/animations/loading/loading_$index.json',
      ),
    );
  }
}
