//定义一些比例
import 'package:flutter/cupertino.dart';

class WH {
  static double w(BuildContext context) {
    return 0.86 * MediaQuery.of(context).size.width;
  }

  static double h(BuildContext context) {
    return 0.8 * MediaQuery.of(context).size.height;
  }

  static double playerWith(BuildContext context) {
    return 0.7 * MediaQuery.of(context).size.width;
  }

  static double playerHeight(BuildContext context) {
    return 0.7 * MediaQuery.of(context).size.height;
  }

  static double personWith(BuildContext context) {
    return 0.7 * MediaQuery.of(context).size.width;
  }

  static double personHeight(BuildContext context) {
    return 0.5 * MediaQuery.of(context).size.height;
  }
}
