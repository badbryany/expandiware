import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:qr/qr.dart';

class VPlanLogin extends StatelessWidget {
  TextEditingController schoolnumberController = new TextEditingController();
  TextEditingController usernameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

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
                  Container(
                    margin: EdgeInsets.only(right: 15),
                    child: IconButton(
                      onPressed: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        String schoolnumber =
                            prefs.getString("vplanSchoolnumber")!;
                        String vplanUsername =
                            prefs.getString("vplanUsername")!;
                        String vplanPassword =
                            prefs.getString("vplanPassword")!;

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
                            content: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: PrettyQr(
                                size: 200,
                                data: jsonEncode(data),
                                elementColor: Theme.of(context).focusColor,
                                errorCorrectLevel: QrErrorCorrectLevel.M,
                                roundEdges: true,
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
