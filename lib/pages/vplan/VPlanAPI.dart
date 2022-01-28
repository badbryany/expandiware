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
    if (prefs.getStringList('offlineVPData') == null ||
        prefs.getStringList('offlineVPData') == []) {
      return false;
    }
    List<dynamic> jsonData = [];

    jsonData = prefs
        .getStringList('offlineVPData')!
        .map((e) => jsonDecode(e))
        .toList();

    for (int i = 0; i < jsonData.length; i++) {
      if (compareDate(vpDate, jsonData[i]['data']['Kopf']['DatumPlan'])) {
        // print('we have an offline backup!');
        return true;
      }
    }
    return false;
  }

  void removePlanByDate(String date) async {
    this.cleanVplanOfflineData();

    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<dynamic> vplanData = [];
    prefs
        .getStringList('offlineVPData')!
        .map((e) => vplanData.add(jsonDecode(e)));

    List<String> newVplanData = [];
    for (int i = 0; i < vplanData.length; i++) {
      if (vplanData[i]['date'] != date) {
        newVplanData.add(jsonEncode(vplanData[i]));
      }
    }
    prefs.setStringList('offlineVPData', newVplanData);
  }

  Future<dynamic> getAllOfflineData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? offlineVPData = prefs.getStringList('offlineVPData');

    if (offlineVPData == null) {
      return [];
    } else {
      //print('offlineVPData');
      return offlineVPData.map((e) => jsonDecode(e));
    }
  }

  Future<List<dynamic>> getCourses(String classId) async {
    List<dynamic> data = (await getVPlanJSON(
      Uri.parse(await getDayURL()),
      DateTime.now(),
    ))['courses'];

    List<dynamic> returnData = [];

    for (int i = 0; i < data.length; i++) {
      if (data[i]['classId'] == classId) {
        returnData.add(data[i]);
      }
    }
    return returnData;
  }

  Future<dynamic> getVPlanJSON(Uri url, DateTime vpDate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<dynamic> data = [];

    bool offlinePlan = await searchForOfflineData(vpDate);

    if (offlinePlan) {
      List<String> offlineStrings = prefs.getStringList('offlineVPData')!;
      offlineStrings.map((e) => data.add(jsonDecode(e)));

      for (int i = 0; i < data.length; i++) {
        if (compareDate(vpDate, data[i]['data']['Kopf']['DatumPlan'])) {
          print('we have an offline backup!');
          print('used offline data');
          return {
            'date': data[i]['date'],
            'data': data[i]['data'],
            'courses': data[i]['courses'],
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

        dynamic jsonVPlan = jsonDecode(stringVPlan);

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

        List<dynamic> courses = [];

        Iterable<XmlElement> classes = xmlVPlan
            .getElement('VpMobil')!
            .getElement('Klassen')!
            .findAllElements('Kl');

        for (int i = 0; i < classes.length; i++) {
          Iterable<XmlElement> _courses =
              classes.elementAt(i).getElement('Kurse')!.findAllElements('Ku');
          String classId = classes.elementAt(i).getElement('Kurz')!.innerText;
          for (int j = 0; j < _courses.length; j++) {
            XmlElement kkz = _courses.elementAt(j).getElement('KKz')!;
            courses.add(
              {
                'classId': classId,
                'course': kkz.innerText,
                'teacher': kkz.attributes.first.value
              },
            );
          }
        }

        /* NEW XML PARSER */
        data.add({
          'date': jsonVPlan['VpMobil']['Kopf']['DatumPlan'],
          'data': jsonVPlan['VpMobil'],
          'info': ziZeilen.map((e) => e.innerText).toList(),
          'courses': courses,
        });
        //-------------------------------------
        List<String>? stringData = prefs.getStringList('offlineVPData');
        stringData ??= [];

        // check if vplan already exist
        bool add = true;
        for (int i = 0; i < stringData.length; i++) {
          ziZeilen.map((e) => e.innerText.toString()).toList();
          if (compareDate(vpDate, jsonDecode(stringData[i])['date'])) {
            add = false;
          }
        }

        if (add) {
          stringData.add(jsonEncode(data.last));
          // print('added');
        } else {
          // print('plan already exist...');
        }

        prefs.setStringList('offlineVPData', stringData);
        //print(prefs.getStringList('offlineVPData'));
        //-------------------------------------

        return data.last;
      });
    } catch (e) {
      print("Fehler bei getVplanJson");
    }
  }

  bool compareDate(DateTime datetime, String date2) {
    DateTime date1 = parseStringDatatoDateTime(date2);

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

    dynamic pureVPlan;
    try {
      pureVPlan = await getVPlanJSON(url, DateTime.now());
    } catch (e) {
      // print('line 316 in VPlanAPI.dart --> $e');
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
      'info': pureVPlan['info'],
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

  Future<List<dynamic>> parseVPlanXML(dynamic jsonVPlan, String classId) async {
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

    // add lessons that are not there
    for (int i = 0; i < int.parse(_outpuLessons.last['count']); i++) {
      if (int.parse(_outpuLessons[i]['count']) != i + 1) {
        _outpuLessons.insert(i, {
          'count': i + 1,
          'lesson': '---',
          'teacher': '---',
          'place': '---',
          'begin': '---',
          'end': '---',
          'info': null,
          'course': '---',
        });
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

    dynamic pureVPlan;
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
    dynamic jsonVPlan =
        pureVPlan['data']['Klassen']['Kl']; //get the XML data of the URL

    List<dynamic> lessons = await parseVPlanXML(jsonVPlan, classId);

    return {
      'date': pureVPlan['date'],
      'data': lessons,
      'info': pureVPlan['info'],
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
    List<String>? offlineVPData = prefs.getStringList('offlineVPData');

    if (offlineVPData == null || offlineVPData == []) {
      return;
    }

    List<dynamic> vplanData = [];
    for (int i = 0; i < offlineVPData.length; i++) {
      vplanData.add(jsonDecode(offlineVPData[i]));
    }
    List<dynamic> cleanedPlan = [];

    for (int i = 0; i < vplanData.length; i++) {
      bool addIt = true;
      for (int j = 0; j < cleanedPlan.length; j++) {
        if (cleanedPlan[j]['data']['Kopf']['DatumPlan'] ==
            vplanData[i]['data']['Kopf']['DatumPlan']) {
          addIt = false;
        }
      }
      if (addIt) cleanedPlan.add(vplanData[i]);
    }
    prefs.setStringList(
      'offlineVPData',
      cleanedPlan.map((e) => jsonEncode(e)).toList(),
    );
  }

  Future<List<String>> getTeachers() async {
    List<String> teachers = [];
    dynamic data = (await getVPlanJSON(
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
