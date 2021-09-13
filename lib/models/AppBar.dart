import 'package:flutter/material.dart';

class Appbar extends StatelessWidget {
  final String title;
  final Widget actionWidget;

  Appbar(this.title, this.actionWidget);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      margin: EdgeInsets.only(top: 30, left: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
                this.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: actionWidget,
          ),
        ],
      ),
    );
  }
}
