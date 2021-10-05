import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http_auth/http_auth.dart' as http_auth;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml2json/xml2json.dart';

class VPlanAPI {
  int schoolnumber = 0; // = prefs.getString("vplanSchoolnumber");
  String vplanUsername = ''; // = prefs.getString("vplanUsername");
  String vplanPassword = ''; // = prefs.getString("vplanPassword");

  Future<void> login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    schoolnumber = int.parse(prefs.getString("vplanSchoolnumber")!);
    vplanUsername = prefs.getString("vplanUsername")!;
    vplanPassword = prefs.getString("vplanPassword")!;
  }

  Future<List<String>> getClassList() async {
    this.login();

    List<String> classList = [];

    dynamic data = await getVPlanJSON(
      Uri.parse(await getDayURL()),
      DateTime.now(),
    );

    for (int i = 0; i < data['data']['Klassen']['Kl'].length; i++) {
      classList.add(data['data']['Klassen']['Kl'][i]['Kurz']);
    }
    return classList;
  }

  void addHiddenCourse(String lesson) async {
    if (lesson == '---') {
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String>? hiddenSubjects = prefs.getStringList('hiddenSubjects');
    if (hiddenSubjects == null) {
      hiddenSubjects = [];
    }
    hiddenSubjects.add(lesson);

    prefs.setStringList('hiddenSubjects', hiddenSubjects);
  }

  void removeHiddenCourse(String course) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String>? hiddenSubjects = prefs.getStringList('hiddenSubjects');
    if (hiddenSubjects == null) {
      hiddenSubjects = [];
    }
    List<String> newCourses = [];

    for (int i = 0; i < hiddenSubjects.length; i++) {
      if (course != hiddenSubjects[i]) {
        newCourses.add(hiddenSubjects[i]);
      }
    }

    prefs.setStringList('hiddenSubjects', newCourses);
  }

  Future<List<String>> getHiddenCourses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String>? hiddenSubjects = prefs.getStringList('hiddenSubjects');
    if (hiddenSubjects == null) {
      hiddenSubjects = [];
    }

    return hiddenSubjects;
  }

  Future<bool> searchForOfflineData(DateTime vpDate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var offlineVPData = prefs.getString('offlineVPData');

    if (offlineVPData == null || offlineVPData == 'null') {
      return false;
    } else {
      List<dynamic> jsonData = jsonDecode(offlineVPData);
      for (int i = 0; i < jsonData.length; i++) {
        if (compareDate(vpDate, jsonData[i]['data']['Kopf']['DatumPlan'])) {
          //print('we have an offline backup!');
          return true;
        }
      }
      return false;
    }
  }

  Future<dynamic> getAllOfflineData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var offlineVPData = prefs.getString('offlineVPData');

    if (offlineVPData == null || offlineVPData == 'null') {
      return [];
    } else {
      //print('offlineVPData');
      return jsonDecode(offlineVPData);
    }
  }

  Future<List<String>> getCourses(String classId) async {
    dynamic data = await getVPlanJSON(
      Uri.parse(await getDayURL()),
      DateTime.now(),
    );

    dynamic classes = data['data']['Klassen']['Kl'];
    dynamic currentClass;
    for (int i = 0; i < classes.length; i++) {
      if (classes[i]['Kurz'] == classId) {
        currentClass = classes[i];
      }
    }

    List<String> courses = [];

    for (int j = 0; j < currentClass['Kurse']['Ku'].length; j++) {
      courses.add(currentClass['Kurse']['Ku'][j]['KKz']);
    }

    return courses;
  }

  Future<dynamic> getVPlanJSON(Uri url, DateTime vpDate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<dynamic> data = [];

    bool offlinePlan = await searchForOfflineData(vpDate);

    if (offlinePlan) {
      data = jsonDecode(prefs.getString('offlineVPData')!);
      for (int i = 0; i < data.length; i++) {
        if (compareDate(vpDate, data[i]['data']['Kopf']['DatumPlan'])) {
          //print('we have an offline backup!');
          print('used offline data');
          return {
            'date': data[i]['date'],
            'data': data[i]['data'],
          };
        }
      }
    }

    Xml2Json xml2json = Xml2Json();
    await login();
    var client = http_auth.BasicAuthClient(vplanUsername, vplanPassword);

    try {
      return client.get(url).then((res) {
        String source = Utf8Decoder().convert(res.bodyBytes);
        xml2json.parse(source);
        String stringVPlan = xml2json.toParker();

        var jsonVPlan = jsonDecode(stringVPlan);
        data.add({
          'date': jsonVPlan['VpMobil']['Kopf']['DatumPlan'],
          'data': jsonVPlan['VpMobil'],
        });

        //-------------------------------------
        String? stringData = prefs.getString('offlineVPData');
        if (stringData == null || stringData == 'null') {
          stringData = '[]';
        }

        List<dynamic> jsonData = jsonDecode(stringData);
        // check if vplan already exist
        bool add = true;
        for (var i = 0; i < jsonData.length; i++) {
          if (compareDate(vpDate, jsonData[i]['data']['Kopf']['DatumPlan'])) {
            add = false;
          }
        }

        if (add) {
          jsonData.add(data.last);
          //print('added');
        } else {
          //print('plan already exist...');
        }

        stringData = jsonEncode(jsonData);

        prefs.setString('offlineVPData', stringData);
        //-------------------------------------

        return data.last;
      });
    } catch (identifier) {
      print("Fehler bei getVplanJson");
    }
  }

  Future getDayInfo(String classId) async {
    await login();

    Uri url = Uri.parse(
      'https://www.stundenplan24.de/${this.schoolnumber}/mobil/mobdaten/Klassen.xml',
    );

    var pureVPlan = await getVPlanJSON(url, DateTime.now());
    return pureVPlan['ZusatzInfo'];
  }

  bool compareDate(DateTime datetime, String date2) {
    DateTime date1 = changeDate(
      date: date2,
      nextDay: true,
    ).subtract(
      Duration(days: 1),
    );
    // changeDate() parses the ugly date String to DateTime
    // changeDate also adds 1 day; that Day was subtracted throw subtract()

    if (date1.day == datetime.day) {
      if (date1.month == datetime.month) {
        if (date1.year == datetime.year) {
          return true;
        }
      }
    }
    return false;
  }

  Future<dynamic> getLessonsForToday(String classId) async {
    await login();

    Uri url = Uri.parse(await getDayURL());

    var pureVPlan = await getVPlanJSON(url, DateTime.now());

    var jsonVPlan =
        pureVPlan['data']['Klassen']['Kl']; //get the XML data of the URL

    List<dynamic> lessons = parseVPlanXML(jsonVPlan, classId);
    return {
      'date': pureVPlan['date'],
      'data': lessons,
    };
  }

  Future<String> getDayURL() async {
    await login();
    return 'https://www.stundenplan24.de/${this.schoolnumber}/mobil/mobdaten/Klassen.xml';
  }

  Future<String> getURL(DateTime date) async {
    await login();
    return 'https://www.stundenplan24.de/${this.schoolnumber}/mobil/mobdaten/Klassen.xml';
  }

  List<dynamic> parseVPlanXML(var jsonVPlan, String classId) {
    List<dynamic> _outpuLessons = [];

    if (jsonVPlan == null) {
      return List.empty();
    }
    for (int i = 0; i < jsonVPlan.length; i++) {
      // scan all classes
      if (jsonVPlan[i]['Kurz'] == classId) {
        // check if it is the right class
        var _lessons = jsonVPlan[i]['Pl']['Std'];

        for (int j = 0; j < _lessons.length; j++) {
          // parse the lessons
          var currentLesson = _lessons[j];
          _outpuLessons.add({
            'count': currentLesson['St'],
            'lesson': currentLesson['Fa'],
            'teacher': currentLesson['Le'],
            'place': currentLesson['Ra'],
            'begin': currentLesson['Beginn'],
            'end': currentLesson['Ende'],
            'info': currentLesson['If'],
            'course': currentLesson['Ku2'],
          });
        }
      }
    }
    return _outpuLessons;
  }

  Future<dynamic> getLessonsByDate({
    required DateTime date,
    required String classId,
  }) async {
    await login();

    String stringDate = parseDate(date);
    Uri url = Uri.parse(
      'https://www.stundenplan24.de/${this.schoolnumber}/mobil/mobdaten/PlanKl$stringDate.xml',
    );
    var pureVPlan = await getVPlanJSON(url, date);

    var jsonVPlan =
        pureVPlan['data']['Klassen']['Kl']; //get the XML data of the URL

    List<dynamic> lessons = parseVPlanXML(jsonVPlan, classId);

    return {
      'date': pureVPlan['date'],
      'data': lessons,
    };
  }

  String parseDate(DateTime _date) {
    String stringDate = '';

    stringDate += '${_date.year}';
    stringDate += _date.month < 10 ? '0${_date.month}' : _date.month.toString();
    stringDate += _date.day < 10 ? '0${_date.day}' : _date.day.toString();

    return stringDate;
  }

  DateTime changeDate({required String date, required bool nextDay}) {
    List dateArray = date.split(',')[1].replaceAll('.', '').trim().split(' ');
    switch (dateArray[1]) {
      case 'Januar':
        dateArray[1] = '01';
        break;
      case 'Februar':
        dateArray[1] = '02';
        break;
      case 'März':
        dateArray[1] = '03';
        break;
      case 'April':
        dateArray[1] = '04';
        break;
      case 'Mai':
        dateArray[1] = '05';
        break;
      case 'Juni':
        dateArray[1] = '06';
        break;
      case 'Juli':
        dateArray[1] = '07';
        break;
      case 'August':
        dateArray[1] = '08';
        break;
      case 'September':
        dateArray[1] = '09';
        break;
      case 'Oktober':
        dateArray[1] = '10';
        break;
      case 'November':
        dateArray[1] = '11';
        break;
      case 'Dezember':
        dateArray[1] = '12';
        break;
    }

    DateTime vpDate = DateTime.parse(
      '${dateArray[2]}-${dateArray[1]}-${dateArray[0]}',
    );

    // morgen
    if (nextDay) {
      int days = 1;
      if (vpDate.weekday == 5) {
        days = 3;
      }
      vpDate = vpDate.add(Duration(days: days));
    }
    // gestern
    if (!nextDay) {
      int days = 1;
      if (vpDate.weekday == 1) {
        days = 3;
      }
      vpDate = vpDate.subtract(Duration(days: days));
    }
    return vpDate;
  }

  Future<List<String>> getClasses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getStringList('classes') == null) {
      prefs.setStringList('classes', []);
    }

    return prefs.getStringList('classes')!;
  }

  void cleanVplanOfflineData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? offlineVPData = prefs.getString('offlineVPData');

    if (offlineVPData == null) {
      return;
    }

    List<dynamic> vplanData = jsonDecode(offlineVPData);
    List<dynamic> cleanedPlan = [];
    for (int i = 0; i < vplanData.length; i++) {
      if (!cleanedPlan.contains(vplanData[i])) {
        cleanedPlan.add(vplanData[i]);
      } else {
        print('already there');
      }
    }
    prefs.setString('offlineVPData', jsonEncode(cleanedPlan));
  }
}
