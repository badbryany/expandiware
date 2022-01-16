import 'dart:convert';

import 'package:http_auth/http_auth.dart' as http_auth;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml2json/xml2json.dart';
import 'package:xml/xml.dart';

class VPlanAPI {
  int schoolnumber = 0; // = prefs.getString("vplanSchoolnumber");
  String vplanUsername = ''; // = prefs.getString("vplanUsername");
  String vplanPassword = ''; // = prefs.getString("vplanPassword");

  Future<void> login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getString('customUrl') != null &&
        prefs.getString('customUrl') != '') {
      return;
    }
    schoolnumber = int.parse(prefs.getString("vplanSchoolnumber")!);
    vplanUsername = prefs.getString("vplanUsername")!;
    vplanPassword = prefs.getString("vplanPassword")!;
  }

  Future<dynamic> getClassList() async {
    this.login();

    List<String> classList = [];

    dynamic data = await getVPlanJSON(
      Uri.parse(await getDayURL()),
      DateTime.now(),
    );

    if (data['error'] != null) {
      return data;
    }

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

  void removePlanByDate(String date) async {
    this.cleanVplanOfflineData();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String offlineVPData = prefs.getString('offlineVPData')!;

    List<dynamic> vplanData = jsonDecode(offlineVPData);
    List<dynamic> newVplanData = [];
    for (int i = 0; i < vplanData.length; i++) {
      if (vplanData[i]['date'] != date) {
        newVplanData.add(vplanData[i]);
      }
    }
    prefs.setString('offlineVPData', jsonEncode(newVplanData));
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
          print('we have an offline backup!');
          print('used offline data');
          return {
            'date': data[i]['date'],
            'data': data[i]['data'],
            'info': data[i]['info'],
          };
        }
      }
    }

    Xml2Json xml2json = Xml2Json();
    await login();
    var client;

    if (prefs.getString('customUrl') != null &&
        prefs.getString('customUrl') != '') {
      url = Uri.parse(prefs.getString('customUrl')! + 'mobdaten/Klassen.xml');
    } else {
      client = http_auth.BasicAuthClient(vplanUsername, vplanPassword);
    }
    try {
      return ((prefs.getString('customUrl') != null &&
                  prefs.getString('customUrl') != '')
              ? http.Client()
              : client)
          .get(url)
          .then((res) {
        if (res.body
            .toString()
            .contains('Die eingegebene Schulnummer wurde nicht gefunden.')) {
          return {'error': 'schoolnumber'};
        }
        if (res.body.toString().contains('Error 401 - Unauthorized')) {
          return {'error': '401'};
        }
        String source = Utf8Decoder().convert(res.bodyBytes);
        xml2json.parse(source);
        String stringVPlan = xml2json.toParker();

        var jsonVPlan = jsonDecode(stringVPlan);

        if (jsonVPlan['VpMobil'] == null) {
          return {};
        }

        /* NEW XML PARSER */

        String cleanXml = res.body;

        cleanXml = cleanXml
            .toString()
            .replaceFirst('ï', '')
            .replaceFirst('»', '')
            .replaceFirst('¿', '');

        final XmlDocument xmlVPlan = XmlDocument.parse(cleanXml);

        Iterable<XmlElement> ziZeilen = xmlVPlan
            .getElement('VpMobil')!
            .getElement('ZusatzInfo')!
            .findAllElements('ZiZeile');

        /* NEW XML PARSER */

        data.add({
          'date': jsonVPlan['VpMobil']['Kopf']['DatumPlan'],
          'data': jsonVPlan['VpMobil'],
          'info': ziZeilen.map((e) => e.innerText),
        });
        //-------------------------------------
        List<String>? stringData = prefs.getStringList('offlineVPData');
        stringData ??= [];

        // check if vplan already exist
        bool add = true;
        for (var i = 0; i < stringData.length; i++) {
          if (compareDate(vpDate, jsonDecode(stringData[i])['date'])) {
            add = false;
          }
        }

        if (add) {
          stringData.add(jsonEncode(data.last));
          //print('added');
        } else {
          //print('plan already exist...');
        }

        prefs.setStringList('offlineVPData', stringData);
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

    try {
      var pureVPlan = await getVPlanJSON(url, DateTime.now());
      return pureVPlan['ZusatzInfo'];
    } catch (e) {}
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

    var pureVPlan;
    try {
      pureVPlan = await getVPlanJSON(url, DateTime.now());
    } catch (e) {
      print(e);
      return {'error': 'no internet'};
    }

    if (pureVPlan == {}) {
      return {};
    }
    if (pureVPlan['error'] != null) {
      return pureVPlan;
    }

    var jsonVPlan =
        pureVPlan['data']['Klassen']['Kl']; //get the XML data of the URL

    List<dynamic> lessons = await parseVPlanXML(jsonVPlan, classId);
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

  Future<List<dynamic>> parseVPlanXML(var jsonVPlan, String classId) async {
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
            'teacher': await replaceTeacherShort(currentLesson['Le']),
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

    var pureVPlan;
    try {
      pureVPlan = await getVPlanJSON(url, date);
    } catch (e) {
      return {'error': 'no internet'};
    }

    if (pureVPlan.toString() == '{}') {
      return {};
    }
    if (pureVPlan['error'] != null) {
      return pureVPlan;
    }
    var jsonVPlan =
        pureVPlan['data']['Klassen']['Kl']; //get the XML data of the URL

    List<dynamic> lessons = await parseVPlanXML(jsonVPlan, classId);

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

  DateTime parseStringDatatoDateTime(String date) {
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

    return DateTime.parse(
      '${dateArray[2]}-${dateArray[1]}-${dateArray[0]}',
    );
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

  Future<List<String>> getTeachers() async {
    List<String> teachers = [];
    var data = (await getVPlanJSON(
      Uri.parse(
        await getDayURL(),
      ),
      DateTime.now(),
    ))['data'];
    for (int i = 0; i < data['Klassen']['Kl'].length; i++) {
      var currentClass = data['Klassen']['Kl'][i];
      for (int j = 0; j < currentClass['Pl']['Std'].length; j++) {
        var currentLesson = currentClass['Pl']['Std'][j];
        if (currentLesson['Le'] != null) {
          bool add = true;
          for (int j = 0; j < teachers.length; j++) {
            if (teachers[j] == currentLesson['Le']) {
              add = false;
            }
          }
          if (add) teachers.add(currentLesson['Le']);
        }
      }
    }
    return teachers;
  }

  Future<String?> replaceTeacherShort(String? teacherShort) async {
    if (teacherShort == null) return teacherShort;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getString('teacherShorts') == null ||
        prefs.getString('teacherShorts') == '') return teacherShort;

    List<dynamic> teacherShorts = jsonDecode(prefs.getString('teacherShorts')!);

    for (int i = 0; i < teacherShorts.length; i++) {
      if (teacherShorts[i]['short'] == teacherShort) {
        if (teacherShorts[i]['realName'] != '')
          return teacherShorts[i]['realName'];
      }
    }
    return teacherShort;
  }
}
