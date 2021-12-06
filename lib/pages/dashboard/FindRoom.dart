import 'package:expandiware/models/ListItem.dart';
import 'package:expandiware/models/ListPage.dart';
import 'package:expandiware/models/LoadingProcess.dart';
import 'package:expandiware/models/ProcessBar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../vplan/VPlanAPI.dart';

class FindRoom extends StatefulWidget {
  const FindRoom({Key? key}) : super(key: key);

  @override
  _FindRoomState createState() => _FindRoomState();
}

class _FindRoomState extends State<FindRoom> {
  dynamic data = [];
  bool getDataExecuted = false;
  String loadText = '';

  int process = 0;
  int totalSteps = 10;

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

  double toDouble(TimeOfDay myTime) => myTime.hour + myTime.minute / 60.0;

  void getData() async {
    getDataExecuted = true;
    dynamic _data;
    VPlanAPI vplanAPI = new VPlanAPI();

    Uri url = Uri.parse(await vplanAPI.getDayURL());

    _data = await vplanAPI.getAllOfflineData();
    if (_data.length == 0) {
      _data = await vplanAPI.getVPlanJSON(url, DateTime.now());
    }

    List<int> rooms = [];
    for (int a = 0; a < _data.length; a++) {
      for (int i = 0; i < _data[a]['data']['Klassen']['Kl'].length; i++) {
        dynamic lessons = _data[a]['data']['Klassen']['Kl'][i]['Pl']['Std'];

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
      _data = mergesort(rooms);
      // ALL ROOMS GOT

      List<int> usedRooms = [];

      List<dynamic> allRooms = [];

      setState(() => loadText = 'Vertretungsplan laden...');
      dynamic _vplanData = await vplanAPI.getVPlanJSON(url, DateTime.now());
      setState(() => loadText = 'Vertretungsplan geladen...');

      totalSteps = _vplanData['data']['Klassen']['Kl'].length;
      loadText = 'scannen...';
      for (int i = 0; i < _vplanData['data']['Klassen']['Kl'].length; i++) {
        setState(() {
          process++;
        });
        dynamic lessons = _vplanData['data']['Klassen']['Kl'][i]['Pl']['Std'];

        for (int j = 0; j < lessons.length; j++) {
          dynamic lesson =
              _vplanData['data']['Klassen']['Kl'][i]['Pl']['Std'][j];

          int bhours = int.parse((lesson['Beginn'] as String).split(':')[0]);
          int bminutes = int.parse((lesson['Beginn'] as String).split(':')[1]);

          int ehours = int.parse((lesson['Ende'] as String).split(':')[0]);
          int eminutes = int.parse((lesson['Ende'] as String).split(':')[1]);

          TimeOfDay _begin = TimeOfDay(hour: bhours, minute: bminutes);
          TimeOfDay _end = TimeOfDay(hour: ehours, minute: eminutes);
          TimeOfDay _now = TimeOfDay.now();

          // check if lesson is now
          if (toDouble(_now) >= toDouble(_begin) &&
              toDouble(_now) <= toDouble(_end)) {
            if (lesson['Ra'] != null) {
              if (isNumeric(lesson['Ra'])) {
                int room = int.parse(lesson['Ra']);
                usedRooms.add(room);
              }
            }
          }
        }
      }

      rooms = mergesort(rooms);
      usedRooms = mergesort(usedRooms);

      setState(() => loadText = 'analysieren...');
      totalSteps = rooms.length;
      process = 0;
      for (int i = 0; i < rooms.length; i++) {
        process++;
        setState(() => loadText = 'überprüfe Raum ${rooms[i]}...');

        List<dynamic> roomLessons = await getRoomLessons(
          rooms[i],
          _vplanData,
        );

        if (roomLessons != []) {
          allRooms.add({
            'room': rooms[i],
            'open': !usedRooms.contains(rooms[i]),
            'used_this_day': roomLessons.isNotEmpty,
            'room_lessons': roomLessons,
          });
        }
      }
      setState(() => loadText = 'Fertig!');
      setState(() => data = allRooms);
      setState(() => loadText = '');
    }
  }

  Future<List<dynamic>> getRoomLessons(int _room, _data) async {
    List<dynamic> res = [];

    for (int i = 0; i < _data['data']['Klassen']['Kl'].length; i++) {
      var currentClass = _data['data']['Klassen']['Kl'][i];

      for (int j = 0; j < currentClass['Pl']['Std'].length; j++) {
        var currentLesson = currentClass['Pl']['Std'][j];

        if (currentLesson['Ra'].toString() == _room.toString()) {
          res.add({
            'count': int.parse(currentLesson['St']),
            'lesson': currentLesson['Fa'],
            'class': currentClass['Kurz'],
            'teacher': currentLesson['Le'],
            'info': currentLesson['If'],
          });
        }
      }
    }
    return sort(res);
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

    return smerge(leftList, rightList);
  }

  List<dynamic> smerge(List<dynamic> leftList, List<dynamic> rightList) {
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

  void roomInfo(context, roomData) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Container(
          width: double.infinity,
          child: Stack(
            children: [
              Container(
                alignment: Alignment.topCenter,
                width: double.infinity,
                child: Container(
                  margin: const EdgeInsets.all(10),
                  width: 100,
                  height: 5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Theme.of(context).backgroundColor,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      roomData.isNotEmpty
                          ? 'Unterricht in diesem Raum'
                          : 'Heute kein Unterricht in diesem Raum',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 25),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Scrollbar(
                          isAlwaysShown: true,
                          radius: Radius.circular(100),
                          thickness: 2,
                          child: ListView(
                            physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics(),
                            ),
                            children: [
                              roomData.isEmpty
                                  ? Text(
                                      '...',
                                      textAlign: TextAlign.center,
                                    )
                                  : SizedBox(),
                              ...roomData.map(
                                (e) => ListItem(
                                  onClick: () {},
                                  color: e['info'] == null
                                      ? null
                                      : Color(0x889E1414),
                                  leading: Text(
                                    printValue('${e['count']}'),
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  title: Container(
                                    alignment: Alignment.centerLeft,
                                    width:
                                        MediaQuery.of(context).size.width * 0.1,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          printValue(e['lesson']),
                                          style: TextStyle(fontSize: 19),
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.group_rounded,
                                                  size: 16,
                                                ),
                                                SizedBox(width: 3),
                                                Text(printValue(e['class'])),
                                              ],
                                            ),
                                            SizedBox(height: 5),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.person_rounded,
                                                  size: 16,
                                                ),
                                                SizedBox(width: 3),
                                                Text(printValue(e['teacher'])),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: 50),
                                      ],
                                    ),
                                  ),
                                  subtitle: e['info'] == null
                                      ? null
                                      : Text(
                                          '${e['info']}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String printValue(String? value) {
    if (value == null) {
      return '---';
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    String time =
        '${TimeOfDay.now().hour <= 9 ? '0${TimeOfDay.now().hour}' : TimeOfDay.now().hour}:${TimeOfDay.now().minute <= 9 ? '0${TimeOfDay.now().minute}' : TimeOfDay.now().minute}';
    if (!getDataExecuted) getData();
    return Container(
      child: ListPage(
        title: 'Freie Räume - $time',
        smallTitle: true,
        actions: [
          IconButton(
            onPressed: () => setState(() {}),
            icon: Icon(Icons.sync_rounded),
          ),
        ],
        children: [
          loadText != ''
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      loadText,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Dieser Vorgang könnte eine Sekunden dauern!',
                      style: TextStyle(fontSize: 11),
                    ),
                    SizedBox(height: 15),
                    ProcessBar(
                      slow: true,
                      width: MediaQuery.of(context).size.width * 0.6,
                      totalSteps: totalSteps,
                      currentStep: process,
                    )
                  ],
                )
              : data == []
                  ? SizedBox(
                      width: 100,
                      height: 200,
                      child: Text('loading...'),
                    )
                  : GridView.count(
                      crossAxisCount: 3,
                      childAspectRatio: 3 / 2,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        ...(data as List).map(
                          (e) => InkWell(
                            onTap: () async => roomInfo(
                              context,
                              e['room_lessons'],
                            ),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              margin: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Theme.of(context).backgroundColor,
                                border: e['used_this_day']
                                    ? null
                                    : Border.all(
                                        color: Theme.of(context).primaryColor,
                                      ),
                              ),
                              child: Center(
                                child: Text(
                                  e['used_this_day']
                                      ? '${e['room']}'
                                      : '(${e['room']})',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
        ],
      ),
    );
  }
}
