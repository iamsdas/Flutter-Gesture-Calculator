import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:touch_calculator/classifier.dart';
import 'package:touch_calculator/classifier_float.dart';
import 'package:touch_calculator/sketcher.dart';
import 'package:math_expressions/math_expressions.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Gesture Calculator",
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Classifier _classifier;
  String _prediction = "";
  List<Offset> points = <Offset>[];
  final Parser mathParser = Parser();
  final contextModel = ContextModel();

  @override
  void initState() {
    super.initState();
    _classifier = ClassifierFloat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("calc")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(10),
              child: _prediction != null
                  ? Text(
                      _prediction,
                      style: TextStyle(fontSize: 100),
                    )
                  : Text("draw number"),
            ),
          ),
          Container(
            color: Colors.black38,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.35,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  fit: FlexFit.tight,
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    color: Colors.white,
                    child: GestureDetector(
                      onPanUpdate: (DragUpdateDetails details) {
                        setState(() {
                          Offset point = details.localPosition;
                          points = List.from(points)..add(point);
                        });
                      },
                      onPanEnd: (DragEndDetails details) async {
                        List _rawImage = (await (await rendered)
                                .toByteData(format: ui.ImageByteFormat.png))
                            .buffer
                            .asUint8List();
                        img.Image imgInput = img.copyResizeCropSquare(
                            img.decodeImage(_rawImage), 50);
                        String _currPred = _classifier.predict(imgInput).label;

                        setState(() {
                          points = List.from(points)..clear();
                          _prediction += _currPred;
                        });
                      },
                      child: ClipRect(
                        child: CustomPaint(
                          painter: Sketcher(points),
                        ),
                      ),
                    ),
                  ),
                ),
                Column(
                  children: [
                    FlatButton(
                      onPressed: () => clear(),
                      child: Text(
                        "AC",
                        style: TextStyle(fontSize: 26),
                      ),
                    ),
                    FlatButton(
                      onPressed: () => back(),
                      child: Icon(Icons.backspace_outlined),
                    ),
                    FlatButton(
                      onPressed: () => equals(),
                      child: Text(
                        "=",
                        style: TextStyle(fontSize: 38),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void clear() {
    setState(() {
      _prediction = "";
    });
  }

  void back() {
    if (_prediction.isNotEmpty) {
      setState(() {
        _prediction = _prediction.substring(0, _prediction.length - 1);
      });
    }
  }

  Future<ui.Image> get rendered {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder);
    canvas.drawColor(Colors.white, BlendMode.src);
    Sketcher painter = Sketcher(points);
    var _size = context.size;
    painter.paint(canvas, _size);
    return recorder
        .endRecording()
        .toImage(_size.width.floor(), _size.width.floor());
  }

  void equals() {
    Expression exp = mathParser.parse(_prediction);
    setState(() {
      _prediction =
          (exp.evaluate(EvaluationType.REAL, contextModel)).toString();
    });
    _prediction = (exp.evaluate(EvaluationType.REAL, contextModel)).toString();
  }
}
