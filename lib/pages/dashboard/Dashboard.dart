import 'package:flutter/material.dart';

import 'package:animations/animations.dart';

import './FindRoom.dart';
import './Settings.dart';
import '../../models/ListItem.dart';

class Dashboard extends StatelessWidget {
  double margin = 8;

  @override
  Widget build(BuildContext context) {
    List<dynamic> elements = [
      {
        'icon': Icon(
          Icons.place_rounded,
          color: Theme.of(context).focusColor,
        ),
        'title': 'Leeren Raum finden',
        'subtitle':
            'lädt ca. 15s!\n\nsuche einen Raum, der gerade nicht benutzt ist!',
        'link': FindRoom(),
      },
      {
        'icon': Icon(
          Icons.grade_rounded,
          color: Theme.of(context).focusColor,
        ),
        'title': 'Noten eintragen',
        'subtitle': 'Halte einen wunderbaren Überblick über deine Noten!',
        'link': SizedBox(),
      },
      {
        'icon': Icon(
          Icons.analytics_rounded,
          color: Theme.of(context).focusColor,
        ),
        'title': 'Analysen vom Stundenplan',
        'subtitle': 'Erweiterte Analysen des Unterrichtes an der Schule',
        'link': SizedBox(),
      },
      {
        'icon': Icon(
          Icons.pedal_bike_rounded,
          color: Theme.of(context).focusColor,
        ),
        'title': 'Stadtradeln',
        'subtitle': 'Nimm an dem Klima-Wettbewerb Teil!',
        'link': SizedBox(),
      },
      {
        'icon': Icon(
          Icons.settings_rounded,
          color: Theme.of(context).focusColor,
        ),
        'title': 'Einstellungen',
        'subtitle': 'weitere Einstellungen zur besseren Nutzung der App',
        'link': Settings(),
      },
    ];
    return Container(
      height: MediaQuery.of(context).size.height * 0.69,
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.1),
      alignment: Alignment.center,
      child: Scrollbar(
        thickness: 3,
        radius: Radius.circular(100),
        isAlwaysShown: true,
        child: ListView(
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          children: [
            ...elements.map(
              (e) => Center(
                child: OpenContainer(
                  closedColor: Theme.of(context).scaffoldBackgroundColor,
                  openColor: Theme.of(context).scaffoldBackgroundColor,
                  closedBuilder: (context, openContainer) => ListItem(
                    padding: 20,
                    leading: e['icon'],
                    title: Container(
                      margin: EdgeInsets.only(top: margin, bottom: margin),
                      child: Text(
                        e['title'],
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    subtitle: Container(
                      margin: EdgeInsets.only(top: margin, bottom: margin),
                      child: Text(e['subtitle']),
                    ),
                    onClick: openContainer,
                    actionButton: IconButton(
                      icon: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Theme.of(context).focusColor,
                      ),
                      onPressed: () => openContainer(),
                    ),
                  ),
                  openBuilder: (context, closeBuilder) => Center(
                    child: e['link'],
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
