import 'dart:io';

import 'package:expandiware/introduction/introscreen.dart';

import 'package:expandiware/models/Button.dart';
import 'package:expandiware/models/ModalBottomSheet.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import './android_colors.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:device_info/device_info.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

import 'background_service.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

/* pages */
import 'pages/vplan/VPlan.dart';
import 'pages/teacherVPlan/TeacherVPlan.dart';
import 'pages/dashboard/Dashboard.dart';

Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
  return <String, dynamic>{
    'version.securityPatch': build.version.securityPatch,
    'version.sdkInt': build.version.sdkInt,
    'version.release': build.version.release,
    'version.previewSdkInt': build.version.previewSdkInt,
    'version.incremental': build.version.incremental,
    'version.codename': build.version.codename,
    'version.baseOS': build.version.baseOS,
    'board': build.board,
    'bootloader': build.bootloader,
    'brand': build.brand,
    'device': build.device,
    'display': build.display,
    'fingerprint': build.fingerprint,
    'hardware': build.hardware,
    'host': build.host,
    'id': build.id,
    'manufacturer': build.manufacturer,
    'model': build.model,
    'product': build.product,
    'supported32BitAbis': build.supported32BitAbis,
    'supported64BitAbis': build.supported64BitAbis,
    'supportedAbis': build.supportedAbis,
    'tags': build.tags,
    'type': build.type,
    'isPhysicalDevice': build.isPhysicalDevice,
    'androidId': build.androidId,
    'systemFeatures': build.systemFeatures,
  };
}

Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
  return <String, dynamic>{
    'name': data.name,
    'systemName': data.systemName,
    'systemVersion': data.systemVersion,
    'model': data.model,
    'localizedModel': data.localizedModel,
    'identifierForVendor': data.identifierForVendor,
    'isPhysicalDevice': data.isPhysicalDevice,
    'utsname.sysname:': data.utsname.sysname,
    'utsname.nodename:': data.utsname.nodename,
    'utsname.release:': data.utsname.release,
    'utsname.version:': data.utsname.version,
    'utsname.machine:': data.utsname.machine,
  };
}

void sendAppOpenData() async {
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> deviceData = <String, dynamic>{};
  dynamic logindata;

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? schoolnumber = prefs.getString('vplanSchoolnumber');
  schoolnumber ??= prefs.getString('customUrl');
  List<String>? classes = prefs.getStringList('classes');
  classes ??= [];
  try {
    if (Platform.isAndroid) {
      deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      logindata = {
        'schoolnumber': schoolnumber,
        'classes': classes.toString(),
        'device_id': deviceData['id'],
        'android_id': deviceData['androidId'],
        'model': deviceData['model'],
        'manufacturer': deviceData['manufacturer'],
        'os_version': 'Android ${deviceData['version.release']}',
        'last_security_update': deviceData['version.securityPatch'],
        'app_open_time': DateTime.now().toString(),
      };
    } else if (Platform.isIOS) {
      deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
    }
  } on PlatformException {
    deviceData = <String, dynamic>{'Error:': 'Failed to get platform version.'};
  }

  // send request to kellermann.team to save the data
  try {
    if (prefs.getBool('analisis') == null ||
        prefs.getBool('analisis')! == true) {
      http.post(
        Uri.parse('https://www.kellermann.team/expandiware/analytics.php'),
        body: logindata,
      );
    }
  } catch (e) {}
}

void main() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getBool('automaticLoad') == true ||
      prefs.getBool('automaticLoad') == null) {
    print('initialize background service');
    WidgetsFlutterBinding.ensureInitialized();
    FlutterBackgroundService.initialize(onStart);
  }
  if (!kDebugMode) sendAppOpenData();

  if (prefs.getBool('firstTime') == null) {
    runApp(Introduction());
    return;
  }
  runApp(MyApp());
}

