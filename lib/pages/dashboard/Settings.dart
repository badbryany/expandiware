import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../../models/ListItem.dart';

import 'settings/VPlanLogin.dart';
import 'settings/DeveloperOptions.dart';

class Settings extends StatelessWidget {
  List<String> colors = [
    '2b97ef',
    '76ac32',
    'f28528',
    '258786',
    'f4a53c',
    '0baba9',
    '9951b4',
    '5f98f2',
  ];
  List<dynamic> settingPages = [
    {
      'colorIndex': 0,
      'title': 'Zugangsdaten',
      'icon': Icons.lock_outline_rounded,
      'subtitle': 'stundenplan24 Nutzerdaten',
      'link': VPlanLogin(),
    },
    {
      'colorIndex': 1,
      'title': '----',
      'icon': Icons.language_rounded,
      'subtitle': '----',
      'link': SizedBox(),
    },
    {
      'colorIndex': 2,
      'title': '----',
      'icon': Icons.fingerprint_rounded,
      'subtitle': '----',
      'link': SizedBox(),
    },
    {
      'colorIndex': 3,
      'title': '----',
      'icon': Icons.help,
      'subtitle': '----',
      'link': SizedBox(),
    },
    {
      'colorIndex': 4,
      'title': '----',
      'icon': Icons.manage_accounts_rounded,
      'subtitle': '----',
      'link': SizedBox(),
    },
    {
      'colorIndex': 5,
      'title': 'Entwickleroptionen',
      'icon': Icons.developer_mode_rounded,
      'subtitle': '...',
      'link': DeveloperOptions(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Stack(
        children: [
          Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.only(top: 30, left: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Theme.of(context).focusColor,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                SizedBox(width: 20),
                Text(
                  'Einstellungen',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              alignment: Alignment.center,
              child: Scrollbar(
                child: ListView(
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  children: [
                    ...settingPages.map((e) => Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          margin: EdgeInsets.all(10),
                          child: Center(
                            child: ListTile(
                              onTap: () => Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  child: e['link'],
                                ),
                              ),
                              leading: Container(
                                margin: EdgeInsets.all(4),
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: Color(
                                    int.parse('0xff${colors[e['colorIndex']]}'),
                                  ),
                                ),
                                child: Icon(e['icon']),
                              ),
                              title: Padding(
                                padding: EdgeInsets.all(4),
                                child: Text(
                                  e['title'],
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              subtitle: Padding(
                                padding: EdgeInsets.all(4),
                                child: Text(
                                  e['subtitle'],
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w100,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
