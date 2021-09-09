import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/modals.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:focused_menu/focused_menu.dart';

import '../../models/ListItem.dart';

import './VPlanAPI.dart';

import './Analytics.dart';

class Plan extends StatefulWidget {
  final String classId;

  const Plan({
    Key? key,
    required this.classId,
  }) : super(key: key);

  @override
  _PlanState createState() => _PlanState();
}

class _PlanState extends State<Plan> {
  VPlanAPI vplanAPI = new VPlanAPI();

  void newVP(bool nextDay) async {
    String? date = data['data']['date'];
    setState(() {
      data = null;
    });
    dynamic newData = await VPlanAPI().getLessonsByDate(
      date: VPlanAPI().changeDate(
        date: (date == null ? '' : date),
        nextDay: nextDay,
      ),
      classId: widget.classId,
    );

    setState(() {
      data = {'data': newData};
    });
  }

  void getData() async {
    VPlanAPI vplanAPI = new VPlanAPI();

    data = {
      'data': await vplanAPI.getLessonsForToday(widget.classId),
      'info': await vplanAPI.getDayInfo(widget.classId),
    };
    hiddenSubjects = await vplanAPI.getHiddenSubjects();

    setState(() {});
  }

  dynamic data;
  List<String>? hiddenSubjects;

  String printValue(String? value) {
    if (value == null) {
      return '---';
    }
    return value;
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        child: Stack(
          children: [
            Container(
              alignment: Alignment.topCenter,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back),
                  ),
                  Text(
                    '${widget.classId}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 15),
                  Text('${data != null ? data['data']['date'].toString() : ''}')
                ],
              ),
            ),
            Center(
              child: Container(
                margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.05,
                ),
                alignment: Alignment.bottomCenter,
                height: MediaQuery.of(context).size.height * 0.9,
                child: data == null
                    ? Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: LinearProgressIndicator(),
                      )
                    : ListView(
                        physics: BouncingScrollPhysics(),
                        children: [
                          ...data['data']['data'].map((e) {
                            if (hiddenSubjects!.contains(e['lesson'])) {
                              return SizedBox();
                            }
                            return FocusedMenuHolder(
                              animateMenuItems: true,
                              duration: Duration(milliseconds: 100),
                              onPressed: () {},
                              menuBoxDecoration: BoxDecoration(
                                color: Theme.of(context).backgroundColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              menuItems: [
                                FocusedMenuItem(
                                  backgroundColor:
                                      Theme.of(context).backgroundColor,
                                  title: Text(
                                    '${e['lesson']} verbergen',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  trailingIcon:
                                      Icon(Icons.remove_red_eye_rounded),
                                  onPressed: () async {
                                    VPlanAPI vplanAPI = new VPlanAPI();

                                    vplanAPI.addHiddenSubject(e['lesson']);
                                    hiddenSubjects =
                                        await vplanAPI.getHiddenSubjects();

                                    setState(() {});
                                  },
                                ),
                              ],
                              child: ListItem(
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
                                                Icons.location_on_rounded,
                                                size: 16,
                                              ),
                                              SizedBox(width: 3),
                                              Text(printValue(e['place'])),
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
                            );
                          }),
                        ],
                      ),
              ),
            ),
            Container(
              alignment: Alignment.topRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => newVP(false),
                    icon: Icon(Icons.arrow_back),
                  ),
                  SizedBox(width: 5),
                  IconButton(
                    onPressed: () => newVP(true),
                    icon: Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            ),
            /*Container(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: Analytics(
                      vplanData: data,
                    ),
                  ),
                ),
                icon: Icon(Icons.analytics_rounded),
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}
