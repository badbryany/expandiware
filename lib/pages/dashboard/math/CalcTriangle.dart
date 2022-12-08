import 'dart:math';

import 'package:angles/angles.dart';
import 'package:expandiware/models/ListItem.dart';
import 'package:expandiware/models/ListPage.dart';
import 'package:expandiware/pages/dashboard/math/CalcRegularTriAngle.dart';
import 'package:flutter/material.dart';

class CalcTriangle extends StatefulWidget {
  const CalcTriangle({Key? key}) : super(key: key);

  @override
  State<CalcTriangle> createState() => _CalcTriangleState();
}

class _CalcTriangleState extends State<CalcTriangle> {
  Map<String, String> values = {
    'a': '?',
    'b': '?',
    'c': '?',
    'alpha': '?',
    'betha': '?',
    'gamma': '?',
  };

  Map<String, String> restValues = {
    'ha': '?',
    'hb': '?',
    'hc': '?',
    'area': '?',
    'radOuterCircle': '?',
    'radInnerCircle': '?',
  };

  Map<String, TextEditingController> controllers = {
    'a': TextEditingController(),
    'b': TextEditingController(),
    'c': TextEditingController(),
    'alpha': TextEditingController(),
    'betha': TextEditingController(),
    'gamma': TextEditingController(),
  };

  List<dynamic> _inputs = [
    {
      'text': 'a',
      'value': 'a',
      'highlight': [3],
      'edit': false,
    },
    {
      'text': 'b',
      'value': 'b',
      'highlight': [2],
      'edit': false,
    },
    {
      'text': 'c',
      'value': 'c',
      'highlight': [1],
      'edit': false,
    },
    {
      'text': 'α',
      'value': 'alpha',
      'highlight': [1, 2],
      'edit': false,
    },
    {
      'text': 'β',
      'value': 'betha',
      'highlight': [3, 1],
      'edit': false,
    },
    {
      'text': 'γ',
      'value': 'gamma',
      'highlight': [2, 3],
      'edit': false,
    },
  ];

  void calc() {
    Map<String, dynamic> triAngle = RegTriAngle().getTriAngle(
      a: double.tryParse(values['a']!),
      b: double.tryParse(values['b']!),
      c: double.tryParse(values['c']!),
      alpha: double.tryParse(values['alpha']!),
      betha: double.tryParse(values['betha']!),
      gamma: double.tryParse(values['gamma']!),
    );
    if (triAngle['a'] != null &&
        triAngle['b'] != null &&
        triAngle['c'] != null &&
        triAngle['alpha'] != null &&
        triAngle['betha'] != null &&
        triAngle['gamma'] != null) {
      for (int i = 0; i < _inputs.length; i++) _inputs[i]['edit'] = false;

      Map<String, double> heights = RegTriAngle().calcTriangleHeights(
        a: triAngle['a'],
        b: triAngle['b'],
        c: triAngle['c'],
        alpha: triAngle['alpha'],
        betha: triAngle['betha'],
        gamma: triAngle['gamma'],
      );

      restValues['ha'] = heights['ha']!.toString();
      restValues['hb'] = heights['hb']!.toString();
      restValues['hc'] = heights['hc']!.toString();

      restValues['radInnerCircle'] = RegTriAngle()
          .radInnerCircle(
            a: triAngle['a'],
            b: triAngle['b'],
            c: triAngle['c'],
            alpha: triAngle['alpha'],
            betha: triAngle['betha'],
            gamma: triAngle['gamma'],
          )
          .toString();

      restValues['radOuterCircle'] = RegTriAngle()
          .radOuterCircle(
            a: triAngle['a'],
            b: triAngle['b'],
            c: triAngle['c'],
            alpha: triAngle['alpha'],
            betha: triAngle['betha'],
            gamma: triAngle['gamma'],
          )
          .toString();

      restValues['area'] = RegTriAngle()
          .calcArea(
            a: triAngle['a'],
            b: triAngle['b'],
            c: triAngle['c'],
            alpha: triAngle['alpha'],
            betha: triAngle['betha'],
            gamma: triAngle['gamma'],
          )
          .toString();

      addAllAnimation({
        'a': triAngle['a'].toString(),
        'b': triAngle['b'].toString(),
        'c': triAngle['c'].toString(),
        'alpha': triAngle['alpha'].toString(),
        'betha': triAngle['betha'].toString(),
        'gamma': triAngle['gamma'].toString(),
      });
    }
  }

  addAllAnimation(Map<String, String> data) async {
    Duration delay = const Duration(milliseconds: 5);

    List<String> allValues = ['a', 'b', 'c', 'alpha', 'betha', 'gamma'];

    for (int j = 0; j < allValues.length; j++) {
      values[allValues[j]] = '';
      for (int i = 0; i < data[allValues[j]]!.length; i++) {
        values[allValues[j]] =
            values[allValues[j]].toString() + data[allValues[j]]![i];
        setState(() {});
        await Future.delayed(delay);
      }
    }
  }

