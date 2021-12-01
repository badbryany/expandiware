import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {
  const ListItem({
    Key? key,
    required this.title,
    this.subtitle,
    this.actionButton,
    this.leading,
    this.padding,
    required this.onClick,
    this.color,
  }) : super(key: key);

  final Widget title;
  final Widget? subtitle;
  final Widget? actionButton;
  final Widget? leading;
  final Function onClick;
  final Color? color;
  final double? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      child: InkWell(
        splashFactory: NoSplash.splashFactory,
        onTap: () => this.onClick(),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 500),
          padding: EdgeInsets.all(padding == null ? 9 : padding!),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: this.color == null
                ? Theme.of(context).backgroundColor
                : this.color,
          ),
          child: ListTile(
            leading: this.leading,
            title: this.title,
            subtitle: this.subtitle != null ? this.subtitle : null,
            trailing: this.actionButton,
          ),
        ),
      ),
    );
  }
}
