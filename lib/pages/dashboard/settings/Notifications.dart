import 'package:flutter/material.dart';

import '../../../models/ListItem.dart';
import '../../../models/ListPage.dart';

import '../../vplan/VPlanAPI.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_background_service/flutter_background_service.dart';
import '../../../background_service.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  Widget heading(String text) => Container(
        margin: EdgeInsets.all(13),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: !_automaticLoad ? Colors.grey.shade500 : null,
          ),
        ),
      );

  bool _automaticLoad = false;
  bool _intiligentNotification = false;
  String _prefClass = '';
  int? _hour;
  int? _minute;
  bool _remindDayBefore = true;
  int? _interval;
  bool _remindOnlyChange = true;

  List<String> _classes = [];

  void restartBackgroundSevice() {
    FlutterBackgroundService().sendData({'action': 'stopService'});

    WidgetsFlutterBinding.ensureInitialized();
    FlutterBackgroundService.initialize(onStart);
  }

  void changeAutomaticLoad() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _automaticLoad = !_automaticLoad;
    prefs.setBool('automaticLoad', _automaticLoad);
    setState(() {});

    if (_automaticLoad) {
      WidgetsFlutterBinding.ensureInitialized();
      FlutterBackgroundService.initialize(onStart);
    } else {
      FlutterBackgroundService().sendData({'action': 'stopService'});
    }

    // peset if all is null
    if (prefs.getString('prefClass') == null)
      prefs.setString(
          'prefClass', (await VPlanAPI().getClasses())[0].toString());
    if (prefs.getString('hour') == null) prefs.setString('hour', '0');
    if (prefs.getString('minute') == null) prefs.setString('minute', '0');
    if (prefs.getBool('remindDayBefore') == null)
      prefs.setBool('remindDayBefore', true);
    if (prefs.getBool('intiligentNotification') == null)
      prefs.setBool('intiligentNotification', false);
    if (prefs.getInt('interval') == null) prefs.setInt('interval', 300);
    if (prefs.getBool('remindOnlyChange') == null)
      prefs.setBool('remindOnlyChange', true);
  }

  void changeNotification() async {
    if (!_automaticLoad) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    _intiligentNotification = !_intiligentNotification;
    prefs.setBool('intiligentNotification', _intiligentNotification);
    setState(() {});
    restartBackgroundSevice();
  }

  void changeTime() async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    _hour = time.hour;
    _minute = time.minute;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('hour', _hour.toString());
    prefs.setString('minute', _minute.toString());
    setState(() {});
    restartBackgroundSevice();
  }

  void changeRemindDayBefore() async {
    if (!_automaticLoad) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    _remindDayBefore = !_remindDayBefore;
    prefs.setBool('remindDayBefore', _remindDayBefore);
    setState(() {});
    restartBackgroundSevice();
  }

  void changeRemindOnlyChange() async {
    if (!_automaticLoad) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    _remindOnlyChange = !_remindOnlyChange;
    prefs.setBool('remindOnlyChange', _remindOnlyChange);
    setState(() {});
    restartBackgroundSevice();
  }

  void getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _classes = await VPlanAPI().getClasses();

    _automaticLoad = prefs.getBool('automaticLoad')!;
    _intiligentNotification = prefs.getBool('intiligentNotification')!;
    _prefClass = prefs.getString('prefClass')!;
    _hour = int.parse(prefs.getString('hour')!);
    _minute = int.parse(prefs.getString('minute')!);
    _remindDayBefore = prefs.getBool('remindDayBefore')!;
    _interval = prefs.getInt('interval')!;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    getData();
    return Scaffold(
      body: SafeArea(
        child: ListPage(
          title: 'Notifications',
          children: [
            heading('Allgemein'),
            ListItem(
              title: Text('Vertretungsplan automatisch laden'),
              onClick: () => changeAutomaticLoad(),
              actionButton: Switch.adaptive(
                value: _automaticLoad,
                onChanged: (change) => changeAutomaticLoad(),
                activeColor: Theme.of(context).accentColor,
              ),
            ),
            ListItem(
              title: Text(
                'Intelligente Benachrichtigungen',
                style: TextStyle(
                  color: !_automaticLoad ? Colors.grey.shade500 : null,
                ),
              ),
              color: !_automaticLoad ? Color(0xff161616) : null,
              onClick: changeNotification,
              actionButton: Switch.adaptive(
                value: _intiligentNotification,
                onChanged: (change) => changeNotification(),
                activeColor: Theme.of(context).accentColor,
              ),
            ),
            ListItem(
              title: Text(
                'Bevorzugte Klasse',
                style: TextStyle(
                  color: !_automaticLoad ? Colors.grey.shade500 : null,
                ),
              ),
              onClick: () {},
              color: !_automaticLoad ? Color(0xff161616) : null,
              actionButton: DropdownButton(
                onChanged: (change) async {
                  setState(() => _prefClass = change.toString());
                  SharedPreferences.getInstance().then(
                    (instance) => instance.setString('prefClass', _prefClass),
                  );
                  restartBackgroundSevice();
                },
                value: _prefClass,
                dropdownColor: Theme.of(context).backgroundColor,
                icon: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.expand_more_rounded,
                    size: 15,
                    color: !_automaticLoad ? Colors.grey.shade500 : null,
                  ),
                ),
                items: [
                  ..._classes.map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: !_automaticLoad ? Colors.grey.shade500 : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ---------------------
            /* heading('Zeit der Erinnerung'),
            ListItem(
              title: Text(
                'Stunde',
                style: TextStyle(
                  color: !_automaticLoad ? Colors.grey.shade500 : null,
                ),
              ),
              color: !_automaticLoad ? Color(0xff161616) : null,
              onClick: changeTime,
              actionButton: _hour == null
                  ? Icon(
                      Icons.schedule_rounded,
                      color: !_automaticLoad ? Colors.grey.shade500 : null,
                    )
                  : Text('${_hour}h'),
            ),
            ListItem(
              title: Text(
                'Minute',
                style: TextStyle(
                  color: !_automaticLoad ? Colors.grey.shade500 : null,
                ),
              ),
              color: !_automaticLoad ? Color(0xff161616) : null,
              onClick: changeTime,
              actionButton: _hour == null
                  ? Icon(
                      Icons.schedule_rounded,
                      color: !_automaticLoad ? Colors.grey.shade500 : null,
                    )
                  : Text('${_minute}m'),
            ),
            ListItem(
              title: Text(
                'Erinnerung am Tag davor',
                style: TextStyle(
                  color: !_automaticLoad ? Colors.grey.shade500 : null,
                ),
              ),
              color: !_automaticLoad ? Color(0xff161616) : null,
              onClick: () {},
              actionButton: Switch.adaptive(
                value: _remindDayBefore,
                onChanged: (change) => changeRemindDayBefore(),
                activeColor: Theme.of(context).accentColor,
              ),
            ), */
            // ---------------------
            heading('Sonstiges'),
            ListItem(
              title: Text(
                'Aufrufsintervall',
                style: TextStyle(
                  color: !_automaticLoad ? Colors.grey.shade500 : null,
                ),
              ),
              color: !_automaticLoad ? Color(0xff161616) : null,
              onClick: () => showDialog(
                context: context,
                builder: (context) => SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: AlertDialog(
                    title: heading('Aufrufsintervall'),
                    content: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1,
                      child: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) =>
                            Slider(
                          onChanged: (change) =>
                              setState(() => _interval = change.toInt()),
                          onChangeEnd: (change) =>
                              SharedPreferences.getInstance().then(
                            (instance) =>
                                instance.setInt('interval', change.toInt()),
                          ),
                          value: _interval!.toDouble(),
                          max: 3600,
                          min: 10,
                          label: '${_interval}s',
                          divisions: 3600,
                          activeColor:
                              Theme.of(context).accentColor.withOpacity(0.8),
                          inactiveColor:
                              Theme.of(context).accentColor.withOpacity(0.1),
                          thumbColor: Theme.of(context).accentColor,
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('ok'),
                      ),
                    ],
                    backgroundColor: Theme.of(context).backgroundColor,
                  ),
                ),
              ),
              actionButton: Text(
                '${_interval}s',
                style: TextStyle(
                  color: !_automaticLoad ? Colors.grey.shade500 : null,
                ),
              ),
            ),
            ListItem(
              title: Text(
                'Nur bei Änderung erinnern',
                style: TextStyle(
                  color: !_automaticLoad ? Colors.grey.shade500 : null,
                ),
              ),
              onClick: changeRemindOnlyChange,
              actionButton: Switch.adaptive(
                value: _remindOnlyChange,
                onChanged: (change) => changeRemindOnlyChange(),
                activeColor: Theme.of(context).accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
