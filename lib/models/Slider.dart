import 'dart:math';

import 'package:flutter/material.dart';

class CustomSlider extends StatefulWidget {
  CustomSlider({
    Key? key,
    required this.text,
    required this.max,
    required this.min,
    required this.value,
    this.color,
    required this.onChange,
  }) : super(key: key);

  final String text;
  final double min;
  final double max;
  final double value;
  final Color? color;
  final Function(double) onChange;

  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.9;

    return Container(
      height: 45,
      width: width,
      margin: const EdgeInsets.only(top: 5, bottom: 5),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        color: Theme.of(context).backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                color: widget.color,
              ),
              height: 80,
              width: (width / widget.max) * widget.value,
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(left: 15),
              child: Text(
                widget.text,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              margin: const EdgeInsets.only(right: 15),
              child: Text(
                '${widget.value.toInt()}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  //color: value <= 15 ? color : null,
                ),
              ),
            ),
            Slider(
              value: widget.value,
              onChanged: widget.onChange,
              min: widget.min,
              max: widget.max,
              activeColor: Colors.transparent,
              inactiveColor: Colors.transparent,
              thumbColor: Colors.transparent,
              onChangeEnd: (value) {}, // send to server
            ),
          ],
        ),
      ),
    );
  }
}
