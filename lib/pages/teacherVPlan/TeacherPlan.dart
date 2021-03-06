import 'package:flutter/material.dart';

import '../vplan/VPlanAPI.dart';
import '../../models/ListItem.dart';
import '../../models/ListPage.dart';
import '../../models/LoadingProcess.dart';

class TeacherPlan extends StatefulWidget {
  const TeacherPlan({
    Key? key,
    required this.teacher,
  }) : super(key: key);

  final String teacher;

  @override
  _TeacherPlanState createState() => _TeacherPlanState();
}

class _TeacherPlanState extends State<TeacherPlan> {
  String date = '';
  List<dynamic> res = [];
  String teacherName = '';

  void getData() async {
    VPlanAPI vplanAPI = new VPlanAPI();

    teacherName = (await vplanAPI.replaceTeacherShort(widget.teacher))!;

    var data = (await vplanAPI.getVPlanJSON(
      Uri.parse(
        await vplanAPI.getDayURL(),
      ),
      DateTime.now(),
    ))['data'];
    setState(() {
      date = data['Kopf']['DatumPlan'];
    });
    for (int i = 0; i < data['Klassen']['Kl'].length; i++) {
      var currentClass = data['Klassen']['Kl'][i];
      for (int j = 0; j < currentClass['Pl']['Std'].length; j++) {
        var currentLesson = currentClass['Pl']['Std'][j];
        if (currentLesson['Le'].toString().toLowerCase() ==
            widget.teacher.toLowerCase()) {
          res.add({
            'count': int.parse(currentLesson['St']),
            'lesson': currentLesson['Fa'],
            'class': currentClass['Kurz'],
            'place': currentLesson['Ra'],
          });
        }
      }
    }
    res = sort(res);

    setState(() {});
  }

  List<dynamic> sort(List<dynamic> list) {
    if (list.length <= 1) {
      return list;
    }

    int half = (list.length / 2).toInt();

    List<dynamic> leftList = [];
    for (int i = 0; i < half; i++) {
      leftList.add(list[i]);
    }

    List<dynamic> rightList = [];
    for (int i = 0; i < list.length - half; i++) {
      int count = i + half;
      rightList.add(list[count]);
    }

    leftList = sort(leftList);
    rightList = sort(rightList);

    return merge(leftList, rightList);
  }

  List<dynamic> merge(List<dynamic> leftList, List<dynamic> rightList) {
    List<dynamic> newList = [];

    while (leftList.isNotEmpty && rightList.isNotEmpty) {
      if (leftList[0]['count'] <= rightList[0]['count']) {
        var value = leftList[0];

        newList.add(leftList[0]);
        leftList.remove(value);
      } else {
        var value = rightList[0];

        newList.add(rightList[0]);
        rightList.remove(value);
      }
    } // end of while

    while (leftList.isNotEmpty) {
      var value = leftList[0];

      newList.add(leftList[0]);
      leftList.remove(value);
    }

    while (rightList.isNotEmpty) {
      var value = rightList[0];

      newList.add(rightList[0]);
      rightList.remove(value);
    }

    return newList;
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    String displayDate = '...';
    DateTime displayDateDateTime = DateTime.now();
    try {
      displayDateDateTime = VPlanAPI().parseStringDatatoDateTime(date);
    } catch (e) {}

    displayDate = '${displayDateDateTime.day}.${displayDateDateTime.month}';
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: ListPage(
        title: 'Stunden von $teacherName- $displayDate',
        smallTitle: true,
        children: res.length == 0
            ? [
                Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: LoadingProcess(),
                )
              ]
            : res
                .map(
                  (e) => ListItem(
                    leading: Text('${e['count']}'),
                    title: Container(
                      alignment: Alignment.centerLeft,
                      width: MediaQuery.of(context).size.width * 0.1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            e['lesson'],
                            style: TextStyle(fontSize: 19),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    size: 16,
                                  ),
                                  SizedBox(width: 3),
                                  Text(e['place']),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.group_rounded,
                                    size: 16,
                                  ),
                                  SizedBox(width: 3),
                                  Text(e['class']),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(width: 50),
                        ],
                      ),
                    ),
                    onClick: () {},
                  ),
                )
                .toList(),
      ),
    );
  }
}
