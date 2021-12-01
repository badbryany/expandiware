import 'dart:io';

import 'package:expandiware/pages/vplan/VPlanAPI.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:device_info/device_info.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

import 'package:quick_actions/quick_actions.dart';

/* vplanlogin scan */
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import 'background_service.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

/* pages */
import 'pages/vplan/VPlan.dart';
import 'pages/teacherVPlan/TeacherVPlan.dart';
import 'pages/dashboard/Dashboard.dart';

Future<String> scanQRCode() async {
  String barcodeScanRes = 'nothing';
  try {
    barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666',
      'Cancel',
      true,
      ScanMode.QR,
    );
    print(barcodeScanRes);
  } catch (e) {
    print(e);
  }

  return barcodeScanRes;
}

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
    http.post(
      Uri.parse('https://www.kellermann.team/expandiware/analytics.php'),
      body: logindata,
    );
  } catch (e) {}
}

void main() async {
  runApp(MyApp());

  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getBool('automaticLoad') != null) {
    if (prefs.getBool('automaticLoad')!) {
      print('initialize background service');
      WidgetsFlutterBinding.ensureInitialized();
      FlutterBackgroundService.initialize(onStart);
    }
  }
  if (!kDebugMode) sendAppOpenData();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        accentColor: Color(0xffECA44D),
        primaryColor: Color(0xff0884eb),
        indicatorColor: Color(0xffd04f5b),
        focusColor: Colors.white,
        backgroundColor: Color(0xff101012), //Color(0xff161B28),
        scaffoldBackgroundColor: Colors.black,
      ),
      theme: ThemeData(
        fontFamily: 'Poppins',
        brightness: Brightness.light,
        accentColor: Color(0xff06b36e),
        primaryColor: Color(0xffE7C4B1),
        indicatorColor: Color(0xffD4CBC5),
        focusColor: Colors.black,
        backgroundColor: Colors.white, //Color(0xffe7e7e7),
        scaffoldBackgroundColor: Color(0xffd7dae1), //Colors.white,
      ),
      /*theme: ThemeData(
        fontFamily: 'Poppins',
        brightness: Brightness.light,
        scaffoldBackgroundColor: Color(0xffeffbf9),
        backgroundColor: Color(0xff18181a),
        cardColor: Color(0xffecf0ef),
        focusColor: Colors.white,
        accentColor: Color(0xff68f9ff),
      ),*/
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

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  String activeText = 'vplan students';
  final QuickActions quickActions = QuickActions();

  @override
  void initState() {
    super.initState();
    eastereggController = AnimationController(vsync: this);
  }

  void dispose() {
    eastereggController.dispose();
    super.dispose();
  }

  void initQuickActions() async {
    List<String> classes = await VPlanAPI().getClasses();
    quickActions.setShortcutItems([
      ShortcutItem(
        type: 'vplan students',
        localizedTitle: 'Vertretungsplan von ${classes[0]}',
      ),
      ShortcutItem(
        type: 'vplan teachers',
        localizedTitle: 'Lehrer finden',
      ),
      ShortcutItem(
        type: 'dashboard',
        localizedTitle: 'Dashboard',
      ),
    ]);
  }

  void checkForUpdates(BuildContext context) async {
    String _version = '1.1';
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
              Icon(Icons.update_rounded),
              SizedBox(width: 10),
              Text('Veraltete Version'),
            ],
          ),
          content: Text('lade dir die neuste Version herunter!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'später',
                style: TextStyle(
                  fontSize: 13,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(4),
              child: TextButton(
                child: Text(
                  'herunterladen',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
        'icon': Icons.photo_album_rounded,
        'widget': VPlan(),
      },
      {
        'text': 'vplan teachers',
        'index': 1,
        'icon': Icons.people_alt_rounded,
        'widget': TeacherVPlan(),
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
      },
    ];
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: Theme.of(context).backgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    quickActions.initialize((shortcutType) async {
      activeText = shortcutType;

      if (shortcutType == ' vplan students') {
        String prefClass = (await VPlanAPI().getClasses())[0];
        openVPLan(prefClass);
      }
    });

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
                        Container(
                          alignment: Alignment.center,
                          height: 45,
                          child: Text(
                            'expandiware',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 23,
                              color: Theme.of(context).focusColor,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          height: 45,
                          margin: EdgeInsets.only(
                            right: MediaQuery.of(context).size.width * 0.07,
                          ),
                          child: Text(
                            activeText,
                            style: TextStyle(
                              color: Theme.of(context).focusColor,
                              fontSize: 10,
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
                                    margin: EdgeInsets.all(17),
                                    child: Icon(
                                      e['icon'],
                                      size: 26,
                                      color: activeText == e['text']
                                          ? Theme.of(context).accentColor
                                          : Theme.of(context).focusColor,
                                    ),
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
      ),
    );
  }
}
