import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';

import 'package:expandiware/models/ListItem.dart';
import 'package:expandiware/models/LoadingProcess.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:expandiware/models/ListPage.dart';
import 'package:expandiware/models/Slider.dart';
import 'package:expandiware/models/Button.dart';
import 'package:expandiware/models/ModalBottomSheet.dart';
import 'package:expandiware/models/QRScanner.dart';
import 'package:expandiware/models/InputField.dart';

Color darken(Color c, [int percent = 10]) {
  assert(1 <= percent && percent <= 100);
  var f = 1 - percent / 100;
  return Color.fromARGB(c.alpha, (c.red * f).round(), (c.green * f).round(),
      (c.blue * f).round());
}

class NewsFeed extends StatefulWidget {
  const NewsFeed({Key? key}) : super(key: key);

  @override
  _NewsFeedState createState() => _NewsFeedState();
}

class _NewsFeedState extends State<NewsFeed> {
  List<FeedEntry> feedData = [];

  getData() async {
    feedData = [];
    setState(() {});
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? stringData = prefs.getString('newsfeeds');
    if (stringData == null || stringData == '[]') {
      prefs.setString('newsfeeds', '[]');
      stringData = '[]';
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.bottomToTop,
          child: AddFeed(
            refreshFeeds: getData,
          ),
        ),
      );
      return;
    }

    List<dynamic> feeds = jsonDecode(stringData);

    for (int i = 0; i < feeds.length; i++) {
      try {
        Uri url = Uri.parse(feeds[i]['url']);

        String res = (await http.get(url)).body;

        XmlDocument xml = XmlDocument.parse(res);

        Iterable<XmlElement> items = xml
            .getElement('rss')!
            .getElement('channel')!
            .findAllElements('item');

        for (int j = 0; j < items.length; j++) {
          String author = items.elementAt(j).getElement('dc:creator') == null
              ? 'no creator found'
              : items.elementAt(j).getElement('dc:creator')!.innerText;
          DateTime? pubDate =
              tryParseDate(items.elementAt(j).getElement('pubDate')!.innerText);

          pubDate ??= DateTime.parse('1970-01-01 00:00:00');

          var linkElements = items.elementAt(j).findAllElements('link');
          linkElements.isEmpty ? linkElements = [] : null;

          List<String> urls = linkElements.map((e) => e.innerText).toList();

          List<Map<String, String>> links = [];
          // get title of webpages
          for (int y = 0; y < urls.length; y++) {
            links.add({
              'title': urls[y],
              'link': urls[y],
            });
          }

          feedData.add(
            FeedEntry(
              feedTitle: feeds[i]['name'],
              url: feeds[i]['url'],
              title: items.elementAt(j).getElement('title')!.innerText,
              description:
                  items.elementAt(j).getElement('description')!.innerText,
              pubDate: pubDate,
              author: author,
              links: links,
              color: Color.fromARGB(
                255,
                feeds[i]['color'][0],
                feeds[i]['color'][1],
                feeds[i]['color'][2],
              ),
              getData: getData,
            ),
          );
        }
      } catch (e) {
        feedData.add(
          FeedEntry(
            error: true,
            title: feeds[i]['name'],
            description: '',
            pubDate: DateTime.now(),
            author: '',
            color: Color.fromARGB(
              255,
              feeds[i]['color'][0],
              feeds[i]['color'][1],
              feeds[i]['color'][2],
            ),
            feedTitle: feeds[i]['name'],
            links: [],
            getData: getData,
            url: feeds[i]['url'],
          ),
        );
      }
    }

    feedData.sort((a, b) => a.pubDate.compareTo(b.pubDate));

    feedData = feedData.reversed.toList();

    setState(() {});
  }

  DateTime? tryParseDate(String dateString) {
    if (DateTime.tryParse(dateString) != null) {
      return DateTime.parse(dateString);
    }
    try {
      List<String> months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];

      List<String> dates = dateString.split(',')[1].trim().split(' ');

      String day = dates[0];
      String month = '';
      String year = dates[2];

      for (int i = 0; i < months.length; i++)
        if (months[i] == dates[1]) {
          if (i <= 9) {
            month = '0$i';
          } else {
            month = '$i';
          }
        }

      return DateTime.parse('$year-$month-$day 00:00:00');
    } catch (e) {
      return DateTime.parse('1970-01-01 00:00:00');
    }
  }

  shareData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? stringData = prefs.getString('newsfeeds');

    stringData ??= '[]';

    showDialog(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        width: MediaQuery.of(context).size.width * 0.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            LoadingProcess(),
            Text(
              'erstelle Sharelink...',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
    var res = await http.get(
      Uri.parse(
        'https://www.kellermann.team/expandiware/api/shareNewsFeed/?clientKey=${Random().nextInt(2 ^ 32)}&content=' +
            stringData,
      ),
    );
    Navigator.pop(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ModalBottomSheet(
        title: 'Quellen teilen',
        content: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: PrettyQr(
              size: 250,
              data: res.body,
              elementColor: Colors.black,
              errorCorrectLevel: QrErrorCorrectLevel.L,
              typeNumber: 10,
              roundEdges: false,
              // image: AssetImage('assets/img/logo.png'),
            ),
          ),
        ),
        extraButton: {
          'onTap': () {
            Navigator.pop(context);
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.bottomToTop,
                child: AddFeed(
                  refreshFeeds: getData,
                ),
              ),
            );
          },
          'child': Icon(
            Icons.qr_code_scanner_rounded,
            size: 18,
          ),
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return ListPage(
      title: 'Neuigkeiten',
      actions: [
        IconButton(
          onPressed: getData,
          icon: Icon(
            Icons.refresh_rounded,
          ),
        ),
        IconButton(
          onPressed: () => Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.bottomToTop,
              child: AddFeed(
                refreshFeeds: getData,
              ),
            ),
          ),
          icon: Icon(
            Icons.add_rounded,
          ),
        ),
        IconButton(
          onPressed: () => shareData(),
          icon: Icon(
            Icons.share_rounded,
            size: 18,
          ),
        ),
      ],
      children: [
        (feedData.isEmpty
            ? Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width * 0.2,
                child: LoadingProcess(),
              )
            : SizedBox()),
        ...feedData.map(
          (e) => e,
        ),
      ],
    );
  }
}

