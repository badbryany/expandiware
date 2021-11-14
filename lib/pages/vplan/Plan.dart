import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
  ScrollController controller = ScrollController();
  double topHeight = -10;

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
    hiddenSubjects = await vplanAPI.getHiddenCourses();

    setState(() {});

    vplanAPI.cleanVplanOfflineData();
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

    controller.addListener(() {
      if (controller.offset > 0) {
        topHeight = 0;
      } else {
        topHeight = -10;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime displayDateDateTime;
    String displayDate = '...';
    if (data != null) {
      displayDateDateTime = VPlanAPI()
          .changeDate(
            date: data['data']['date'].toString(),
            nextDay: true,
          )
          .subtract(
            Duration(days: 1),
          );
      displayDate = '${displayDateDateTime.day}.${displayDateDateTime.month}';
    }
    if (topHeight == -10) topHeight = MediaQuery.of(context).size.height * 0.17;

    return SafeArea(
      child: Container(
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.topCenter,
              color: Theme.of(context).backgroundColor,
              height: topHeight,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
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
                            Text(
                              '${data != null ? displayDate : ''}',
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                VPlanAPI()
                                    .removePlanByDate(data['data']['date']);
                                getData();
                              },
                              icon: Icon(Icons.refresh, size: 20),
                            ),
                            // courses
                            OpenContainer(
                              closedColor: Colors.transparent,
                              closedElevation: 0,
                              openColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              closedBuilder: (context, openContainer) =>
                                  IconButton(
                                onPressed: openContainer,
                                icon: Icon(
                                  Icons.settings_rounded,
                                  size: 20,
                                ),
                              ),
                              openBuilder: (context, closeContainer) => Courses(
                                classId: widget.classId,
                                updateCourses: () => getData(),
                              ),
                            ),
                            // courses
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // CONTENT
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(
                  top: topHeight != 0
                      ? MediaQuery.of(context).size.height * 0.08
                      : 0,
                ),
                padding: EdgeInsets.only(
                  top: topHeight != 0
                      ? MediaQuery.of(context).size.height * 0.07
                      : 0,
                ),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(45),
                    topRight: Radius.circular(45),
                  ),
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                alignment: Alignment.bottomCenter,
                height: MediaQuery.of(context).size.height * 0.9,
                child: data == null
                    ? Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: LinearProgressIndicator(
                          color: Theme.of(context).accentColor,
                        ),
                      )
                    : ListView(
                        physics: BouncingScrollPhysics(),
                        controller: controller,
                        children: [
                          ...data['data']['data'].map(
                            (e) {
                              if (hiddenSubjects!.contains(e['course'])) {
                                return SizedBox();
                              }
                              return ListItem(
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
                              );
                            },
                          ),
                        ],
                      ),
              ),
            ),
            /*Container(
              alignment: Alignment.topRight,
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: 
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
            ),*/*/
          ],
        ),
      ),
    );
  }
}

class Courses extends StatefulWidget {
  final String classId;
  final Function updateCourses;

  Courses({
    required this.classId,
    required this.updateCourses,
  });

  @override
  State<Courses> createState() => _CoursesState();
}

class _CoursesState extends State<Courses> {
  VPlanAPI vplanAPI = new VPlanAPI();
  List<dynamic> courses = [];

  void getData() async {
    courses = [];
    List<String> _courses = await vplanAPI.getCourses(widget.classId);

    List<String> hiddenCourses = await vplanAPI.getHiddenCourses();
    for (int i = 0; i < _courses.length; i++) {
      courses.add({
        'course': _courses[i],
        'show': !hiddenCourses.contains(_courses[i]),
      });
    }

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
          (courses.length == 0
              ? Container(
                  width: double.infinity,
                  child: Center(
                    child: Container(
                      alignment: Alignment.center,
                      width: 80,
                      child: LinearProgressIndicator(
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                )
              : Container(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.9,
                    alignment: Alignment.bottomCenter,
                    child: Scrollbar(
                      radius: Radius.circular(100),
                      child: GridView.count(
                        childAspectRatio: 3 / 2,
                        shrinkWrap: true,
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        physics: BouncingScrollPhysics(),
                        children: [
                          ...courses.map(
                            (e) => ListItem(
                              color: e['show']
                                  ? Theme.of(context).backgroundColor
                                  : Theme.of(context)
                                      .backgroundColor
                                      .withOpacity(0.4),
                              title: Center(
                                child: Text(
                                  e['course'],
                                  textAlign: TextAlign.center,
                                  style: !e['show']
                                      ? TextStyle(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          color: Colors.grey,
                                        )
                                      : null,
                                ),
                              ),
                              onClick: () {
                                setState(() {
                                  e['show'] = !e['show'];
                                });
                                if (e['show']) {
                                  vplanAPI.removeHiddenCourse(e['course']);
                                  print('remove course');
                                } else {
                                  vplanAPI.addHiddenCourse(e['course']);
                                  print('add course');
                                }
                              },
                              actionButton: Container(
                                width: 20,
                                child: AnimatedSwitcher(
                                  duration: Duration(milliseconds: 500),
                                  child: e['show']
                                      ? Icon(
                                          Icons.visibility_outlined,
                                          key: ValueKey(1),
                                          size: 18,
                                        )
                                      : Icon(
                                          Icons.visibility_off_outlined,
                                          key: ValueKey(2),
                                          size: 18,
                                        ),
                                  transitionBuilder: (
                                    Widget child,
                                    Animation<double> animation,
                                  ) =>
                                      SizeTransition(
                                    sizeFactor: animation,
                                    child: child,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
          Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.only(top: 30, left: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Theme.of(context).focusColor,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    widget.updateCourses();
                  },
                ),
                SizedBox(width: 20),
                Text(
                  'Kurse',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
