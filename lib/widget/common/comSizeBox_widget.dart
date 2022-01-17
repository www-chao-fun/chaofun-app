import 'dart:ffi';

import 'package:flutter/material.dart';

class ComSizedBox extends StatelessWidget {
  int num;
  ComSizedBox({Key key, this.num}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 10,
    );
  }
}
