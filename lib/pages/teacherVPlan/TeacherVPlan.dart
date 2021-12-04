import 'package:flutter/material.dart';

import 'package:page_transition/page_transition.dart';

import './TeacherPlan.dart';

import '../../models/LoadingProcess.dart';

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
    ); //SizedBox();
    return Container(
      margin: EdgeInsets.only(
        //top: MediaQuery.of(context).size.height * 0.1,
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
          SizedBox(height: spaceBetween),
          TextFormField(
            controller: textFieldController,
            decoration: InputDecoration(
              labelText: 'Gib ein Lehrer-Kürzel ein',
              hintText: 'z.B. Mus',
            ),
            onChanged: (value) => setState(
              () {
                teacherShort = value;
              },
            ),
          ),
          SizedBox(height: spaceBetween),
          Container(
            margin: EdgeInsets.all(5),
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: TeacherPlan(
                    teacher: teacherShort,
                  ),
                ),
              ),
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).indicatorColor,
                ),
                child: Text(
                  'ansehen',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
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
  List<String> teachers = ['Scanne alle Lehrerkürzel...'];

  Future<void> getTeachers() async {
    VPlanAPI vplanAPI = new VPlanAPI();
    var data = (await vplanAPI.getVPlanJSON(
      Uri.parse(
        await vplanAPI.getDayURL(),
      ),
      DateTime.now(),
    ))['data'];
    teachers = [];
    for (int i = 0; i < data['Klassen']['Kl'].length; i++) {
      var currentClass = data['Klassen']['Kl'][i];
      for (int j = 0; j < currentClass['Pl']['Std'].length; j++) {
        var currentLesson = currentClass['Pl']['Std'][j];
        if (currentLesson['Le'] != null) {
          bool add = true;
          for (int j = 0; j < teachers.length; j++) {
            if (teachers[j] == currentLesson['Le']) {
              add = false;
            }
          }
          if (add) {
            setState(() {
              teachers.add(currentLesson['Le']);
            });
          }
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getTeachers();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.searchText != '') {
      List<String> newList = [];
      for (int i = 0; i < teachers.length; i++) {
        RegExp exp = new RegExp(
          '${widget.searchText.toLowerCase()}[a-z,ö,ä,ü]*',
        );
        if (exp.hasMatch(teachers[i].toLowerCase())) {
          newList.add(teachers[i]);
        }
      }
      teachers = newList;
    }
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
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              children: [
                ...teachers.map(
                  (e) => Container(
                    margin: EdgeInsets.all(5),
                    child: InkWell(
                      onTap: () => widget.setTeacherShort(e),
                      child: Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Theme.of(context).backgroundColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            e,
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
