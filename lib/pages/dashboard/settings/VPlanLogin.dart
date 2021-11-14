import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/ListPage.dart';
import '../../../models/InputField.dart';

import 'package:pretty_qr_code/pretty_qr_code.dart';
import '../../../models/QRScanner.dart';

class VPlanLogin extends StatelessWidget {
  TextEditingController schoolnumberController = new TextEditingController();
  TextEditingController usernameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  String schoolnumber = '';
  String username = '';
  String password = '';

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
    schoolnumberController.text = jsonData['schoolnumber'];
    usernameController.text = jsonData['username'];
    passwordController.text = jsonData['password'];
    return;
  }

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
    getLoginData();
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

              dynamic data = {
                'schoolnumber': schoolnumber,
                'username': vplanUsername,
                'password': vplanPassword,
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
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          width: 80,
                          height: 5,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Color(0x99202020),
                          ),
                        ),
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
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                              color: Color(0x99202020),
                            ),
                            child: Center(
                              child: Text(
                                'fertig',
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),
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
                ...inputs.map(
                  (e) => InputField(
                    controller: e['controller'],
                    labelText: e['hintText'],
                    keaboardType: e['numeric'] ? TextInputType.number : null,
                  ),
                ),
                InkWell(
                  onTap: () async {
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
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).accentColor,
                    ),
                    child: Text(
                      'Speichern',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
