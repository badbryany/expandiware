import 'package:expandiware/models/Button.dart';
import 'package:expandiware/models/InputField.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../models/ListPage.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class DeveloperOptions extends StatelessWidget {
  void deleteOfflineData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setStringList('offlineVPData', []);
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> options = [
      {
        'title': 'Entwickleroptionen deaktivieren',
        'actionText': 'deaktivieren',
        'action': () => SharedPreferences.getInstance().then(
              (instance) => instance.setBool('developerOptions', false),
            ),
      },
      {
        'title': 'Offline Vertretungsplan löschen',
        'actionText': 'löschen',
        'action': deleteOfflineData,
      },
      {
        'title': 'Stop Background service',
        'actionText': 'stop',
        'action': () =>
            FlutterBackgroundService().sendData({'action': 'stopService'}),
      },
      {
        'title': 'Clear all SharedPreferences',
        'actionText': 'clear',
        'action': () => SharedPreferences.getInstance()
            .then((instance) => instance.clear()),
      },
      {
        'title': 'remove Teacher shorts',
        'actionText': 'remove',
        'action': () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('teacherShorts', '');
        },
      },
      {
        'title': 'clear notified dates',
        'actionText': 'clear',
        'action': () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setStringList('notified', []);
        },
      },
      {
        'title': 'clear news feeds',
        'actionText': 'clear',
        'action': () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('newsfeeds', '[]');
        },
      },
      {
        'title': 'toggle Material You',
        'actionText': 'change',
        'action': () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('materialyou', !prefs.getBool('materialyou')!);
          Fluttertoast.showToast(
            msg:
                'prefs.getBool(\'materialyou\') => ${prefs.getBool('materialyou')}',
          );
        },
      },
      {
        'title': 'delete lessontimes',
        'actionText': 'delete',
        'action': () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('lessontimes', '[]');
        },
      },
      {
        'title': 'firstTime to true',
        'actionText': 'set',
        'action': () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('firstTime', true);
        },
      },
      {
        'title': 'analysis code',
        'actionText': 'enter',
        'action': () async {
          TextEditingController _controller = new TextEditingController();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Text('enter analisis code'),
              content: Container(
                alignment: Alignment.center,
                height: 100,
                child: InputField(
                  controller: _controller,
                  labelText: 'analisis code',
                ),
              ),
              actions: [
                Button(
                  text: 'enter',
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    if (_controller.text == 'JuIGZxo0Na') {
                      prefs.setBool('analisis', false);
                      Fluttertoast.showToast(msg: 'no analisis anymore');
                    } else {
                      Fluttertoast.showToast(msg: 'incorrect code');
                    }
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      },
    ];
    return Scaffold(
      body: ListPage(
        title: 'Entwickleroptionen',
        children: [
          ...options.map(
            (e) => Container(
              margin: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    e['title'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Button(
                    text: e['actionText'],
                    onPressed: e['action'],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
