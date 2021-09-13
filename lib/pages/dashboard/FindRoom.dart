import 'package:expandiware/models/ListItem.dart';
import 'package:expandiware/pages/vplan/VPlan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import '../vplan/VPlanAPI.dart';

import '../../models/AppBar.dart';

class FindRoom extends StatefulWidget {
  const FindRoom({Key? key}) : super(key: key);

  @override
  _FindRoomState createState() => _FindRoomState();
}

class _FindRoomState extends State<FindRoom> {
  dynamic data = [];

  DateTime DATE = DateTime.now();

  bool isNumeric(String s) {
    return double.tryParse(s) != null;
  }

  List<int> mergesort(List<int> list) {
    if (list.length <= 1) {
      return list;
    }

    int half = (list.length / 2).toInt();

    List<int> leftList = [];
    for (int i = 0; i < half; i++) {
      leftList.add(list[i]);
    }

    List<int> rightList = [];
    for (int i = 0; i < list.length - half; i++) {
      int count = i + half;
      rightList.add(list[count]);
    }

    leftList = mergesort(leftList);
    rightList = mergesort(rightList);

    return merge(leftList, rightList);
  }

  List<int> merge(List<int> leftList, List<int> rightList) {
    List<int> newList = [];

    while (leftList.isNotEmpty && rightList.isNotEmpty) {
      if (leftList[0] <= rightList[0]) {
        int value = leftList[0];

        newList.add(leftList[0]);
        leftList.remove(value);
      } else {
        int value = rightList[0];

        newList.add(rightList[0]);
        rightList.remove(value);
      }
    } // end of while

    while (leftList.isNotEmpty) {
      int value = leftList[0];

      newList.add(leftList[0]);
      leftList.remove(value);
    }

    while (rightList.isNotEmpty) {
      int value = rightList[0];

      newList.add(rightList[0]);
      rightList.remove(value);
    }

    return newList;
  }

  void getData() async {
    VPlanAPI vplanAPI = new VPlanAPI();

    //String stringDate = vplanAPI.parseDate(DateTime.now());
    DateTime dateTimeDate = DateTime.parse('2021-09-09 08:30:00');
    String stringDate =
        vplanAPI.parseDate(DateTime.parse('2021-09-09 08:30:00'));

    Uri url = Uri.parse(await vplanAPI.getDayURL());

    data = await vplanAPI.getAllOfflineData();
    if (data.length == 0) {
      data = await vplanAPI.getVPlanJSON(url, DateTime.now());
    }

    List<int> rooms = [];
    for (int a = 0; a < data.length; a++) {
      for (int i = 0; i < data[a]['data']['Klassen']['Kl'].length; i++) {
        dynamic lessons = data[a]['data']['Klassen']['Kl'][i]['Pl']['Std'];

        for (int j = 0; j < lessons.length; j++) {
          String? room = lessons[j]['Ra'];

          if (room != null && room != 'Gang') {
            String editRoom = room
                .replaceAll('H1', '')
                .replaceAll('H2', '')
                .replaceAll('H3', '')
                .replaceAll('E', '');
            if (int.tryParse(editRoom) != null) {
              if (!rooms.contains(int.parse(editRoom))) {
                rooms.add(int.parse(editRoom));
              }
            }
          }
        }
      }
    }
    setState(() {
      data = mergesort(rooms);
    });
    // ALL ROOMS GOT

    List<int> freeRooms = [];

    List<String> classes = await vplanAPI.getClassList();
    List<dynamic> classLessons = [];
    for (int i = 0; i < classes.length; i++) {
      String currentClass = classes[i];

      classLessons.add(
        (await vplanAPI.getLessonsForToday(currentClass))['data'],
      );
    }

    for (int j = 0; j < classLessons.length; j++) {
      List<dynamic> lessons = classLessons[j];
      for (var i = 0; i < lessons.length; i++) {
        dynamic lesson = lessons[i];
        if (lesson['place'] != 'null' || lesson['place'] != null) {
          // check if lesson is in the right time
          DateTime currentTime = DATE;
          String hour = currentTime.hour.toString().length == 2
              ? currentTime.hour.toString()
              : '0' + currentTime.hour.toString();
          String minute = currentTime.minute.toString().length == 2
              ? currentTime.minute.toString()
              : '0' + currentTime.minute.toString();

          DateTime begin = DateTime.parse('2004-09-22 ${lesson['begin']}:00');
          DateTime end = DateTime.parse('2004-09-22 ${lesson['end']}:00');

          DateTime currentDateTime = DateTime.parse(
            '2004-09-22 $hour:$minute:00',
          );

          if (isNumeric(lesson['place'].toString())) {
            if (currentDateTime.isAfter(begin)) {
              if (currentDateTime.isBefore(end)) {
                freeRooms.add(int.parse(lesson['place']));
              }
            }
          }
        }
      }
    }

    data = mergesort(freeRooms);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Stack(
        children: [
          Container(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.9,
              child: GridView.count(
                crossAxisCount: 3,
                childAspectRatio: 3 / 2,
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                children: [
                  ...data.map(
                    (e) => Container(
                      padding: EdgeInsets.all(8),
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(context).backgroundColor,
                      ),
                      child: Center(
                        child: Text(
                          '$e',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Appbar(
            'Raum finden',
            SizedBox(),
          ),
        ],
      ),
    );
  }
}
