import 'dart:async';
import 'dart:math';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:expandiware/pages/vplan/VPlanAPI.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

void onStart() async {
  WidgetsFlutterBinding.ensureInitialized();
  final service = FlutterBackgroundService();
  service.onDataReceived.listen((event) {
    if (event!["action"] == "setAsForeground") {
      service.setForegroundMode(true);
      return;
    }
    if (event["action"] == "setAsBackground") {
      service.setForegroundMode(false);
    }
    if (event["action"] == "stopService") {
      service.stopBackgroundService();
    }
  });

  // bring to foreground
  service.setForegroundMode(true);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getInt('interval') == null) prefs.setInt('interval', 300);
  int? _interval = prefs.getInt('interval')!;
  print('start background service');
  Timer.periodic(Duration(seconds: _interval), vplanNotifications);

  service.setNotificationInfo(
    title: 'expandiware interval: ${_interval}s',
    content: '',
  );
}

void vplanNotifications(Timer _timer) async {
  print('background process');
  SharedPreferences prefs = await SharedPreferences.getInstance();

  if (prefs.getString('prefClass') == null)
    prefs.setString('prefClass', (await VPlanAPI().getClasses())[0].toString());
  if (prefs.getString('hour') == null) prefs.setString('hour', '0');
  if (prefs.getString('minute') == null) prefs.setString('minute', '0');
  if (prefs.getBool('remindDayBefore') == null)
    prefs.setBool('remindDayBefore', true);
  if (prefs.getBool('remindOnlyChange') == null)
    prefs.setBool('remindOnlyChange', true);

  String _classId = prefs.getString('prefClass')!;
  DateTime _today = DateTime.now();
  int _remindHour = int.parse(prefs.getString('hour')!);
  int _remindMinutes = int.parse(prefs.getString('minute')!);
  bool _remindDayBefore = prefs.getBool('remindDayBefore')!;
  DateTime _vplanDate;
  bool _remindOnlyChange = prefs.getBool('remindOnlyChange')!;

  dynamic data = await VPlanAPI().getLessonsForToday(_classId);

  if (data == null || data.toString() == '{}') {
    // no school today
    data = await VPlanAPI().getLessonsByDate(
      date: _today.add(Duration(days: 1)),
      classId: _classId,
    );
    if (data == null || data.toString() == '{}') {
      // no school tomorrow
      return;
    }
  }
  if (!prefs.getBool('intiligentNotification')!) return;

  _vplanDate = VPlanAPI()
      .changeDate(date: data['date'], nextDay: true)
      .subtract(Duration(days: 1));

  List<dynamic> _lessons = [];
  if (_remindDayBefore) {
    if (_today.add(Duration(days: 1)).isAfter(_vplanDate)) {
      if (_today.hour >= _remindHour &&
          (_today.minute >= _remindMinutes || _today.hour > _remindHour)) {
        List<String> _courses = await VPlanAPI().getHiddenCourses();
        for (int i = 0; i < data['data'].length; i++) {
          if (!_courses.contains(data['data'][i]['course'])) {
            _lessons.add(data['data'][i]);
          }
        }
      }
    }
  } else {
    // not _remindDayBefore
    if (_today.day == _vplanDate.day &&
        _today.month == _vplanDate.month &&
        _today.year == _vplanDate.year) {
      if (_today.hour == _remindHour && _today.minute == _remindMinutes) {
        List<String> _courses = await VPlanAPI().getHiddenCourses();
        for (int i = 0; i < data['data'].length; i++) {
          if (!_courses.contains(data['data'][i]['course'])) {
            _lessons.add(data['data'][i]);
          }
        }
      }
    }
  }

  _lessons = _lessons.reversed.toList();

  bool reminded = false;

  if (prefs.getStringList('notified') == null)
    prefs.setStringList('notified', []);

  print(prefs.getStringList('notified'));

  if (!prefs.getStringList('notified')!.contains(data['date'])) {
    for (int i = 0; i < _lessons.length; i++) {
      if (!_remindOnlyChange) {
        createNotification(
          id: i,
          title: _lessons[i]['lesson'],
          body: _lessons[i]['place'] + ' ' + _lessons[i]['teacher'],
          subtitle: 'expandiware',
        );
      } else {
        print('foo');
        if (!(_lessons[i]['info'] == '' || _lessons[i]['info'] == null)) {
          print('bar');
          reminded = true;
          createNotification(
            id: i,
            title: _lessons[i]['lesson'],
            body: _lessons[i]['place'] + ' ' + _lessons[i]['teacher'],
            subtitle: 'expandiware',
          );
        }
      }
    }

    if (!reminded) {
      print('baz');
      createNotification(
        id: 10000000,
        title: 'keine Veränderungen',
        body: ' ',
        subtitle: 'expandiware',
        normal: true,
      );
    }

    List<String> _addList = prefs.getStringList('notified')!;
    _addList.add(data['date']);
    prefs.setStringList('notified', _addList);
  }
}

void createNotification({
  required String title,
  required String body,
  required String subtitle,
  bool? normal,
  int? id,
}) {
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'vplan_notification',
        channelName: 'Vertretungsplan Benachrichtigungen',
        channelDescription: 'Benachrichtigungen zu Änderungen und Fächern',
        //defaultColor: Color(0xFF9D50DD),
      )
    ],
  );
  id ??= Random().nextInt(100000000);
  normal ??= false;
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: id,
      channelKey: 'vplan_notification',
      title: title,
      body: body,
      summary: subtitle,
      color: Colors.transparent,
      notificationLayout:
          normal ? NotificationLayout.BigText : NotificationLayout.Messaging,
    ),
  );
}
