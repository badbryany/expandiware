import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../models/InputField.dart';
import '../../../models/ListPage.dart';
import '../../vplan/VPlanAPI.dart';

class TeacherShorts extends StatefulWidget {
  TeacherShorts({Key? key}) : super(key: key);

  @override
  State<TeacherShorts> createState() => _TeacherShortsState();
}

class _TeacherShortsState extends State<TeacherShorts> {
  List<dynamic> teachers = [];

  getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> teacherShorts = await VPlanAPI().getTeachers();

    if (prefs.getString('teacherShorts') == null ||
        prefs.getString('teacherShorts') == '') {
      List<dynamic> addList = [];
      for (int i = 0; i < teacherShorts.length; i++) {
        addList.add({
          'short': teacherShorts[i],
          'realName': '',
        });
      }
      prefs.setString('teacherShorts', jsonEncode(addList));
    }

    List<dynamic> teacherShortConvert =
        jsonDecode(prefs.getString('teacherShorts')!);

    for (int i = 0; i < teacherShorts.length; i++) {
      teachers.add({
        'short': teacherShorts[i],
        'realName': teacherShortConvert[i]['realName'],
        'controller': TextEditingController(
          text: teacherShortConvert[i]['realName'],
        ),
        'currently_added': false,
      });
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListPage(
        title: 'Lehrerkürzel erstzen',
        children: [
          ...teachers.map(
            (e) => Container(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Theme.of(context).backgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        e['short'],
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: InputField(
                      controller: e['controller'],
                      labelText: 'echter Nachname',
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(5),
                    child: InkWell(
                      onTap: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        String value =
                            (e['controller'] as TextEditingController).text;

                        List<dynamic> _teacherShorts =
                            jsonDecode(prefs.getString('teacherShorts')!);

                        for (int i = 0; i < _teacherShorts.length; i++) {
                          if (_teacherShorts[i]['short'] == e['short']) {
                            _teacherShorts[i]['realName'] = value;
                          }
                        }
                        prefs.setString(
                          'teacherShorts',
                          jsonEncode(_teacherShorts),
                        );
                        setState(() => e['currently_added'] = true);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Theme.of(context).backgroundColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: e['currently_added']
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).backgroundColor,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            e['currently_added'] ? 'added' : 'add',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