class FeedEntry extends StatefulWidget {
  FeedEntry({
    Key? key,
    required this.title,
    required this.description,
    required this.pubDate,
    required this.author,
    required this.color,
    required this.feedTitle,
    required this.links,
    required this.getData,
    required this.url,
    this.error,
  }) : super(key: key);

  final String title;
  final String description;
  final DateTime pubDate;
  final String author;
  final String url;
  final Color color;
  final String feedTitle;
  final Function getData;
  final List<Map<String, String>> links;
  bool? error;

  @override
  _FeedEntryState createState() => _FeedEntryState();
}

class _FeedEntryState extends State<FeedEntry> {
  @override
  Widget build(BuildContext context) {
    widget.error ??= false;
    Color iconColor =
        widget.color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    Color shadowColor =
        Theme.of(context).backgroundColor.computeLuminance() < 0.5
            ? Colors.black
            : Colors.white;

    String month = widget.pubDate.month <= 9
        ? '0${widget.pubDate.month}'
        : widget.pubDate.month.toString();
    String day = widget.pubDate.day <= 9
        ? '0${widget.pubDate.day}'
        : widget.pubDate.day.toString();

    String displayDate = '$day/$month/${widget.pubDate.year}';

    if (widget.error!) {
      return GestureDetector(
        onLongPress: () => Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.bottomToTop,
            child: AddFeed(
              edit: true,
              editFeed: {
                'name': widget.feedTitle,
                'url': widget.url,
                'color': widget.color,
              },
              refreshFeeds: widget.getData,
            ),
          ),
        ),
        child: ListItem(
          shadow: true,
          leading: Icon(
            Icons.info_rounded,
            color: Theme.of(context).errorColor,
          ),
          title: Text(
            '${widget.title}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text('konnte nicht geladen werden'),
          actionButton: IconButton(
            icon: Icon(
              Icons.more_vert_rounded,
              size: 20,
            ),
            onPressed: () => Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.bottomToTop,
                child: AddFeed(
                  edit: true,
                  editFeed: {
                    'name': widget.feedTitle,
                    'url': widget.url,
                    'color': widget.color,
                  },
                  refreshFeeds: widget.getData,
                ),
              ),
            ),
          ),
          onClick: () {},
        ),
      );
    }

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(
            top: 10,
            bottom: 10,
            left: 5,
            right: 5,
          ),
          child: GestureDetector(
            onLongPress: () => Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.bottomToTop,
                child: AddFeed(
                  edit: true,
                  editFeed: {
                    'name': widget.feedTitle,
                    'url': widget.url,
                    'color': widget.color,
                  },
                  refreshFeeds: widget.getData,
                ),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.only(
                top: 23,
                left: 17,
                right: 17,
                bottom: 17,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Theme.of(context).backgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 5, // soften the shadow
                    spreadRadius: 0.1, //extend the shadow
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width * 0.08,
                        height: MediaQuery.of(context).size.width * 0.08,
                        decoration: BoxDecoration(
                          color: widget.color,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          widget.feedTitle[0].toUpperCase(),
                          style: TextStyle(
                            fontSize:
                                (MediaQuery.of(context).size.width * 0.1) /
                                    2.25,
                            fontWeight: FontWeight.bold,
                            color: iconColor,
                            fontFamily: 'Questrial',
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: Text(
                              widget.title,
                              maxLines: 2,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10 / widget.title.length + 18,
                              ),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${widget.author} - ${widget.feedTitle}',
                            style: TextStyle(
                              color:
                                  Theme.of(context).focusColor.withOpacity(0.3),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      top: 20,
                      left: 10,
                      right: 10,
                      bottom: 10,
                    ),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: darken(Theme.of(context).backgroundColor, 20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.description,
                          style: TextStyle(
                            color:
                                Theme.of(context).focusColor.withOpacity(0.8),
                          ),
                        ),
                        SizedBox(height: 15),
                        Container(
                          height: 1,
                          width: MediaQuery.of(context).size.width * 0.6,
                          color: Theme.of(context).backgroundColor,
                        ),
                        SizedBox(height: 15),
                        ...widget.links.map(
                          (e) => InkWell(
                            onTap: () => launch(e['link']!),
                            child: Text(
                              e['title']!,
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                decorationColor: Theme.of(context).focusColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          displayDate,
                          style: TextStyle(
                            color:
                                Theme.of(context).focusColor.withOpacity(0.3),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          alignment: Alignment.topRight,
          margin: const EdgeInsets.only(right: 20, top: 22),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  String linkString = widget.links
                      .toList()
                      .map((e) => e['link']! + '\n')
                      .toString()
                      .replaceAll('(', '')
                      .replaceAll(')', '');
                  Share.share(
                      'Neuigkeit von ${widget.feedTitle}:\n${widget.author} schrieb am $day.$month.${widget.pubDate.year} folgende Nachricht:\n${widget.description}\nweitere Informationen:\n$linkString \nNewsfeedurl: ${widget.url}\n\nDiese Nachricht wurde über expandiware geteilt.\nZu expandiware: https://www.kellermann.team/expandiware/');
                },
                icon: Icon(
                  Icons.share_rounded,
                  size: 17,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.more_vert_rounded,
                  size: 20,
                ),
                onPressed: () => Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.bottomToTop,
                    child: AddFeed(
                      edit: true,
                      editFeed: {
                        'name': widget.feedTitle,
                        'url': widget.url,
                        'color': widget.color,
                      },
                      refreshFeeds: widget.getData,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AddFeed extends StatefulWidget {
  AddFeed({
    Key? key,
    required this.refreshFeeds,
    this.edit,
    this.editFeed,
  }) : super(key: key);

  final Function refreshFeeds;
  bool? edit;
  dynamic editFeed;

  @override
  State<AddFeed> createState() => _AddFeedState();
}

class _AddFeedState extends State<AddFeed> {
  Color color = Colors.primaries[Random().nextInt(Colors.primaries.length)];

  TextEditingController nameController = TextEditingController();
  TextEditingController urlController = TextEditingController();
  String lastUrControllerValue = '';

  bool feedExist = false;

  Future<dynamic> setData() async {
    if (nameController.text == '') {
      return 'empty name';
    }
    if (urlController.text == '') {
      return 'empty url';
    }
    if (!feedExist) {
      bool stop = true;
      await showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) => ModalBottomSheet(
          title: 'Quelle existiert nicht - Quelle trotzdem hinzufügen?',
          onPop: () => Navigator.pop(context),
          submitButtonText: 'nein',
          extraButton: {
            'child': Text(
              ' ja ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            'onTap': () {
              stop = false;
              Navigator.pop(context);
            },
          },
          content: SizedBox(),
        ),
      );
      if (stop) return 'false feed';
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();

    widget.edit ??= false;
    if (widget.edit!) {
      dynamic newData = {
        'name': nameController.text,
        'url': urlController.text,
        'color': [color.red, color.green, color.blue],
      };
      String stringData = prefs.getString('newsfeeds')!;
      List<dynamic> data = jsonDecode(stringData);

      for (int i = 0; i < data.length; i++) {
        if (data[i]['name'] == widget.editFeed['name'] &&
            data[i]['url'] == widget.editFeed['url']) {
          data[i] = newData;
          prefs.setString('newsfeeds', jsonEncode(data));
          widget.refreshFeeds();
          Fluttertoast.cancel();
          Fluttertoast.showToast(msg: 'Quelle gespeichert');
          return;
        }
      }
    }

    String? stringData = prefs.getString('newsfeeds');
    stringData ??= '[]';

    List<dynamic> data = jsonDecode(stringData);

    for (int i = 0; i < data.length; i++) {
      if (nameController.text == data[i]['name'] && widget.edit == false) {
        return 'name';
      }
      if (urlController.text == data[i]['url'] && widget.edit == false) {
        return 'url';
      }
    }

    data.add({
      'name': nameController.text,
      'url': urlController.text,
      'color': [color.red, color.green, color.blue],
    });

    prefs.setString('newsfeeds', jsonEncode(data));
    return 'done';
  }

  @override
  void initState() {
    super.initState();

    widget.edit ??= false;
    if (widget.edit!) {
      feedExist = true;
      nameController.text = widget.editFeed['name'];
      urlController.text = widget.editFeed['url'];
      color = widget.editFeed['color'];
      setState(() {});
    }

    urlController.addListener(() async {
      if (urlController.text == '') urlController.text = 'https://';

      if (urlController.text == lastUrControllerValue) return;

      lastUrControllerValue = urlController.text;
      if (!urlController.text.contains('.')) return;
      if (!urlController.text.contains('http://')) {
        Fluttertoast.cancel();
        Fluttertoast.showToast(msg: '"https://" nicht vergessen!');
      }

      Uri url = Uri.parse(urlController.text);
      String res = '';
      XmlDocument xml;
      try {
        Fluttertoast.cancel();
        Fluttertoast.showToast(msg: 'suche Quelle...');
        res = (await http.get(url)).body;
        xml = XmlDocument.parse(res);
        feedExist = true;
        Fluttertoast.cancel();
        Fluttertoast.showToast(msg: 'gefunden');
      } catch (e) {
        feedExist = false;
        print('no xml feed');
        return;
      }

      nameController.text = xml
          .getElement('rss')!
          .getElement('channel')!
          .getElement('title')!
          .innerText;
      return;
    });
  }

  @override
  Widget build(BuildContext context) {
    widget.edit ??= false;
    return Scaffold(
      body: Dismissible(
        key: ValueKey('NewsFeed'),
        direction: DismissDirection.down,
        onDismissed: (_) => Navigator.of(context).pop(),
        child: ListPage(
          title: 'Quelle ${widget.edit! ? 'bearbeiten' : 'hinzufügen'}',
          canclePage: true,
          actions: [
            widget.edit!
                ? IconButton(
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      List<dynamic> feeds =
                          jsonDecode(prefs.getString('newsfeeds')!);

                      for (int i = 0; i < feeds.length; i++) {
                        if (feeds[i]['name'] == widget.editFeed['name'] &&
                            feeds[i]['url'] == widget.editFeed['url']) {
                          feeds.removeAt(i);
                        }
                      }

                      prefs.setString(
                        'newsfeeds',
                        jsonEncode(
                          feeds,
                        ),
                      );
                      Fluttertoast.cancel();
                      Fluttertoast.showToast(
                        msg: '${widget.editFeed['name']} gelöscht',
                      );
                      Navigator.pop(context);
                      widget.refreshFeeds();
                    },
                    icon: Icon(Icons.delete_rounded),
                  )
                : IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QRScanner(
                          setData: (String? res) async {
                            showDialog(
                              context: context,
                              builder: (context) => Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    LoadingProcess(),
                                    Text(
                                      'Lade Quellen...',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );

                            var httpRes = await http.get(
                              Uri.parse(
                                'https://www.kellermann.team/expandiware/api/shareNewsFeed/get.php?key=' +
                                    res!,
                              ),
                            );

                            Navigator.pop(context);

                            List<dynamic> data = jsonDecode(httpRes.body);
                            print(data);
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) => ModalBottomSheet(
                                submitButtonText: 'keine',
                                title: 'Welche Quelle speichern?',
                                content: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.3,
                                  margin: EdgeInsets.only(
                                    left: 10,
                                    right: 10,
                                  ),
                                  child: ListView(
                                    physics: BouncingScrollPhysics(),
                                    children: [
                                      ...data.map(
                                        (e) => ListItem(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          leading: Container(
                                            alignment: Alignment.center,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.08,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.08,
                                            decoration: BoxDecoration(
                                              color: Color.fromARGB(
                                                255,
                                                e['color'][0],
                                                e['color'][1],
                                                e['color'][2],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                            ),
                                            child: Text(
                                              e['name'][0].toUpperCase(),
                                              style: TextStyle(
                                                fontSize:
                                                    (MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.1) /
                                                        2.25,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(
                                                          255,
                                                          e['color'][0],
                                                          e['color'][1],
                                                          e['color'][2],
                                                        ).computeLuminance() >
                                                        0.5
                                                    ? Colors.black
                                                    : Colors.white,
                                                fontFamily: 'Questrial',
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            e['name'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                            ),
                                          ),
                                          subtitle: Text(
                                            e['url'],
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 13,
                                            ),
                                          ),
                                          padding: 5,
                                          onClick: () {
                                            urlController.text = e['url'];
                                            nameController.text = e['name'];
                                            color = Color.fromARGB(
                                              255,
                                              e['color'][0],
                                              e['color'][1],
                                              e['color'][2],
                                            );
                                            setState(() {});
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    icon: Icon(Icons.qr_code_scanner_rounded),
                  ),
          ],
          children: [
            InputField(
              controller: urlController,
              labelText: 'URL / Web Adresse',
            ),
            InputField(
              controller: nameController,
              labelText: 'Name',
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.1,
                  height: MediaQuery.of(context).size.width * 0.1,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Button(
                  text: 'Farbe auswählen',
                  borderRadius: 15,
                  filled: false,
                  color: color,
                  onPressed: () {
                    int red = color.red;
                    int green = color.green;
                    int blue = color.blue;

                    setColor() {
                      color = Color.fromARGB(255, red, green, blue);
                      setState(() {});
                    }

                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) => StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return ModalBottomSheet(
                            title: 'Farbe auswählen',
                            content: Column(
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.1,
                                  height:
                                      MediaQuery.of(context).size.width * 0.1,
                                  decoration: BoxDecoration(
                                    color:
                                        Color.fromARGB(255, red, green, blue),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                SizedBox(height: 15),
                                CustomSlider(
                                  text: 'Rot',
                                  value: red.toDouble(),
                                  max: 255,
                                  min: 0,
                                  onChange: (value) {
                                    red = value.toInt();
                                    setColor();
                                    setState(() {});
                                  },
                                  color: Color(0xffD14A22)
                                      .withOpacity(red.toDouble() / 255),
                                ),
                                SizedBox(height: 8),
                                CustomSlider(
                                  text: 'Grün',
                                  value: green.toDouble(),
                                  max: 255,
                                  min: 0,
                                  onChange: (value) {
                                    green = value.toInt();
                                    setColor();
                                    setState(() {});
                                  },
                                  color: Color(0xff21B24F)
                                      .withOpacity(green.toDouble() / 255),
                                ),
                                SizedBox(height: 8),
                                CustomSlider(
                                  text: 'Blau',
                                  value: blue.toDouble(),
                                  max: 255,
                                  min: 0,
                                  onChange: (value) {
                                    blue = value.toInt();
                                    setColor();
                                    setState(() {});
                                  },
                                  color: Color(0xff3B74A1)
                                      .withOpacity(blue.toDouble() / 255),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
            Button(
              text: 'hinzufügen',
              onPressed: () async {
                dynamic foo = await setData();
                if (foo == 'empty url') {
                  Fluttertoast.cancel();
                  Fluttertoast.showToast(msg: 'Trage eine URL ein');
                  return;
                }
                if (foo == 'empty name') {
                  Fluttertoast.cancel();
                  Fluttertoast.showToast(msg: 'Trage einen Namen ein');
                  return;
                }
                if (foo == 'url') {
                  Fluttertoast.cancel();
                  Fluttertoast.showToast(msg: 'Die URL existiert bereits');
                  return;
                }
                if (foo == 'name') {
                  Fluttertoast.cancel();
                  Fluttertoast.showToast(msg: 'Der Name existiert bereits');
                  return;
                }

                if (foo == 'false feed') {
                  return;
                }

                Fluttertoast.cancel();
                Fluttertoast.showToast(msg: 'Quelle gespeichert');
                Navigator.pop(context);
                widget.refreshFeeds();
              },
            ),
          ],
        ),
      ),
    );
  }
}
