import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui' as ui;
import 'package:web_socket_channel/io.dart';
import 'dart:convert';
import 'dart:async';

void main() => runApp(new SnakeApp());

class SnakeApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Snake',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      // PUT YOUR CODE HERE
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _HomePageState createState() => new _HomePageState();
}

List<dynamic> _playerSnakes;
List<dynamic> _snakes;
List<dynamic> _snake;

class _HomePageState extends State<HomePage> {

  void _left() {
    // PUT YOUR CODE HERE

    _updateSnakes();
  }

  void _right(){
    //PUT YOUR CODE HERE

    _updateSnakes();
  }

  void _updateSnakes(){
    setState(() {
      _snakes = _playerSnakes + [_snake];
    });
  }

  @override
  void initState(){
    super.initState();

    _playerSnakes = [];

    _snakes = [];

    _snake = [];

    IOWebSocketChannel _channel;

    _channel = new IOWebSocketChannel.connect('ws://testing.route.technology:40004');

    Map<String, dynamic> response;

    _channel.stream.listen((m) {
      if(m!=null) {
        response = JSON.decode(m);
        if (response["snake"]!=null && response["snake"]["coords"]!=null) {
          // PUT YOUR CODE HERE
          _updateSnakes();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Snake - Home"),
      ),
      body: new Stack(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        children: <Widget>[
          new SnakeField(),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              new Container(
                alignment: Alignment.centerLeft,
                child: new FlatButton(child: new Icon(Icons.rotate_left),
                  onPressed: _left,
                ),
              ),
              new Container(
                alignment: Alignment.centerRight,
                child: new FlatButton(
                  child: new Icon(Icons.rotate_right),
                  // PUT YOUR CODE HERE
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SnakeField extends StatefulWidget {

  @override
  _SnakeFieldState createState() => new _SnakeFieldState();
}

class _SnakeFieldState extends State<SnakeField> with SingleTickerProviderStateMixin {

  AnimationController _animation;

  @override
  void initState(){
    super.initState();

    _animation = new AnimationController(
      duration: const Duration(milliseconds: 1),
      vsync: this,
    )..repeat();

  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var _squareSize = 5.0;
    var _fieldSize = MediaQuery.of(context).size.width;

    CustomPaint paint = new CustomPaint(
        painter: new SnakeFieldPainter(100.0, 100.0, _squareSize),
        size: new Size(_fieldSize,_fieldSize),
    );

    return paint;
  }
}

class SnakeFieldPainter extends CustomPainter {
  final double _size;
  final double _x;
  final double _y;

  SnakeFieldPainter(this._x, this._y, this._size);

  @override
  void paint(Canvas canvas, Size size) {
    final int _columns = size.width ~/ _size;
    final double _snakeSize = 5.0;

    // create grid
    for(var i = 0; i<_columns; i++) {
      canvas.drawLine(
          new Offset(_snakeSize*i, 0.0), new Offset(_snakeSize*i, size.height),
          new Paint()..color = new Color.fromARGB(1000, 0, 0, 0)
      );
      canvas.drawLine(
          new Offset(0.0, _snakeSize*i), new Offset(size.width, _snakeSize*i),
          new Paint()..color = new Color.fromARGB(1000, 0, 0, 0)
      );
    }

    // draw snakes
    Offset pointA;
    Offset pointB;
    for(var _theSnake in _snakes) {
      for (var s in _theSnake) {
        pointA = new Offset(
            s[0] * _snakeSize,
            s[1] * _snakeSize
        );
        pointB = new Offset(
            s[0] * _snakeSize + _size,
            s[1] * _snakeSize + _size
        );
        canvas.drawRect(
            new Rect.fromPoints(pointA, pointB),
            new Paint()..color = new Color.fromARGB(900, 255, 0, 0)
        );
      }
    }
    print("paint");
  }

  @override
  bool shouldRepaint(SnakeFieldPainter oldDelegate) {
    return true;
  }
}

void toasting(BuildContext context, String msg){
  Scaffold.of(context).showSnackBar(new SnackBar(content: new Text(msg)));
}

