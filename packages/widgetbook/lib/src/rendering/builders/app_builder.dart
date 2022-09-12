import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const AppBuilderFunction defaultAppBuilder = _defaultAppBuilderMethod;

Widget _defaultAppBuilderMethod(BuildContext context, Widget child) {
  return WidgetsApp(
    color: Colors.transparent,
    debugShowCheckedModeBanner: false,
    home: child,
  );
}

AppBuilderFunction get materialAppBuilder =>
    (BuildContext context, Widget child) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: child,
      );
    };

AppBuilderFunction get cupertinoAppBuilder =>
    (BuildContext context, Widget child) {
      return CupertinoApp(
        debugShowCheckedModeBanner: false,
        home: child,
      );
    };

typedef AppBuilderFunction = Widget Function(
  BuildContext context,
  Widget child,
);
