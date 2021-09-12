import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:device_info/device_info.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

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
  try {
    if (Platform.isAndroid) {
      deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      logindata = {
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
  var res = await http.post(
    Uri.parse('http://192.168.3.91/expandiware/analytics.php'),
    body: logindata,
  );

  print(res.body);
}

void main() {
  runApp(MyApp());
  sendAppOpenData();
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
        accentColor: Color(0xff258786),
        primaryColor: Color(0xff0884eb),
        indicatorColor: Color(0xffd04f5b),
        focusColor: Colors.white,
        backgroundColor: Color(0xff1d1e23), //Color(0xff161B28),
        scaffoldBackgroundColor: Color(0xff010001),
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

  void checkForUpdates(BuildContext context) async {
    String _version = 'beta 0.6';
    var r = await http.get(
      Uri.parse(
        'https://www.kellermann.team/expandiware/shouldUpdate.php?version=${_version}',
      ),
    );
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () async {
                  String data = await scanQRCode();
                  dynamic jsonData = {};
                  try {
                    jsonData = jsonDecode(data);
                  } catch (e) {
                    return;
                  }
                  prefs.setString(
                      'vplanSchoolnumber', jsonData['schoolnumber']);
                  prefs.setString('vplanUsername', jsonData['username']);
                  prefs.setString('vplanPassword', jsonData['password']);
                  return;
                },
                child: Text('scannen'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('ok'),
              ),
            ],
          ),
        ],
      ),
    ).then(
      (value) => showDialog(
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
      ).then(
        (value) => showDialog(
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    checkForUpdates(context);
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
                                onTap: () {
                                  activeText = e['text'];
                                  setState(() {});
                                },
                                onLongPress: e['settings'],
                                child: Container(
                                  padding: EdgeInsets.all(7),
                                  child: Icon(
                                    e['icon'],
                                    size: 26,
                                    color: activeText == e['text']
                                        ? Theme.of(context).accentColor
                                        : null,
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
    );
  }
}
