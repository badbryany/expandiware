import 'package:flutter/material.dart';

import 'package:animations/animations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/ListItem.dart';

import './Plan.dart';

class VPlan extends StatefulWidget {
  const VPlan({Key? key}) : super(key: key);

  @override
  _VPlanState createState() => _VPlanState();
}

class _VPlanState extends State<VPlan> {
  List<String> classes = [];
  final listKey = GlobalKey<AnimatedListState>();

  void getClasses() async {
    classes = [];

    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String>? prefClasses = prefs.getStringList('classes');
    if (prefClasses == null) {
      prefClasses = [];
    }

    for (int i = 0; i < prefClasses.length; i++) {
      listKey.currentState!.insertItem(i);
      classes.add(prefClasses[i]);
    }

    if (classes.length == 0) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).backgroundColor,
            title: Text(
              'Füge eine neue Klasse hinzu!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 19),
            ),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('vergiss nicht die Zugangsdaten!'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'ok',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getClasses();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          OpenContainer(
            closedColor: Theme.of(context).scaffoldBackgroundColor,
            openColor: Theme.of(context).scaffoldBackgroundColor,
            closedBuilder: (context, openContainer) => ListItem(
              title: Text(
                'Klassenauswahl',
                style: TextStyle(
                  fontSize: 19,
                ),
              ),
              onClick: openContainer,
            ),
            openBuilder: (context, closeContainer) => SelectClass(
              pop: (String classId) {
                listKey.currentState!.insertItem(classes.length);
                classes.add(classId);
              },
              favs: classes,
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Scrollbar(
              isAlwaysShown: true,
              radius: Radius.circular(100),
              child: AnimatedList(
                key: listKey,
                initialItemCount: classes.length,
                itemBuilder: (context, index, animation) => SizeTransition(
                  sizeFactor: animation,
                  child: OpenContainer(
                    closedColor: Theme.of(context).scaffoldBackgroundColor,
                    openColor: Theme.of(context).scaffoldBackgroundColor,
                    closedBuilder: (context, openContainer) => ListItem(
                      title: Text(
                        classes[index],
                        style: TextStyle(
                          fontSize: 19,
                        ),
                      ),
                      onClick: openContainer,
                      actionButton: IconButton(
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          List<String>? newClasses =
                              prefs.getStringList('classes');
                          if (newClasses == null) {
                            newClasses = [];
                          }
                          newClasses.remove(classes[index]);
                          prefs.setStringList('classes', newClasses);

                          listKey.currentState!.removeItem(
                            index,
                            (context, animation) => SizeTransition(
                              sizeFactor: animation,
                              child: ListItem(
                                onClick: () {},
                                title: Text(classes[index]),
                              ),
                            ),
                          );
                          classes.removeAt(index);
                          //getClasses();
                        },
                        icon: Icon(Icons.delete_rounded),
                      ),
                    ),
                    openBuilder: (context, closeContainer) => Plan(
                      classId: classes[index],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SelectClass extends StatelessWidget {
  const SelectClass({
    Key? key,
    required this.pop,
    required this.favs,
  }) : super(key: key);

  final Function pop;
  final List<String> favs;

  @override
  Widget build(BuildContext context) {
    List<String> classes = [
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
    return SafeArea(
      child: Container(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 10),
              alignment: Alignment.topLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back),
                  ),
                  Text(
                    'Klassenauswahl',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: AnimatedList(
                  initialItemCount: classes.length,
                  itemBuilder: (context, index, animation) {
                    {
                      bool used = false;
                      if (favs.contains(classes[index])) {
                        used = true;
                      }
                      return ListItem(
                        title: Text(
                          classes[index],
                          style: TextStyle(
                            fontSize: 19,
                          ),
                        ),
                        actionButton: used
                            ? IconButton(
                                icon: Icon(Icons.check_rounded),
                                onPressed: () {},
                              )
                            : null,
                        color: used ? Color(0xff4B6F49) : null,
                        onClick: () async {
                          SharedPreferences instance =
                              await SharedPreferences.getInstance();
                          List<String>? _classes =
                              instance.getStringList('classes');
                          if (_classes == null) {
                            _classes = [];
                          }
                          _classes.add(classes[index]);
                          instance.setStringList('classes', _classes);
                          this.pop(classes[index]);
                          Navigator.pop(context);
                        },
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
