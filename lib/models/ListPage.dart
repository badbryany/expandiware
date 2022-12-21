import 'package:flutter/material.dart';

class ListPage extends StatefulWidget {
  ListPage({
    Key? key,
    required this.title,
    this.smallTitle,
    required this.children,
    this.actions,
    this.animate,
    this.canclePage,
    this.onPop,
  }) : super(key: key);

  final String title;
  bool? smallTitle;
  bool? animate;
  bool? canclePage;
  Function? onPop;
  final List<Widget> children;
  List<Widget>? actions;

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  ScrollController controller = ScrollController();
  double topHeight = -10;

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if (controller.offset == 0) return;
      if (controller.offset < 0) {
        topHeight = -10;
      } else {
        topHeight = 0;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (topHeight == -10) topHeight = MediaQuery.of(context).size.height * 0.23;
    widget.actions ??= [];
    widget.animate ??= false;
    widget.smallTitle ??= false;

    widget.onPop ??= () => Navigator.pop(context);

    IconData backIcon = Icons.arrow_back_rounded;

    if (widget.canclePage != null && widget.canclePage == true) {
      backIcon = Icons.clear_rounded;
    }

    return SafeArea(
      child: Container(
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.topCenter,
              color: Theme.of(context).backgroundColor,
              height: topHeight,
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: (topHeight / 5.5).toDouble(),
                      bottom: 10,
                      left: 10,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () => widget.onPop!(),
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(100),
                                  ),
                                  color: Theme.of(context).dividerColor,
                                ),
                                child: Icon(
                                  backIcon,
                                  size: 19,
                                  color: Theme.of(context).splashColor,
                                ),
                              ),
                            ),
                            SizedBox(width: 30),
                            AnimatedOpacity(
                              duration: Duration(
                                  milliseconds: topHeight == 0 ? 700 : 100),
                              opacity: topHeight == 0 ? 0 : 1,
                              child: Container(
                                child: Text(
                                  widget.title,
                                  style: TextStyle(
                                    fontSize: widget.smallTitle! ? 22 : 30,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Questrial',
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        //actions
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: widget.actions!,
                        ),
                        SizedBox(width: 5),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AnimatedOpacity(
              duration: Duration(milliseconds: topHeight == 0 ? 700 : 100),
              opacity: topHeight == 0 ? 1 : 0,
              child: Container(
                  alignment: Alignment.topLeft,
                  margin: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () => widget.onPop!(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(100),
                            ),
                            color: Theme.of(context).dividerColor,
                          ),
                          child: Icon(
                            backIcon,
                            size: 16,
                            color: Theme.of(context).splashColor,
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Questrial',
                        ),
                      ),
                    ],
                  )),
            ),
            // CONTENT
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(
                  top: topHeight != 0
                      ? MediaQuery.of(context).size.height * 0.08
                      : 0,
                ),
                padding: EdgeInsets.only(
                  top: topHeight != 0
                      ? MediaQuery.of(context).size.height * 0.07
                      : 0,
                  left: 10,
                  right: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(45),
                    topRight: Radius.circular(45),
                  ),
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                alignment: Alignment.bottomCenter,
                height: MediaQuery.of(context).size.height *
                    (topHeight == 0 ? 0.85 : 0.85),
                child: widget.animate!
                    ? AnimatedSwitcher(
                        duration: Duration(milliseconds: 500),
                        transitionBuilder: (child, animation) =>
                            SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 2),
                            end: const Offset(0, 0),
                          ).animate(animation),
                          child: child,
                        ),
                        child: ListView(
                          key: ValueKey(widget.children),
                          controller: controller,
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          children: widget.children,
                        ),
                      )
                    : ListView(
                        controller: controller,
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        children: widget.children,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
