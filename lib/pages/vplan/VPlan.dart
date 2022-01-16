import 'package:expandiware/models/Button.dart';
import 'package:expandiware/models/ListPage.dart';
import 'package:expandiware/pages/vplan/VPlanAPI.dart';
import 'package:flutter/material.dart';

import 'package:animations/animations.dart';
import 'package:page_transition/page_transition.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dashboard/settings/VPlanLogin.dart';

import '../../models/ListItem.dart';
import '../../models/LoadingProcess.dart';

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
  dynamic classes = [];
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
    if (classes.toString().contains('error')) {
      String errorText = '';
      Widget extraWidget = SizedBox();
      switch (classes['error']) {
        case '401':
          errorText = 'Der Benutzername oder das Passwort ist falsch!';
          extraWidget = Lottie.asset(
            'assets/animations/lock.json',
            height: 120,
          );
          break;
        case 'schoolnumber':
          errorText = 'Falsche Schulnummer!\n\noder Vertretungsplan verfügbar';
          extraWidget = Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: Theme.of(context).backgroundColor,
            ),
            margin: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.37,
              right: MediaQuery.of(context).size.width * 0.37,
              bottom: 30,
            ),
            child: Center(
              child: Lottie.asset(
                'assets/animations/attention.json',
                height: 120,
                width: 120,
              ),
            ),
          );
          break;
        case 'no internet':
          errorText = 'Keine Internetverbindung';
          extraWidget = Lottie.asset(
            'assets/animations/wifi.json',
            height: 120,
          );
          break;
        default:
          switch (classes['data']['error']) {
            case '401':
              errorText = 'Der Benutzername oder das Passwort ist falsch!';
              extraWidget = Lottie.asset(
                'assets/animations/lock.json',
                height: 120,
              );
              break;
            case 'schoolnumber':
              errorText =
                  'Falsche Schulnummer!\n\noder Vertretungsplan verfügbar';
              extraWidget = Lottie.asset(
                'assets/animations/attention.json',
                height: 120,
              );
              break;
            case 'no internet':
              errorText = 'Keine Internetverbindung';
              extraWidget = Lottie.asset(
                'assets/animations/wifi.json',
                height: 120,
              );
              break;
          }
      }
      return ListPage(
        title: 'Klassenauswahl',
        animate: true,
        actions: [
          IconButton(
            onPressed: () => getClasses(),
            icon: Icon(Icons.sync_rounded),
          ),
        ],
        children: [
          extraWidget,
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(left: 10, right: 10),
            child: Text(
              errorText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.red.shade300,
              ),
            ),
          ),
          SizedBox(height: 30),
          Button(
            text: 'Zugangsdaten',
            onPressed: () => Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                child: VPlanLogin(),
              ),
            ),
          ),
        ],
      );
    }
    return ListPage(
      title: 'Klassenauswahl',
      animate: true,
      children: [
        classes.length == 0
            ? Center(
                child: LoadingProcess(),
              )
            : SizedBox(),
        ...classes.map((className) {
          bool used = false;
          if (widget.favs.contains(className)) {
            used = true;
          }
          return ListItem(
            title: Text(
              className,
              style: TextStyle(
                fontSize: 19,
                fontWeight: used ? FontWeight.w600 : null,
                color: used ? Colors.black : null,
              ),
            ),
            actionButton: used
                ? IconButton(
                    icon: Icon(
                      Icons.check_rounded,
                      color: used ? Colors.black : null,
                    ),
                    onPressed: () {},
                  )
                : null,
            color: used ? Theme.of(context).indicatorColor : null,
            onClick: () async {
              SharedPreferences instance =
                  await SharedPreferences.getInstance();
              List<String>? _classes = instance.getStringList('classes');
              if (_classes == null) {
                _classes = [];
              }
              _classes.add(className);
              instance.setStringList('classes', _classes);
              this.widget.pop(className);
              Navigator.pop(context);
            },
          );
        }),
      ],
    );
  }
}
