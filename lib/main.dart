import 'dart:ui' as prefix0;

import 'package:flutter/material.dart';
import 'package:flutter_image_guesser/image_card.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  List<String> vehicleNames = [
    'bicycle',
    'boat',
    'car',
    'excavator',
    'helicopter',
    'motorbike',
    'plane',
    'tractor',
    'train',
    'truck',
  ];
  String currentVehicleName = "vehicle name";

  double scrollPercent = 0.0;

  Offset startDrag;
  double startDragPercentScroll;

  double finishScrollStart;
  double finishScrollEnd;

  AnimationController finishScrollController;

  @override
  initState() {
    super.initState();

    finishScrollController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );

    finishScrollController.addListener(() {
      setState(() {
        scrollPercent = prefix0.lerpDouble(
            finishScrollStart, finishScrollEnd, finishScrollController.value);
      });
    });
  }

  @override
  dispose() {
    super.dispose();
    finishScrollController.dispose();
  }

  List<Widget> buildCards() {
    List<Widget> cardsList = [];

    for (int i = 0; i < vehicleNames.length; i++) {
      cardsList.add(buildCard(i, scrollPercent));
    }

    return cardsList;
  }

  Widget buildCard(int cardIndex, double scrollPercent) {
    final cardScrollPercent = scrollPercent / (1 / vehicleNames.length);

    return FractionalTranslation(
      translation: Offset(cardIndex - cardScrollPercent, 0.0),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: ImageCard(
          imageName: vehicleNames[cardIndex],
        ),
      ),
    );
  }

  onHorizontalDragStart(DragStartDetails details) {
    startDrag = details.globalPosition;
    startDragPercentScroll = scrollPercent;
  }

  onHorizontalDragEnd(DragEndDetails details) {
    finishScrollStart = scrollPercent;
    finishScrollEnd =
        (scrollPercent * vehicleNames.length).round() / vehicleNames.length;
    finishScrollController.forward(from: 0.0);

    setState(() {
      startDrag = null;
      startDragPercentScroll = null;
      currentVehicleName = '';
    });
  }

  onHorizontalDragUpdate(DragUpdateDetails details) {
    final currentDrag = details.globalPosition;
    final dragDistance = currentDrag.dx - startDrag.dx;
    final singleCardDragPercent = dragDistance / context.size.width;

    setState(() {
      scrollPercent = (startDragPercentScroll +
              (-singleCardDragPercent / vehicleNames.length))
          .clamp(0.0, 1.0 - (1 / vehicleNames.length));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hello"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              child: GestureDetector(
                onHorizontalDragStart: onHorizontalDragStart,
                onHorizontalDragEnd: onHorizontalDragEnd,
                onHorizontalDragUpdate: onHorizontalDragUpdate,
                behavior: HitTestBehavior.translucent,
                child: Stack(
                  children: buildCards(),
                ),
              ),
              height: 300,
            ),
            OutlineButton(
              onPressed: () {
                setState(() {
                  currentVehicleName =
                      vehicleNames[(scrollPercent * 10).round()];
                });
              },
              child: Text(
                "Show Answer",
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              padding: EdgeInsets.all(10.0),
              borderSide: BorderSide(
                color: Colors.black,
                width: 4.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  20.0,
                ),
              ),
              highlightedBorderColor: Colors.black,
            ),
            Text(
              currentVehicleName,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
