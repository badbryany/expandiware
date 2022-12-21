import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {
  ListItem({
    Key? key,
    required this.title,
    this.subtitle,
    this.actionButton,
    this.leading,
    this.padding,
    this.margin,
    required this.onClick,
    this.color,
    this.shadow,
    this.borderRadius,
  }) : super(key: key);

  final Widget title;
  final Widget? subtitle;
  final Widget? actionButton;
  final Widget? leading;
  final Function onClick;
  final Color? color;
  final double? padding;
  final double? margin;
  final BorderRadius? borderRadius;
  bool? shadow;

  @override
  Widget build(BuildContext context) {
    shadow ??= false;
    return Container(
      margin: EdgeInsets.all(margin == null ? 5 : margin!),
      child: InkWell(
        splashFactory: NoSplash.splashFactory,
        onTap: () => this.onClick(),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 250),
          padding: EdgeInsets.all(padding == null ? 9 : padding!),
          decoration: BoxDecoration(
            borderRadius:
                borderRadius == null ? BorderRadius.circular(25) : borderRadius,
            boxShadow: shadow!
                ? [
                    BoxShadow(
                      color: Theme.of(context).focusColor.withOpacity(0.1),
                      blurRadius: 5, // soften the shadow
                      spreadRadius: 0.1, //extend the shadow
                    ),
                  ]
                : null,
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
