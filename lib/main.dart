import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());
// starts the app
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      // theme for the label from the app
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Stacked Cards Animation'),
    );
  }
}
class MyHomePage extends StatefulWidget {
  // displays the title
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  String imageUrl = "image1.jpeg";
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Flutter Swipe Component'),
      ),
      // safe area makes it responsive

      body: SafeArea(
        // the stack class makes the cards get on each other
        child: Stack(
          // makes the width expand
          fit: StackFit.expand,
          children: [
            new Container(
              // Draws a box
              decoration: new BoxDecoration(
                // if i want a background cover
//                image: new DecorationImage(
//                  image: AssetImage("assets/$imageUrl"),
//                  fit: BoxFit.cover,
//                ),
              ),

              // some decoration of the cards
              child: new BackdropFilter(
                filter: new ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                child: new Container(
                  decoration:
                  new BoxDecoration(color: Colors.white.withOpacity(0.0)),
                ),
              ),
            ),

            new Center(
              // centers the stack of cards into the middle
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CardStack(
                    onCardChanged: (url) {
                      setState(() {
                        imageUrl = url;
                      });
                    },
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
class CardStack extends StatefulWidget {
  // call method for changing the card
  final Function onCardChanged;
  CardStack({this.onCardChanged});
  @override
  _CardStackState createState() => _CardStackState();
}
class _CardStackState extends State<CardStack>
//When you add your SingleTickerProviderStateMixin, it tells Flutter that there
// is some animation in this widget and this widget needs to notified about the animation frames of flutter.
    with SingleTickerProviderStateMixin {
  // This loads the images in
  var cards = [
    SwipeCard(index: 0, imageUrl: "image1.jpeg"),
    SwipeCard(index: 1, imageUrl: "image2.jpeg"),
    SwipeCard(index: 2, imageUrl: "image3.jpeg"),
    SwipeCard(index: 3, imageUrl: "image4.jpeg"),
  ];

  // The different animations that are used are here defined
  int currentIndex;
  AnimationController controller;
  CurvedAnimation curvedAnimation;
  Animation<Offset> _translationAnim;
  Animation<Offset> _moveAnim;
  Animation<double> _scaleAnim;

  @override
  // initState is called once when the stateful widget is inserted in the widget tree
  // think about something like public function create in Laravel PHP
  void initState() {
    super.initState();
    currentIndex = 0;
    // calling method for the AnimationController
    controller = AnimationController(
      // vsync keeps the track of the screen, so that Flutter doesn't show
      // the animation when the screen is not being displayed
      vsync: this,
      duration: Duration(milliseconds: 150),
    );

    // curvedAnimation is useful for non-linear curve to an animation object
    curvedAnimation =
        CurvedAnimation(parent: controller, curve: Curves.easeOut);

    //moves the card from the current position to -1000 left
    // doesn't work when the offset is changed to (0.0, -1000.0)
    _translationAnim = Tween(begin: Offset(0.0, 0.0), end: Offset(-1000.0, 0.0))
        .animate(controller)
      ..addListener(() {
        setState(() {});
      });

    // increases the size the card as it moves to the center
    _scaleAnim = Tween(begin: 0.965, end: 1.0).animate(curvedAnimation);

    // moves the card to the center
    _moveAnim = Tween (begin: Offset (0.0, 0.05), end: Offset(0.0, 0.0))
        .animate(curvedAnimation);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      // the stacks could be overflowed and are visible
        overflow: Overflow.visible,
        children: cards.reversed.map((card) {
          if (cards.indexOf(card) <= 3) {

            // detects the mouse movements
            return GestureDetector(
              // a pointer that was previously
              onHorizontalDragEnd: _onDragEnd,
              child: Transform.translate(

                offset: _getFlickTransformOffset(card),
                child: FractionalTranslation(
                  translation: _getStackedCardOffset(card),
                  child: Transform.scale(
                    scale: _getStackedCardScale(card),
                    child: Center(child: card),
                  ),
                ),
              ),
            );
          } else {
            return Container();
          }
        }).toList());
  }
  Offset _getStackedCardOffset(SwipeCard card) {
    int diff = card.index - currentIndex;
    if (card.index == currentIndex + 1) {
      return _moveAnim.value;
    } else if (diff > 0 && diff <= 3) {
      return Offset(0.0, 0.05 * diff);
    } else {
      return Offset(0.0, 0.0);
    }
  }
  double _getStackedCardScale(SwipeCard card) {
    int diff = card.index - currentIndex;
    if (card.index == currentIndex) {
      return 1.0;
    } else if (card.index == currentIndex + 1) {
      return _scaleAnim.value;
    } else {
      return (1 - (0.035 * diff.abs()));
    }
  }
  Offset _getFlickTransformOffset(SwipeCard card) {
    if (card.index == currentIndex) {
      return _translationAnim.value;
    }
    // return to the middle
    return Offset(0.0, 0.0);
  }
  void _onDragEnd(DragEndDetails details) {
    if (details.primaryVelocity < 0) {
      // Swiped Right to Left
      controller.forward().whenComplete(() {
        setState(() {
          controller.reset();
          SwipeCard removedCard = cards.removeAt(0);
          cards.add(removedCard);
          currentIndex = cards[0].index;
          if (widget.onCardChanged != null)
            widget.onCardChanged(cards[0].imageUrl);
        });
      });
    }
  }
}

// added
class DragScreenState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          )
        ],
      ),
    );
  }
}
// end of added

class SwipeCard extends StatelessWidget {
  final int index;
  final String imageUrl;
  SwipeCard({this.index, this.imageUrl});
  @override
  Widget build(BuildContext context) {
    TextStyle cardTitleStyle =
    Theme.of(context).textTheme.headline6.copyWith(fontSize: 24.0);
    TextStyle cardSubtitleStyle = Theme.of(context)
        .textTheme
        .headline6
        .copyWith(fontSize: 20.0, color: Colors.grey);
    TextStyle cardButtonStyle = Theme.of(context)
        .textTheme
        .headline6
        .copyWith(fontSize: 16.0, color: Colors.white);

    // the look of the card
    return Card(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 40.0),
        child: Column(children: [
          Image.asset("assets/$imageUrl"),
          FractionalTranslation(
            translation: Offset(1.7, -0.5),
//            child: FloatingActionButton(
//              mini: true,
//              backgroundColor: Colors.yellow,
//              child: Icon(Icons.star),
//              onPressed: () {},
//            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              "Location",
              style: cardTitleStyle,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              "Travel and Recreation",
              style: cardSubtitleStyle,
            ),
          ),
          RaisedButton(
            elevation: 2.0,
            color: Colors.blue,
            child: Text(
              "EXPLORE",
              style: cardButtonStyle,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            onPressed: () {},
          )
        ]),
      ),
    );
  }
}