import 'package:expandiware/main.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget title(BuildContext context) => Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/img/bird.svg',
            width: MediaQuery.of(context).size.width * 0.15,
            color: Theme.of(context).focusColor,
          ),
          SizedBox(height: 15),
          Text(
            'expandwiare',
            style: TextStyle(
              fontFamily: 'Crackman',
            ),
          ),
          SizedBox(height: 50),
          /* SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
              strokeWidth: 1,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'initialisiere App...',
            style: TextStyle(
              color: Theme.of(context).focusColor.withOpacity(0.5),
            ),
          ), */
          Icon(
            Icons.warning_rounded,
            color: Theme.of(context).errorColor,
            size: 40,
          ),
          SizedBox(height: 15),
          Text(
            'Achtung, ganz gefährliche App!\nwird bestimmt ein Trojaner...',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).errorColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );

Future<bool> titleAction() async {
  // register the App
  return true;
}

Widget getStarded(BuildContext context) => Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/img/bird.svg',
                width: MediaQuery.of(context).size.width * 0.08,
                color: Theme.of(context).focusColor,
              ),
              SizedBox(width: 15),
              Text(
                'expandwiare',
                style: TextStyle(
                  fontFamily: 'Crackman',
                ),
              ),
            ],
          ),
          SizedBox(height: 50),
          Text(
            'Viel Spaß mit expandiware!',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 5),
          Text(
            '...und liebe grüße vom Oskar ( ❛︠ ᴗ ︡❛)',
            style: TextStyle(
                // fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );

start() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('firstTime', false);
  runApp(MyApp());
}

Widget vplanLogin(BuildContext context) => Container();

Widget classes(BuildContext context) => Container();

Widget login(BuildContext context) => Container();

Widget news(BuildContext context) => Container();
