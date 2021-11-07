import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

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
      body: Container(
        child: Stack(
          children: [
            Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.only(top: 30, left: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Theme.of(context).focusColor,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(width: 20),
                      Text(
                        'Zugangsdaten für indiware',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(),
                  IconButton(
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      String schoolnumber =
                          prefs.getString("vplanSchoolnumber")!;
                      String vplanUsername = prefs.getString("vplanUsername")!;
                      String vplanPassword = prefs.getString("vplanPassword")!;

                      dynamic data = {
                        'schoolnumber': schoolnumber,
                        'username': vplanUsername,
                        'password': vplanPassword,
                      };

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Theme.of(context).backgroundColor,
                          title: Text('Zugangsdaten teilen'),
                          content: Container(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: PrettyQr(
                                size: 250,
                                data: jsonEncode(data),
                                elementColor: Colors.black,
                                errorCorrectLevel: QrErrorCorrectLevel.M,
                                roundEdges: true,
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              child: Text('ok'),
                              onPressed: () => Navigator.pop(context),
                            )
                          ],
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
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 50, right: 50),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ...inputs.map(
                    (e) => Container(
                      margin: EdgeInsets.all(10),
                      child: TextFormField(
                        autocorrect: false,
                        controller: e['controller'],
                        keyboardType:
                            e['numeric'] ? TextInputType.number : null,
                        decoration: InputDecoration(
                          labelText: e['hintText'],
                        ),
                      ),
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
      ),
    );
  }
}

/*async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
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
                      schoolnumberController.text = jsonData['schoolnumber'];
                      usernameController.text = jsonData['username'];
                      passwordController.text = jsonData['password'];
                      return;
                    } */