import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'pages/vplan/VPlan.dart';
import 'pages/teacherVPlan/TeacherVPlan.dart';
import 'pages/dashboard/Dashboard.dart';

void main() {
  runApp(MyApp());
}

void loadOfflineData(foo) {
  print('loadOfflineData\nfoo -> $foo');
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'expandiware',
      darkTheme: ThemeData(
        fontFamily: 'Poppins',
        brightness: Brightness.dark,
        accentColor: Color(0xffC1DEBA),
        primaryColor: Color(0xffE7C4B1),
        indicatorColor: Color(0xffD4CBC5),
        focusColor: Colors.white,
        backgroundColor: Color(0xff161B28),
        scaffoldBackgroundColor: Color(0xff000000),
      ),
      theme: ThemeData(
        fontFamily: 'Poppins',
        brightness: Brightness.light,
        accentColor: Color(0xff33aef8),
        primaryColor: Color(0xffE7C4B1),
        indicatorColor: Color(0xffD4CBC5),
        focusColor: Colors.black,
        backgroundColor: Colors.white,
        scaffoldBackgroundColor: Color(0xffe7e7e7),
      ),
      home: Scaffold(
        body: HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String activeText = 'vplan students';

  void getVPlanLogin(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).backgroundColor,
        title: Text('Schulnummer'),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Schulnummer',
          ),
          onChanged: (value) => prefs.setString('vplanSchoolnumber', value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ok'),
          ),
        ],
      ),
    );
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).backgroundColor,
        title: Text('Benutzername'),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Benutzername',
          ),
          onChanged: (value) => prefs.setString('vplanUsername', value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ok'),
          ),
        ],
      ),
    );
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).backgroundColor,
        title: Text('Passwort'),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Passwort',
          ),
          onChanged: (value) => prefs.setString('vplanPassword', value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ok'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> pages = [
      {
        'text': 'vplan students',
        'index': 0,
        'icon': Icons.photo_album_rounded,
        'widget': VPlan(),
        'settings': () => getVPlanLogin(context),
      },
      {
        'text': 'vplan teachers',
        'index': 1,
        'icon': Icons.people_alt_rounded,
        'widget': TeacherVPlan(),
        'settings': () => getVPlanLogin(context),
      },
      /*{
        'text': 'analysis',
        'index': 3,
        'icon': Icons.bar_chart_rounded, // stacked_bar_chart_rounded
        'widget': Text(
          'Coming soon...',
          key: ValueKey(1),
        ),
        'settings': () {},
      },*/
      {
        'text': 'dashboard',
        'index': 2,
        'icon': Icons.now_widgets_rounded,
        'widget': Dashboard(),
        'settings': () {},
      },
    ];
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: Theme.of(context).backgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    Widget activeWidget = Text('loading...');
    for (int i = 0; i < pages.length; i++) {
      if (pages[i]['text'] == activeText) {
        activeWidget = pages[i]['widget'];
      }
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          child: Stack(
            children: [
              // APPBAR
              Container(
                margin: EdgeInsets.only(top: 10),
                alignment: Alignment.topCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(),
                    SvgPicture.asset(
                      'assets/img/bird.svg',
                      color: Theme.of(context).focusColor,
                      width: 35,
                    ),
                    SizedBox(width: 30),
                    Text(
                      'expandiware',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 23,
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: Text(
                        activeText,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(),
                  ],
                ),
              ),
              // CONTENT
              Container(
                alignment: Alignment.center,
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: child,
                  ),
                  child: activeWidget,
                ),
              ),
              // FOOTER
              Positioned(
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    color: Theme.of(context).backgroundColor,
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.1,
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ...pages.map(
                        (e) => Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                onLongPress: e['settings'],
                                child: IconButton(
                                  icon: Icon(
                                    e['icon'],
                                    size: 26,
                                    color: activeText == e['text']
                                        ? Theme.of(context).accentColor
                                        : null,
                                  ),
                                  onPressed: () {
                                    activeText = e['text'];
                                    setState(() {});
                                  },
                                ),
                              ),
                              Container(
                                height: 2,
                                width: 8,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: e['text'] == activeText
                                      ? Theme.of(context).accentColor
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
