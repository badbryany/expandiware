import 'dart:convert';

import 'package:expandiware/models/Button.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/ListPage.dart';
import '../../../models/InputField.dart';

import 'package:pretty_qr_code/pretty_qr_code.dart';
import '../../../models/QRScanner.dart';

class VPlanLogin extends StatefulWidget {
  @override
  State<VPlanLogin> createState() => _VPlanLoginState();
}

class _VPlanLoginState extends State<VPlanLogin> {
  TextEditingController schoolnumberController = new TextEditingController();
  TextEditingController usernameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  TextEditingController customUrlController = new TextEditingController();

  String schoolnumber = '';

  String username = '';

  String password = '';

  @override
  void initState() {
    super.initState();
    getLoginData();
  }

  void getLoginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    schoolnumberController.text = prefs.getString('vplanSchoolnumber') == null
        ? ''
        : prefs.getString('vplanSchoolnumber')!;

    usernameController.text = prefs.getString('vplanUsername') == null
        ? ''
        : prefs.getString('vplanUsername')!;

    passwordController.text = prefs.getString('vplanPassword') == null
        ? ''
        : prefs.getString('vplanPassword')!;

    customUrlController.text = prefs.getString('customUrl') == null
        ? ''
        : prefs.getString('customUrl')!;

    if (customUrlController.text != '') {
      setState(() => customUrlField = true);
    }
  }

  void setData(dynamic data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic jsonData = {};
    try {
      jsonData = jsonDecode(data);
    } catch (e) {
      return;
    }
    prefs.setString('vplanSchoolnumber', jsonData['schoolnumber']);
    prefs.setString('vplanUsername', jsonData['username']);
    prefs.setString('vplanPassword', jsonData['password']);

    prefs.setString('customUrl', jsonData['customUrl']);

    schoolnumberController.text = jsonData['schoolnumber'];
    usernameController.text = jsonData['username'];
    passwordController.text = jsonData['password'];

    passwordController.text = jsonData['customUrl'];
  }

  bool customUrlField = false;

  @override
  Widget build(BuildContext context) {
    List<dynamic> inputs = [
      {
        'hintText': 'Schulnummer',
        'controller': schoolnumberController,
        'numeric': true,
      },
      {
        'hintText': 'Benutzer',
        'controller': usernameController,
        'numeric': false,
      },
      {
        'hintText': 'Passwort',
        'controller': passwordController,
        'numeric': false,
      },
    ];

    Widget _inputs = Column(
      children: inputs
          .map(
            (e) => InputField(
              controller: e['controller'],
              labelText: e['hintText'],
              keaboardType: e['numeric'] ? TextInputType.number : null,
            ),
          )
          .toList(),
    );

    if (customUrlField) {
      _inputs =
          InputField(controller: customUrlController, labelText: 'Eigene URL');
    }

    return Scaffold(
      body: ListPage(
        title: 'Zugangsdaten',
        actions: [
          IconButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String schoolnumber = prefs.getString("vplanSchoolnumber")!;
              String vplanUsername = prefs.getString("vplanUsername")!;
              String vplanPassword = prefs.getString("vplanPassword")!;

              String customUrl = prefs.getString("customUrl")!;

              dynamic data = {
                'schoolnumber': schoolnumber,
                'username': vplanUsername,
                'password': vplanPassword,
                'customUrl': customUrl,
              };

              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                enableDrag: true,
                builder: (context) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    color: Theme.of(context).backgroundColor,
                  ),
                  child: Container(
                    width: double.infinity,
                    child: Stack(
                      children: [
                        Container(
                          alignment: Alignment.topCenter,
                          width: double.infinity,
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            width: 100,
                            height: 5,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Theme.of(context).indicatorColor,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Zugangsdaten teilen',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(height: 25),
                              Container(
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: PrettyQr(
                                    size: 250,
                                    data: jsonEncode(data),
                                    elementColor: Colors.black,
                                    errorCorrectLevel: QrErrorCorrectLevel.H,
                                    typeNumber: 10,
                                    roundEdges: false,
                                    image: AssetImage('assets/img/logo.png'),
                                  ),
                                ),
                              ),
                              SizedBox(height: 25),
                              InkWell(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  width: 200,
                                  padding: EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                    color: Theme.of(context).indicatorColor,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'fertig',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            icon: Icon(
              Icons.share_rounded,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QRScanner(setData: setData),
              ),
            ),
            icon: Icon(Icons.qr_code_scanner_rounded),
          ),
        ],
        children: [
          Container(
            margin: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) => SizeTransition(
                    sizeFactor: animation,
                    child: child,
                  ),
                  child: _inputs,
                ),

                // CUSTOM URL
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 10),
                  child: InkWell(
                    onTap: () =>
                        setState(() => customUrlField = !customUrlField),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: 1.4,
                            color:
                                Theme.of(context).focusColor.withOpacity(0.3),
                            width: MediaQuery.of(context).size.width * 0.2,
                          ),
                          Text(
                            customUrlField
                                ? 'oder Login verwenden'
                                : 'oder eigene URL',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.85),
                            ),
                          ),
                          Container(
                            height: 1.4,
                            color:
                                Theme.of(context).focusColor.withOpacity(0.3),
                            width: MediaQuery.of(context).size.width * 0.2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // CUSTOM URL

                Button(
                  text: 'Speichern',
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();

                    prefs.setString(
                      'vplanSchoolnumber',
                      schoolnumberController.text.toString(),
                    );
                    prefs.setString(
                      'vplanUsername',
                      usernameController.text.toString(),
                    );
                    prefs.setString(
                      'vplanPassword',
                      passwordController.text.toString(),
                    );
                    if (!customUrlField) {
                      prefs.setString("customUrl", '');
                    } else {
                      prefs.setString(
                        "customUrl",
                        customUrlController.text.toString(),
                      );
                    }
                    Fluttertoast.showToast(msg: 'Anmeldedaten gespeichert');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
