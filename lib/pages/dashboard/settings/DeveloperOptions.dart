import 'package:flutter/material.dart';

import '../../../models/ListPage.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class DeveloperOptions extends StatelessWidget {
  void deleteOfflineData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('offlineVPData', 'null');
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> options = [
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
        'title': '--',
        'actionText': '---',
        'action': () {},
      },
      {
        'title': '--',
        'actionText': '---',
        'action': () {},
      },
      {
        'title': '--',
        'actionText': '---',
        'action': () {},
      },
      {
        'title': '--',
        'actionText': '---',
        'action': () {},
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
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    e['title'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: e['action'],
                    child: Text(e['actionText']),
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
