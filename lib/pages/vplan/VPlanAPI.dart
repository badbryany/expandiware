import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http_auth/http_auth.dart' as http_auth;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml2json/xml2json.dart';

class VPlanAPI {
  int schoolnumber = 0; // = prefs.getString("vplanSchoolnumber");
  String vplanUsername = ''; // = prefs.getString("vplanUsername");
  String vplanPassword = ''; // = prefs.getString("vplanPassword");

  final List<String> classes = [
    '05a',
    '05b',
    '05c',
    '05d',
    '05e',
    '06a',
    '06b',
    '06c',
    '06d',
    '06e',
    '07a',
    '07b',
    '07c',
    '07d',
    '07e',
    '08a',
    '08b',
    '08c',
    '08d',
    '08e',
    '09a',
    '09b',
    '09c',
    '09d',
    '09e',
    '10a',
    '10b',
    '10c',
    '10d',
    '10e',
    'JG11',
    /*'11.1',
    '11.2',
    '11.3',
    '11.4',
    '11.5',
    '11.6',
    '11.7',
    '11.8',*/
    'JG12',
    /*'12.1',
    '12.2',
    '12.3',
    '12.4',
    '12.5',
    '12.6',
    '12.7',
    '12.8',*/
  ];

  Future<void> login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    schoolnumber = int.parse(prefs.getString("vplanSchoolnumber")!);
    vplanUsername = prefs.getString("vplanUsername")!;
    vplanPassword = prefs.getString("vplanPassword")!;
  }

  void addHiddenSubject(String lesson) async {
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

  Future<List<String>> getHiddenSubjects() async {
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
        if (compareDate(vpDate.subtract(Duration(days: 1)),
            jsonData[i]['data']['Kopf']['zeitstempel'])) {
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
      print('offlineVPData');
      return jsonDecode(offlineVPData);
    }
  }

  Future<dynamic> getVPlanJSON(Uri url, DateTime vpDate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<dynamic> data = [];

    bool offlinePlan = await searchForOfflineData(vpDate);

    if (offlinePlan) {
      data = jsonDecode(prefs.getString('offlineVPData')!);
      for (int i = 0; i < data.length; i++) {
        if (compareDate(vpDate.subtract(Duration(days: 1)),
            data[i]['data']['Kopf']['zeitstempel'])) {
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
          if (compareDate(vpDate.subtract(Duration(days: 1)),
              jsonData[i]['data']['Kopf']['zeitstempel'])) {
            add = false;
          }
        }

        if (add) {
          jsonData.add(data.last);
          print('added');
        } else {
          print('plan already exist...');
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
    List<String> dateString = date2.split('.');
    // dateString[0] => day
    // dateString[1] => month
    // dateString[2] => year
    String year = dateString[2].split(',')[0];
    if (int.parse(dateString[0]) == datetime.day) {
      if (int.parse(dateString[1]) == datetime.month) {
        if (int.parse(year) == datetime.year) {
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
            'info': currentLesson['If']
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
      vpDate = vpDate.add(Duration(days: 1));
    }
    // gestern
    if (!nextDay) {
      vpDate = vpDate.subtract(Duration(days: 1));
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

  Widget parseError(String error, var data) {
    bool exit = false;

    Color errorColor = Colors.red;
    double iconSize = 40;

    String errorMessage;
    Icon errorIcon;

    if (this.schoolnumber == null && !exit) {
      errorMessage = 'Gib deine Schulnummer ein.';
      errorIcon = Icon(Icons.lock, color: errorColor, size: iconSize);
      exit = true;
    } else if (this.vplanUsername == null && !exit) {
      errorMessage = 'Gib deinen Benutzernamen ein.';
      errorIcon = Icon(Icons.lock, color: errorColor, size: iconSize);
      exit = true;
    } else if (this.vplanPassword == null && !exit) {
      errorMessage = 'Gib dein Passwort ein.';
      errorIcon = Icon(Icons.lock, color: errorColor, size: iconSize);
      exit = true;
    } else if (error.contains(
            'HandshakeException: Handshake error in client (OS Error:') &&
        !exit) {
      errorMessage = 'Die Anfrage wurde blockiert.';
      errorIcon = Icon(Icons.block, color: errorColor, size: iconSize);
      exit = true;
    } else if (error
            .contains('Invalid response, unexpected 10 in reason phrase') &&
        !exit) {
      errorMessage = 'Die Daten konnten nicht abgerufen werden.';
      errorIcon = Icon(Icons.error, color: errorColor, size: iconSize);
      exit = true;
    } else if (data == null || data.length == 0 && !exit) {
      errorColor = Colors.white;
      errorMessage = 'keine Daten';
      errorIcon = Icon(Icons.block, color: errorColor, size: iconSize);
      exit = true;
    } else if (data == null ||
        error.contains("The method '[]' was called on null") && !exit) {
      errorColor = Colors.white;
      errorMessage = 'keine Daten';
      errorIcon = Icon(Icons.block, color: errorColor, size: iconSize);
      exit = true;
    } else {
      errorMessage = 'An diesem Tag gibt es keine Daten.';
      errorIcon = Icon(Icons.error, color: errorColor, size: iconSize);
      exit = true;
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          errorIcon,
          SizedBox(height: 10),
          Text(
            errorMessage,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: errorColor,
            ),
          ),
          SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Gehe auf '),
              Icon(Icons.settings, size: 15),
              Text(' um die Benutzerdaten einzugeben.'),
            ],
          ),
        ],
      ),
    );
  }
}

/*
  return [
      {
        'count': '1',
        'lesson': 'DE',
        'teacher': 'Taschler',
        'place': '124',
        'begin': '07:50',
        'end': '08:35',
        'info': ''
      },
      {
        'count': '2',
        'lesson': 'DE',
        'teacher': 'Taschler',
        'place': '124',
        'begin': '08:35',
        'end': '09:20',
        'info': ''
      },
      {
        'count': '3',
        'lesson': 'BIO',
        'teacher': 'Demuth',
        'place': '154',
        'begin': '07:50',
        'end': '09:20',
        'info': ''
      },
      {
        'count': '4',
        'lesson': 'BIO',
        'teacher': 'Demuth',
        'place': '154',
        'begin': '07:50',
        'end': '09:20',
        'info': 'Frau Demuth tut die Stimme weh...'
      },
      {
        'count': '5',
        'lesson': 'KU',
        'teacher': 'Tash',
        'place': '124',
        'begin': '07:50',
        'end': '09:20',
        'info': ''
      },
      {
        'count': '6',
        'lesson': 'RE',
        'teacher': 'Tash',
        'place': '124',
        'begin': '07:50',
        'end': '09:20',
        'info': ''
      },
      {
        'count': '7',
        'lesson': 'RE',
        'teacher': 'Tasch',
        'place': '124',
        'begin': '07:50',
        'end': '09:20',
        'info': ''
      },
    ];
 */