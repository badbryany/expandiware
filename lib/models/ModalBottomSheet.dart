import 'package:flutter/material.dart';

class ModalBottomSheet extends StatelessWidget {
  ModalBottomSheet({
    Key? key,
    required this.title,
    required this.content,
    this.extraButton,
    this.submitButtonText,
    this.onPop,
    this.bigTitle,
  }) : super(key: key);

  final String title;
  String? submitButtonText;
  final Widget content;
  Map<String, dynamic>? extraButton;
  Function? onPop;
  bool? bigTitle;

  @override
  Widget build(BuildContext context) {
    onPop ??= () => Navigator.pop(context);
    bigTitle ??= false;
    submitButtonText ??= 'fertig';
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        color: Theme.of(context).backgroundColor,
      ),
      child: Container(
        width: double.infinity,
        child: Stack(
          children: [
            Container(
              alignment: Alignment.topCenter,
              width: double.infinity,
              child: Container(
                margin: const EdgeInsets.all(10),
                width: 100,
                height: 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Theme.of(context).indicatorColor,
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: bigTitle! ? 28 : 23,
                    ),
                  ),
                  SizedBox(height: 25),
                  Container(
                    child: content,
                  ),
                  SizedBox(height: 25),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      extraButton != null
                          ? Container(
                              margin: const EdgeInsets.only(right: 10),
                              child: GestureDetector(
                                onTap: extraButton!['onTap'],
                                child: Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 0.3,
                                      color: Colors.grey,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  child: extraButton!['child'],
                                ),
                              ),
                            )
                          : SizedBox(),
                      GestureDetector(
                        onTap: () => onPop!(),
                        child: Container(
                          width: 200,
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                            color: Theme.of(context).primaryColor,
                          ),
                          child: Center(
                            child: Text(
                              submitButtonText!,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
