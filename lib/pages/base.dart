//定义一些比例
import 'package:flutter/cupertino.dart';

class WH {
  static double w(BuildContext context) {
    return 0.8 * MediaQuery.of(context).size.width;
  }

  static double h(BuildContext context) {
    return 0.8 * MediaQuery.of(context).size.height;
  }
}
