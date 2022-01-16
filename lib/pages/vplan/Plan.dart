import 'package:animations/animations.dart';
import 'package:expandiware/models/Button.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:lottie/lottie.dart';

import '../../models/ListItem.dart';
import '../../models/ListPage.dart';
import '../../models/LoadingProcess.dart';
import '../../pages/dashboard/settings/VPlanLogin.dart';

import './VPlanAPI.dart';

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
      data = 'loading';
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
    setState(() => data = 'loading'); // show loadng animation
    VPlanAPI vplanAPI = new VPlanAPI();

    dynamic _lessons = await vplanAPI.getLessonsForToday(widget.classId);
    if (_lessons['error'] != null) {
      setState(() => data = _lessons);
      return;
    }
    data = {
      'data': _lessons,
      'info': _lessons['info'],
    };
    hiddenSubjects = await vplanAPI.getHiddenCourses();

    setState(() {});

    vplanAPI.cleanVplanOfflineData();
  }

  dynamic data = 'loading';
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
    DateTime displayDateDateTime;
    String displayDate = '...';
    if (data == null) {
      return Text('no vplan');
    }
    if (data.toString().contains('error')) {
      String errorText = '';
      Widget extraWidget = SizedBox();
      switch (data['error']) {
        case '401':
          errorText = 'Der Benutzername oder das Passwort ist falsch!';
          extraWidget = Lottie.asset(
            'assets/animations/lock.json',
            height: 120,
          );
          break;
        case 'schoolnumber':
          errorText =
              'Kein Vertretungsplan verfügbar!\n\n oder falsche Schulnummer';
          extraWidget = Lottie.asset(
            'assets/animations/nodata.json',
            height: 120,
          );
          break;
        case 'no internet':
          errorText = 'Keine Internetverbindung';
          extraWidget = Lottie.asset(
            'assets/animations/wifi.json',
            height: 120,
          );
          break;
        default:
          switch (data['data']['error']) {
            case '401':
              errorText = 'Der Benutzername oder das Passwort ist falsch!';
              extraWidget = Lottie.asset(
                'assets/animations/lock.json',
                height: 120,
              );
              break;
            case 'schoolnumber':
              errorText =
                  'Kein Vertretungsplan verfügbar!\n\n oder falsche Schulnummer';
              extraWidget = Lottie.asset(
                'assets/animations/nodata.json',
                height: 120,
              );
              break;
            case 'no internet':
              errorText = 'Keine Internetverbindung';
              extraWidget = Lottie.asset(
                'assets/animations/wifi.json',
                height: 120,
              );
              break;
          }
      }
      return ListPage(
        title: '${widget.classId}',
        animate: true,
        actions: [
          IconButton(
            onPressed: () => getData(),
            icon: Icon(Icons.sync_rounded),
          ),
        ],
        children: [
          extraWidget,
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(left: 10, right: 10),
            child: Text(
              errorText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.red.shade300,
              ),
            ),
          ),
          SizedBox(height: 30),
          Button(
            text: 'Zugangsdaten',
            onPressed: () => Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                child: VPlanLogin(),
              ),
            ),
          ),
        ],
      );
    }
    if (data.toString().contains('data')) {
      displayDateDateTime =
          VPlanAPI().parseStringDatatoDateTime(data['data']['date'].toString());
      displayDate = '${displayDateDateTime.day}.${displayDateDateTime.month}';
    }
    return ListPage(
      title: '${widget.classId} - $displayDate',
      animate: true,
      smallTitle: true,
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                VPlanAPI().removePlanByDate(data['data']['date']);
                getData();
              },
              icon: Icon(Icons.refresh, size: 20),
            ),
            // courses
            OpenContainer(
              closedColor: Colors.transparent,
              closedElevation: 0,
              openColor: Theme.of(context).scaffoldBackgroundColor,
              closedBuilder: (context, openContainer) => IconButton(
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
      children: [
        ...(data == 'loading'
            ? [
                Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: LoadingProcess(),
                )
              ]
            : (data['data']['data'] as List).map(
                (e) {
                  if (hiddenSubjects!.contains(e['course'])) {
                    return SizedBox();
                  }
                  return ListItem(
                    onClick: () {},
                    color: e['info'] == null
                        ? null
                        : Color.fromARGB(158, 119, 18, 18),
                    leading: Text(
                      printValue('${e['count']}'),
                      style: TextStyle(fontSize: 18),
                    ),
                    title: Container(
                      alignment: Alignment.centerLeft,
                      width: MediaQuery.of(context).size.width * 0.1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            printValue(e['lesson']),
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
                                  Text(printValue(e['place'])),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
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
              ).toList()),
        data != 'loading'
            ? Container(
                margin: EdgeInsets.only(
                  top: 15,
                  bottom: 15,
                  left: MediaQuery.of(context).size.width * 0.1,
                  right: MediaQuery.of(context).size.width * 0.1,
                ),
                color: Theme.of(context).backgroundColor,
                height: 2,
              )
            : const SizedBox(),
        data != 'loading'
            ? (data['info'] != null && data['info'].toString() != ''
                ? ListItem(
                    padding: 20,
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...(data['info'] as List).map(
                          (e) => Text(
                            '$e',
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                    onClick: () {},
                  )
                : ListItem(
                    title: Text('keine Zusatzinformationen'),
                    onClick: () {},
                  ))
            : SizedBox(),
      ],
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
  bool? seeAll = null;

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
    return ListPage(
      title: 'Kurse',
      actions: [
        IconButton(
          icon: Icon(Icons.visibility_rounded),
          onPressed: () {
            for (int i = 0; i < courses.length; i++) {
              courses[i]['show'] = true;
              vplanAPI.removeHiddenCourse(courses[i]['course']);
            }
            setState(() {});
          },
        ),
        IconButton(
          icon: Icon(Icons.visibility_off_rounded),
          onPressed: () {
            for (int i = 0; i < courses.length; i++) {
              courses[i]['show'] = false;
              vplanAPI.addHiddenCourse(courses[i]['course']);
            }
            setState(() {});
          },
        ),
      ],
      children: [
        GridView.count(
          childAspectRatio: 3 / 2.3,
          shrinkWrap: true,
          crossAxisCount: 3,
          crossAxisSpacing: 1,
          mainAxisSpacing: 1,
          physics: BouncingScrollPhysics(),
          children: [
            ...courses.map(
              (e) => ListItem(
                color: e['show']
                    ? Theme.of(context).backgroundColor
                    : Theme.of(context).backgroundColor.withOpacity(0.4),
                title: Center(
                  child: Text(
                    e['course'],
                    textAlign: TextAlign.center,
                    style: !e['show']
                        ? TextStyle(
                            decoration: TextDecoration.lineThrough,
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
                  alignment: Alignment.center,
                  width: 17,
                  margin: const EdgeInsets.only(bottom: 15),
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 500),
                    child: e['show']
                        ? Icon(
                            Icons.visibility_outlined,
                            key: ValueKey(1),
                            size: 16,
                          )
                        : Icon(
                            Icons.visibility_off_outlined,
                            key: ValueKey(2),
                            size: 16,
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
      ],
    );
  }
}
