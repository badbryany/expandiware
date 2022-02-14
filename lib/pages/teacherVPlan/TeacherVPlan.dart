import 'package:expandiware/models/InputField.dart';
import 'package:flutter/material.dart';

import 'package:page_transition/page_transition.dart';

import './TeacherPlan.dart';

import 'package:expandiware/models/LoadingProcess.dart';
import 'package:expandiware/models/Button.dart';

import '../vplan/VPlanAPI.dart';

class TeacherVPlan extends StatefulWidget {
  const TeacherVPlan({Key? key}) : super(key: key);

  @override
  _TeacherVPlanState createState() => _TeacherVPlanState();
}

class _TeacherVPlanState extends State<TeacherVPlan> {
  String teacherShort = '';
  double spaceBetween = 50;
  String searchText = '';

  TextEditingController textFieldController = new TextEditingController();

  void setTeacherShort(String newValue) {
    teacherShort = newValue;
    textFieldController.text = newValue;
  }

  @override
  void initState() {
    super.initState();
    textFieldController.addListener(() {
      searchText = textFieldController.text;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget scannWidget = Container(
      margin: EdgeInsets.all(20),
      child: FutureBuilder(
        future: Future.delayed(Duration(microseconds: 1)),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return LoadingProcess();
          }
          return TeacherList(
            setTeacherShort: this.setTeacherShort,
            searchText: searchText,
          );
        },
      ),
    );
    return Container(
      margin: EdgeInsets.only(
        left: 50,
        right: 50,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Lehrer finden',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          SizedBox(height: spaceBetween * 0.3),
          InputField(
            controller: textFieldController,
            labelText: 'Lehrer-Kürzel wie z.B. "Mus"',
          ),
          SizedBox(height: spaceBetween * 0.3),
          Button(
            text: 'ansehen',
            onPressed: () => Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                child: TeacherPlan(
                  teacher: teacherShort,
                ),
              ),
            ),
          ),
          scannWidget,
        ],
      ),
    );
  }
}

class TeacherList extends StatefulWidget {
  final Function setTeacherShort;
  final String searchText;

  const TeacherList({
    Key? key,
    required this.setTeacherShort,
    required this.searchText,
  }) : super(key: key);

  @override
  _TeacherListState createState() => _TeacherListState();
}

class _TeacherListState extends State<TeacherList> {
  List<dynamic> teachers = ['Scanne alle Lehrerkürzel...'];

  Future<void> getTeachers() async {
    VPlanAPI vplanAPI = new VPlanAPI();
    List<String> teacherShorts = await vplanAPI.getTeachers();

    teachers = [];
    for (int i = 0; i < teacherShorts.length; i++) {
      teachers.add({
        'short': teacherShorts[i],
        'name': await vplanAPI.replaceTeacherShort(teacherShorts[i]),
      });
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getTeachers();
  }

  @override
  Widget build(BuildContext context) {
    try {
      if (widget.searchText != '') {
        List<dynamic> newList = [];
        for (int i = 0; i < teachers.length; i++) {
          RegExp exp = new RegExp(
            '${widget.searchText.toLowerCase()}[a-z,ö,ä,ü]*',
          );
          if (exp.hasMatch(teachers[i]['short'].toString().toLowerCase())) {
            newList.add(teachers[i]);
          }
        }
        teachers = newList;
      }
    } catch (e) {}
    return Container(
      height: MediaQuery.of(context).size.height * 0.35,
      child: teachers[0] == 'Scanne alle Lehrerkürzel...'
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: teachers
                  .map(
                    (e) => Text(
                      e,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  )
                  .toList(),
            )
          : GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              childAspectRatio: 2 / 1.3,
              children: [
                ...teachers.map(
                  (e) => Container(
                    margin: EdgeInsets.all(5),
                    child: InkWell(
                      onTap: () => widget.setTeacherShort(e['short']),
                      child: Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Theme.of(context).backgroundColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            e['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
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
