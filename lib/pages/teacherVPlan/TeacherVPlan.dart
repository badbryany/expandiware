import 'package:flutter/material.dart';

import 'package:page_transition/page_transition.dart';

import './TeacherPlan.dart';

import '../vplan/VPlanAPI.dart';

class TeacherVPlan extends StatefulWidget {
  const TeacherVPlan({Key? key}) : super(key: key);

  @override
  _TeacherVPlanState createState() => _TeacherVPlanState();
}

class _TeacherVPlanState extends State<TeacherVPlan> {
  String teacherShort = '';
  double spaceBetween = 50;

  TextEditingController textFieldController = new TextEditingController();

  void setTeacherShort(String newValue) {
    teacherShort = newValue;
    textFieldController.text = newValue;
  }

  @override
  Widget build(BuildContext context) {
    Widget scannWidget = Container(
      margin: EdgeInsets.all(20),
      child: FutureBuilder(
        future: Future.delayed(Duration(microseconds: 1)),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return LinearProgressIndicator();
          }
          return TeacherList(
            setTeacherShort: this.setTeacherShort,
          );
        },
      ),
    ); //SizedBox();
    return Container(
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.18,
        left: 50,
        right: 50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Gib das Kürzel eines Lehrers ein!',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          SizedBox(height: spaceBetween * 0.3),
          Text(
            'Durch den Vertretungsplan der einzelnen Klassen wird gefiltert wann welcher Lehrer Unterricht hat. Diese Daten werden ohne den Lehrerlogin erhoben.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[800],
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
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).backgroundColor,
                ),
                child: Text('ansehen'),
              ),
            ),
          ),
          /*TextButton(
            onPressed: () => setState(() {
              scannWidget = FutureBuilder(
                future: Future.delayed(Duration(seconds: 1)),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return CircularProgressIndicator();
                  }
                  return TeacherList(
                    setTeacherShort: this.setTeacherShort,
                  );
                },
              );
            }),
            child: Text('Scanne Lehrerkürzel'),
          ),*/
          scannWidget,
        ],
      ),
    );
  }
}

class TeacherList extends StatefulWidget {
  const TeacherList({
    Key? key,
    required this.setTeacherShort,
  }) : super(key: key);

  final Function setTeacherShort;

  @override
  _TeacherListState createState() => _TeacherListState();
}

class _TeacherListState extends State<TeacherList> {
  List<String> teachers = ['Scanne alle Lehrerkürzel...', 'Bitte warten...'];

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
    return Container(
      height: 200,
      child: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          Text(
            'Alle Lehrer Kürzel:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          ...teachers.map(
            (e) => InkWell(
              onTap: () => widget.setTeacherShort(e),
              child: Container(
                margin: EdgeInsets.all(3),
                padding: EdgeInsets.all(3),
                child: Text(
                  e,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
