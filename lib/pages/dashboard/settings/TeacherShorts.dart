import 'package:flutter/material.dart';

import '../../../models/ListPage.dart';
import '../../vplan/VPlanAPI.dart';

class TeacherShorts extends StatelessWidget {
  const TeacherShorts({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListPage(
        title: 'Lehrer Kürzel erstzen',
        children: [
          Text(
            'kommt bald',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
