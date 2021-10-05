import 'package:expandiware/pages/vplan/VPlanAPI.dart';
import 'package:flutter/material.dart';

import 'package:animations/animations.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dashboard/settings/VPlanLogin.dart';

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
                  'später',
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: VPlanLogin(),
                    ),
                  );
                },
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
            openElevation: 0,
            closedElevation: 0,
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
                physics: BouncingScrollPhysics(),
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
                                title: Text(
                                  classes[index],
                                  style: TextStyle(
                                    fontSize: 19,
                                  ),
                                ),
                              ),
                            ),
                          );
                          classes.removeAt(index);
                          //getClasses();
                        },
                        icon: Icon(
                          Icons.delete_rounded,
                          color: Theme.of(context).focusColor,
                        ),
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

class SelectClass extends StatefulWidget {
  const SelectClass({
    Key? key,
    required this.pop,
    required this.favs,
  }) : super(key: key);

  final Function pop;
  final List<String> favs;

  @override
  State<SelectClass> createState() => _SelectClassState();
}

class _SelectClassState extends State<SelectClass> {
  List<String> classes = [];
  void getClasses() async {
    VPlanAPI vplanAPI = new VPlanAPI();

    classes = await vplanAPI.getClassList();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getClasses();
  }

  @override
  Widget build(BuildContext context) {
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
                child: classes.length == 0
                    ? Center(
                        child: Container(
                          width: 80,
                          child: LinearProgressIndicator(),
                        ),
                      )
                    : AnimatedList(
                        physics: BouncingScrollPhysics(),
                        initialItemCount: classes.length,
                        itemBuilder: (context, index, animation) {
                          {
                            bool used = false;
                            if (widget.favs.contains(classes[index])) {
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
                                this.widget.pop(classes[index]);
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
