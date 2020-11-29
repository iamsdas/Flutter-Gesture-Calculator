import 'package:touch_calculator/classifier.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class ClassifierFloat extends Classifier {
  ClassifierFloat({int numThreads}) : super(numThreads: numThreads);

  @override
  String get modelName => 'model-cal.tflite';

  @override
  NormalizeOp get preProcessNormalizeOp => NormalizeOp(0, 255);

  @override
  NormalizeOp get postProcessNormalizeOp => NormalizeOp(0, 1);
}
