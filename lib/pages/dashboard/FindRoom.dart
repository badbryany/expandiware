import 'package:expandiware/pages/vplan/VPlan.dart';
import 'package:flutter/material.dart';

import '../vplan/VPlanAPI.dart';

class FindRoom extends StatefulWidget {
  const FindRoom({Key? key}) : super(key: key);

  @override
  _FindRoomState createState() => _FindRoomState();
}

class _FindRoomState extends State<FindRoom> {
  dynamic data = [];

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

    String stringDate = vplanAPI.parseDate(DateTime.now());
    /*Uri url = Uri.parse(
      'https://www.stundenplan24.de/${vplanAPI.schoolnumber}/mobil/mobdaten/PlanKl$stringDate.xml',
    );*/

    Uri url = Uri.parse(await vplanAPI.getDayURL());

    data = await vplanAPI.getVPlanJSON(url, DateTime.now());

    List<int> rooms = [];

    for (int i = 0; i < data['data']['Klassen']['Kl'].length; i++) {
      dynamic lessons = data['data']['Klassen']['Kl'][i]['Pl']['Std'];

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

    data = mergesort(rooms);
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
            height: MediaQuery.of(context).size.height * 0.7,
            alignment: Alignment.center,
            child: ListView(
              shrinkWrap: true,
              children: [
                Text(
                  'all rooms:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...data.map(
                  (e) => Container(
                    child: Text('$e'),
                  ),
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.only(top: 30, left: 10),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                color: Theme.of(context).focusColor,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
