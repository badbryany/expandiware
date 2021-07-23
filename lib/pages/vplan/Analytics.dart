import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './VPlanAPI.dart';

class Analytics extends StatefulWidget {
  Analytics({
    Key? key,
    required this.vplanData,
  }) : super(key: key);

  final dynamic vplanData;

  @override
  _AnalyticsState createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  final Analysis analysis = new Analysis();

  Widget content = Text('loading...');

  void getData(context) async {
    var data = await analysis.analyseDay(widget.vplanData['data'], context);
    setState(() {
      content = data;
    });
  }

  @override
  void initState() {
    super.initState();
    getData(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          child: content,
        ),
      ),
    );
  }
}

class Analysis {
  final VPlanAPI vplanAPI = new VPlanAPI();

  Future<Widget> analyseDay(_data, context) async {
    var data = (await vplanAPI.getVPlanJSON(
      Uri.parse(
        await vplanAPI.getDayURL(),
      ),
      DateTime.now(),
    ))['data']['Klassen'];

    List<dynamic> teachers = [];

    for (int i = 0; i < _data.length; i++) {
      bool add = true;
      for (int j = 0; j < teachers.length; j++) {
        if (teachers[j]['name'].contains(_data[i]['teacher'])) {
          add = false;
        }
      }
      if (add) {
        teachers.add({
          'name': _data[i]['teacher'],
          'lessons': [],
        });
      }
    }

    for (int i = 0; i < data['Kl'].length; i++) {
      var element = data['Kl'][i]['Pl'];
      for (int j = 0; j < element['Std'].length; j++) {
        var lesson = element['Std'][j];
        for (int y = 0; y < teachers.length; y++) {
          if (teachers[y]['name'] == lesson['Le']) {
            teachers[y]['lessons'].add({
              'lesson': lesson['Fa'],
              'place': lesson['Ra'],
            });
          }
        }
      }
    }
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      child: ListView(
        children: [
          ...teachers.map(
            (e) => Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text('Lehrer ${e['name']}'),
                  ...e['lessons'].map(
                      (e) => Text('Fach: ${e['lesson']}\nRaum: ${e['place']}')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/*ListTile(
            leading: Text(e['name']),
            title: Text('schon ${e['lessons'].length} Stunden Unterricht'),
          ), */