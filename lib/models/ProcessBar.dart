import 'package:flutter/material.dart';

class ProcessBar extends StatefulWidget {
  ProcessBar({
    Key? key,
    required this.width,
    required this.totalSteps,
    required this.currentStep,
    this.slow,
  }) : super(key: key);

  final double width;
  final int totalSteps;
  final int currentStep;
  bool? slow;

  @override
  _ProcessBarState createState() => _ProcessBarState();
}

class _ProcessBarState extends State<ProcessBar> {
  double getWidth() => (widget.width / widget.totalSteps) * widget.currentStep;

  @override
  Widget build(BuildContext context) {
    widget.slow ??= false;
    double height = 5;
    return Stack(
      children: [
        Container(
          height: height,
          width: widget.width,
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(100)),
          ),
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: widget.slow! ? 3000 : 700),
          height: height,
          width: getWidth(),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: const BorderRadius.all(Radius.circular(100)),
          ),
        ),
      ],
    );
  }
}
