import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import 'package:shared_preferences/shared_preferences.dart';

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
    dynamic newData = await VPlanAPI().getLessonsByDate(
      date: VPlanAPI().changeDate(
        date: (data == null ? '' : data['data']['date']),
        nextDay: nextDay,
      ),
      classId: widget.classId,
    );

    setState(() {
      data = {'data': newData};
    });
  }

  Future<dynamic> getVPlan(String classId) async {
    VPlanAPI vplanAPI = new VPlanAPI();

    return ({
      'data': await vplanAPI.getLessonsForToday(classId),
      'info': await vplanAPI.getDayInfo(classId),
    });
  }

  void getData() async {
    data = await getVPlan(widget.classId);
    setState(() {});
  }

  dynamic data;

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
                    'Vertretungsplan ${widget.classId}',
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
                          ...data['data']['data'].map(
                            (e) => ListItem(
                              onClick: () {},
                              color:
                                  e['info'] == null ? null : Color(0x889E1414),
                              leading: Text(
                                printValue('${e['count']}'),
                                style: TextStyle(fontSize: 18),
                              ),
                              title: Container(
                                alignment: Alignment.centerLeft,
                                width: MediaQuery.of(context).size.width * 0.1,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                          ),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () => newVP(false),
                                  icon: Icon(Icons.arrow_back),
                                ),
                                IconButton(
                                  onPressed: () => newVP(true),
                                  icon: Icon(Icons.arrow_forward),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            Container(
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
            ),
          ],
        ),
      ),
    );
  }
}