Color darken(Color c, [int percent = 10]) {
  assert(1 <= percent && percent <= 100);
  var f = 1 - percent / 100;
  return Color.fromARGB(c.alpha, (c.red * f).round(), (c.green * f).round(),
      (c.blue * f).round());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getMaterialYouColor(),
      builder: (context, AsyncSnapshot<MaterialYouPalette?> snapshot) {
        Color primaryColor = Color(0xffAF69EE); //1fbe88); // ECA44D
        int scaffoldBGDark = snapshot.data?.neutral2.shade900 == null ? 50 : 70;

        final backgroundColor = snapshot.data?.neutral2.shade900 ??
            Color(0xff1e1f25); //Color(0xff101012);
        final backgroundColorLight =
            snapshot.data?.neutral2.shade100 ?? Colors.grey.shade300;

        final primarySwatch = snapshot.data?.accent1.shade200 ?? primaryColor;
        final primarySwatchLight =
            snapshot.data?.accent1.shade400 ?? primaryColor;
        final dividerColor =
            snapshot.data?.accent3.shade100 ?? Color(0xff0d0d0f);
        final dividerColorLight =
            snapshot.data?.accent3.shade100 ?? Colors.white;

        final indicatorColor = snapshot.data?.accent1.shade100 ?? primaryColor;

        final indicatorColorLight =
            snapshot.data?.accent1.shade100 ?? primaryColor;

        return MaterialApp(
          builder: (BuildContext context, Widget? child) {
            final MediaQueryData data = MediaQuery.of(context);
            return MediaQuery(
              data: data.copyWith(
                textScaleFactor: 0.9,
              ),
              child: child!,
            );
          },
          debugShowCheckedModeBanner: false,
          title: 'expandiware',
          darkTheme: ThemeData(
            fontFamily: 'Poppins',
            brightness: Brightness.dark,
            primaryColor: primarySwatch,
            dividerColor: dividerColor,
            focusColor: Colors.white,
            indicatorColor: indicatorColor,
            errorColor: Color.fromARGB(158, 119, 18, 18),
            backgroundColor: darken(backgroundColor, 5), //Color(0xff161B28),
            scaffoldBackgroundColor: darken(backgroundColor, scaffoldBGDark),
            splashColor: snapshot.data == null ? Colors.white : Colors.black,
          ),
          theme: ThemeData(
            fontFamily: 'Poppins',
            brightness: Brightness.light,
            primaryColor: primarySwatchLight,
            indicatorColor: indicatorColorLight,
            focusColor: Colors.black,
            errorColor: Color.fromARGB(158, 119, 18, 18),
            dividerColor: dividerColorLight,
            backgroundColor: backgroundColorLight, //Color(0xffe7e7e7),
            scaffoldBackgroundColor: Colors.white,
            splashColor: Colors.black,
          ),
          home: Scaffold(
            body: HomePage(),
          ),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  String activeText = 'vplan students';

  @override
  void initState() {
    super.initState();
    eastereggController = AnimationController(vsync: this);
  }

  void dispose() {
    eastereggController.dispose();
    super.dispose();
  }

  int developerClickCount = 0;
  int maxDeveloperClickCount = 7;
  void getDeveloper() async {
    if (activeText != 'dashboard') return;
    if (developerClickCount == maxDeveloperClickCount) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('developerOptions', true);
      Fluttertoast.cancel();
      Fluttertoast.showToast(msg: 'Du bist jetzt Entwickler!');
      print('Du bist jetzt Entwickler!');
    }

    developerClickCount++;
    if (developerClickCount >= 3 &&
        developerClickCount <= maxDeveloperClickCount) {
      Fluttertoast.cancel();
      Fluttertoast.showToast(
        msg:
            'In ${maxDeveloperClickCount - developerClickCount + 1} Schritte${(maxDeveloperClickCount - developerClickCount + 1) == 0 ? '' : 'n'} bist du Entwickler',
      );
      print(
        'In ${maxDeveloperClickCount - developerClickCount + 1} Schritte${(maxDeveloperClickCount - developerClickCount + 1) == 0 ? '' : 'n'} bist du Entwickler',
      );
    }
  }

  String version = '1.15';
  void checkForUpdates(BuildContext context) async {
    String _version = version;
    var r;
    try {
      r = await http.get(
        Uri.parse(
          'https://www.kellermann.team/expandiware/shouldUpdate.php?version=${_version}',
        ),
      );
    } catch (e) {
      return;
    }
    if (r.body == 'update') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).backgroundColor,
          title: Row(
            children: [
              Icon(Icons.system_security_update_outlined),
              SizedBox(width: 10),
              Text('Neue Version'),
            ],
          ),
          content: Text('lade dir die neuste Version herunter!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'später',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 13,
                ),
              ),
            ),
            Button(
              text: 'herunterladen',
              onPressed: () async {
                String url =
                    'https://www.kellermann.team/expandiware/expandiware.apk';

                try {
                  await launch(url);
                } catch (e) {
                  print('faild');
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    }
  }

  void openVPLan(String _prefClass) {}

  void eastereggIconChange() {
    if (eastereggIcon.key == ValueKey(1)) {
      eastereggIcon = SvgPicture.asset(
        'assets/img/bird.svg',
        key: ValueKey(2),
        color: Theme.of(context).focusColor,
        width: 35,
      );
    } else {
      eastereggIcon = LottieBuilder.asset(
        'assets/animations/bird.json',
        key: ValueKey(1),
      );
      Future.delayed(
        const Duration(milliseconds: 6140),
        eastereggIconChange,
      );
    }
    setState(() {});
  }

  late final AnimationController eastereggController;
  Widget eastereggIcon = SizedBox();

  @override
  Widget build(BuildContext context) {
    if (eastereggIcon.runtimeType == SizedBox)
      eastereggIcon = SvgPicture.asset(
        'assets/img/bird.svg',
        width: 35,
        key: ValueKey(2),
        color: Theme.of(context).focusColor,
      );
    checkForUpdates(context);
    List<Map<String, dynamic>> pages = [
      {
        'text': 'vplan students',
        'index': 0,
        'icon': 'assets/img/home.svg',
        'widget': VPlan(),
      },
      {
        'text': 'vplan teachers',
        'index': 1,
        'icon': 'assets/img/person.svg',
        'widget': TeacherVPlan(),
      },
      {
        'text': 'dashboard',
        'index': 2,
        'icon': 'assets/img/dashboard.svg',
        'widget': Dashboard(),
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
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                // APPBAR
                Container(
                  alignment: Alignment.topCenter,
                  color: Theme.of(context).backgroundColor,
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.only(
                    top: 10,
                    bottom: 10,
                  ),
                  child: SafeArea(
                    child: Stack(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          height: 45,
                          child: Text(
                            'expandiware',
                            style: TextStyle(
                              fontSize: 23,
                              color: Theme.of(context).focusColor,
                              fontFamily: 'Crackman',
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: getDeveloper,
                          child: Container(
                            alignment: Alignment.centerRight,
                            height: 45,
                            margin: EdgeInsets.only(
                              right: MediaQuery.of(context).size.width * 0.07,
                            ),
                            // padding: const EdgeInsets.all(10),
                            child: IconButton(
                              icon: Icon(Icons.more_horiz_rounded),
                              color: Colors.grey.shade400,
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => ModalBottomSheet(
                                    title: 'App Info',
                                    bigTitle: true,
                                    extraButton: {
                                      'onTap': () => Share.share(
                                            'Probier doch mal diese Schulapp aus!\nhier herunterladen: https://www.kellermann.team/expandiware/',
                                          ),
                                      'child': Icon(
                                        Icons.share_rounded,
                                        size: 18,
                                      ),
                                    },
                                    content: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Entwickler: Oskar',
                                            style: TextStyle(
                                              fontSize: 17,
                                            ),
                                          ),
                                        ),
                                        ...[
                                          {
                                            'name': 'Kontakt',
                                            'link':
                                                'https://www.kellermann.team/expandiware/contact',
                                          },
                                          {
                                            'name': 'Github',
                                            'link':
                                                'https://www.github.com/badbryany/expandiware',
                                          },
                                          {
                                            'name': 'Website',
                                            'link':
                                                'https://www.kellermann.team/expandiware',
                                          },
                                          {
                                            'name': 'Instagram',
                                            'link':
                                                'https://www.instagram.com/expandiware/',
                                          },
                                        ].map(
                                          (e) => Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: InkWell(
                                              onTap: () => launch(e['link']!),
                                              child: Text(
                                                '${e['name']}: www.${e['link']![12] + e['link']![13] + e['link']![14] + e['link']![15]}...',
                                                style: TextStyle(
                                                  decoration:
                                                      TextDecoration.underline,
                                                  decorationColor:
                                                      Theme.of(context)
                                                          .focusColor,
                                                  fontSize: 17,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'version: $version',
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.1,
                          ),
                          height: 45,
                          width: 45,
                          child: InkWell(
                            onTap: eastereggIconChange,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              transitionBuilder: (child, animation) =>
                                  FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: animation,
                                  child: child,
                                ),
                              ),
                              child: eastereggIcon,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // CONTENT
                Container(
                  margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.14,
                  ),
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(45),
                      topRight: Radius.circular(45),
                    ),
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
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
                                  onTap: () {
                                    activeText = e['text'];
                                    setState(() {});
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(7),
                                    child: SvgPicture.asset(
                                      e['icon'],
                                      color: activeText == e['text']
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context).focusColor,
                                      width: 28,
                                    ),
                                  ),
                                ),
                                SvgPicture.asset(
                                  'assets/img/active.svg',
                                  width: 13,
                                  color: e['text'] == activeText
                                      ? Theme.of(context).primaryColor
                                      : Colors.transparent,
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
      ),
    );
  }
}
