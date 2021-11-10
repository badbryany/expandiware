import 'package:flutter/material.dart';

import '../../../models/AppBar.dart';

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
      {
        'title': '--',
        'actionText': '---',
        'action': () {},
      },
    ];
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Appbar('Entwickleroptionen', SizedBox()),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.89,
                alignment: Alignment.bottomCenter,
                child: Container(
                  alignment: Alignment.topCenter,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      ...options.map(
                        (e) => Container(
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
