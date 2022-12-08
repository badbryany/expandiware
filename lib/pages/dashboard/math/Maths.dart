import 'package:expandiware/models/ListItem.dart';
import 'package:expandiware/pages/dashboard/math/CalcTriangle.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import 'package:expandiware/models/ListPage.dart';

class Maths extends StatelessWidget {
  Maths({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> pages = [
    {
      'title': 'Allgemeines Dreieck berechnen',
      'link': CalcTriangle(),
    }
  ];

  @override
  Widget build(BuildContext context) {
    return ListPage(
      title: 'Mathe',
      children: [
        ...pages.map(
          (e) => ListItem(
            title: Text(e['title']),
            onClick: () => Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.bottomToTop,
                child: e['link'],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