  @override
  void initState() {
    for (int i = 0; i < _inputs.length; i++) {
      controllers[_inputs[i]['value']]!.addListener(() {
        values[_inputs[i]['value']] = controllers[_inputs[i]['value']]!.text;

        setState(() {});
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListPage(
        title: 'Dreieck',
        actions: [
          IconButton(
            onPressed: () {
              values = {
                'a': '?',
                'b': '?',
                'c': '?',
                'alpha': '?',
                'betha': '?',
                'gamma': '?',
              };
              for (int i = 0; i < _inputs.length; i++)
                _inputs[i]['edit'] = false;
              controllers = {
                'a': TextEditingController(),
                'b': TextEditingController(),
                'c': TextEditingController(),
                'alpha': TextEditingController(),
                'betha': TextEditingController(),
                'gamma': TextEditingController(),
              };
              for (int i = 0; i < _inputs.length; i++) {
                controllers[_inputs[i]['value']]!.addListener(() {
                  values[_inputs[i]['value']] =
                      controllers[_inputs[i]['value']]!.text;

                  setState(() {});
                });
              }
              setState(() {});
            },
            icon: Icon(Icons.restart_alt_rounded),
          ),
          IconButton(
            onPressed: calc,
            icon: Icon(Icons.calculate_rounded),
          ),
        ],
        children: [
          ..._inputs.map(
            (e) {
              return ListItem(
                color: values[e['value']] != '?'
                    ? Theme.of(context).backgroundColor.withOpacity(0.3)
                    : null,
                shadow: e['edit'] ? true : false,
                leading: Container(
                  width: 45,
                  height: 30,
                  child: CustomPaint(
                    painter: DrawTriAngle(context, e['highlight']),
                  ),
                ),
                title: Row(
                  children: [
                    Text(
                      e['text'] + ' = ' + (e['edit'] ? '' : values[e['value']]),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Visibility(
                      visible: e['edit'],
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.1,
                        height: MediaQuery.of(context).size.height * 0.05,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: TextField(
                          controller: controllers[e['value']],
                          autofocus: true,
                          keyboardType: TextInputType.number,
                          onSubmitted: (submit) {
                            for (int i = 0; i < _inputs.length; i++)
                              _inputs[i]['edit'] = false;
                          },
                        ),
                      ),
                    ),
                    (e['value'] != 'a' &&
                            e['value'] != 'b' &&
                            e['value'] != 'c')
                        ? Text(
                            '°',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
                onClick: () {
                  for (int i = 0; i < _inputs.length; i++) {
                    _inputs[i]['edit'] = false;
                    if (values[_inputs[i]['value']] == '') {
                      values[_inputs[i]['value']] = '?';
                    }
                  }
                  e['edit'] = true;
                  setState(() {});
                },
              );
            },
          ),
          Container(
            margin: EdgeInsets.only(
              top: 20,
              bottom: 20,
              left: MediaQuery.of(context).size.width * 0.2,
              right: MediaQuery.of(context).size.width * 0.2,
            ),
            height: 1,
            color: Colors.grey.shade800,
          ),

          // everiting else

          ListItem(
            title: Text(
              'Höhe A = ' + restValues['ha']!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            color: Theme.of(context).backgroundColor.withOpacity(0.3),
            onClick: () {},
          ),
          ListItem(
            title: Text(
              'Höhe B = ' + restValues['hb']!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            color: Theme.of(context).backgroundColor.withOpacity(0.3),
            onClick: () {},
          ),
          ListItem(
            title: Text(
              'Höhe C = ' + restValues['hc']!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            color: Theme.of(context).backgroundColor.withOpacity(0.3),
            onClick: () {},
          ),
          ListItem(
            title: Text(
              'Flächeninhalt = ' + restValues['area']!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            color: Theme.of(context).backgroundColor.withOpacity(0.3),
            onClick: () {},
          ),
          ListItem(
            title: Text(
              'Radius Umkreis = ' + restValues['radOuterCircle']!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            color: Theme.of(context).backgroundColor.withOpacity(0.3),
            onClick: () {},
          ),
          ListItem(
            title: Text(
              'Radius Inkreis = ' + restValues['radInnerCircle']!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            color: Theme.of(context).backgroundColor.withOpacity(0.3),
            onClick: () {},
          ),
        ],
      ),
    );
  }
}

class DrawTriAngle extends CustomPainter {
  const DrawTriAngle(this.context, this.highlightLines);

  final BuildContext context;
  final List<int> highlightLines;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    paint.strokeWidth = 1;
    paint.color = Theme.of(context).focusColor;

    if (highlightLines.contains(1)) {
      paint.strokeWidth = 2;
      paint.color = Theme.of(context).primaryColor;
    }
    // hypotenuse
    canvas.drawLine(
      Offset(size.width * 0.1, size.height * 0.9),
      Offset(size.width * 0.9, size.height * 0.9),
      paint,
    );
    paint.color = Theme.of(context).focusColor;
    paint.strokeWidth = 1;

    if (highlightLines.contains(2)) {
      paint.strokeWidth = 2;
      paint.color = Theme.of(context).primaryColor;
    }
    // second line
    canvas.drawLine(
      Offset(size.width * 0.9, size.height * 0.9),
      Offset(size.width * 0.65, size.height * 0.2),
      paint,
    );
    paint.color = Theme.of(context).focusColor;
    paint.strokeWidth = 1;

    if (highlightLines.contains(3)) {
      paint.strokeWidth = 2;
      paint.color = Theme.of(context).primaryColor;
    }
    // third line
    canvas.drawLine(
      Offset(size.width * 0.65, size.height * 0.2),
      Offset(size.width * 0.1, size.height * 0.9),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}
