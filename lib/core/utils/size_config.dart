// lib/core/utils/size_config.dart
import 'package:flutter/material.dart';

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;
  static late Orientation orientation;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    orientation = _mediaQueryData.orientation;
    
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    double safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    double safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - safeAreaVertical) / 100;
  }

  // Responsive width (percentage based)
  static double width(double percentage) {
    return blockSizeHorizontal * percentage;
  }

  // Responsive height (percentage based)
  static double height(double percentage) {
    return blockSizeVertical * percentage;
  }

  // Safe area width
  static double safeWidth(double percentage) {
    return safeBlockHorizontal * percentage;
  }

  // Safe area height
  static double safeHeight(double percentage) {
    return safeBlockVertical * percentage;
  }

  // Responsive font size (scales based on screen width)
  static double fontSize(double size) {
    return size * (screenWidth / 375); // Base width 375 (iPhone SE)
  }

  // Responsive icon size
  static double iconSize(double size) {
    return size * (screenWidth / 375);
  }

  // Responsive padding/margin
  static EdgeInsets padding({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? right,
    double? top,
    double? bottom,
  }) {
    return EdgeInsets.only(
      left: left != null
          ? width(left)
          : (horizontal != null ? width(horizontal) : (all != null ? width(all) : 0)),
      right: right != null
          ? width(right)
          : (horizontal != null ? width(horizontal) : (all != null ? width(all) : 0)),
      top: top != null
          ? height(top)
          : (vertical != null ? height(vertical) : (all != null ? height(all) : 0)),
      bottom: bottom != null
          ? height(bottom)
          : (vertical != null ? height(vertical) : (all != null ? height(all) : 0)),
    );
  }

  // Responsive border radius
  static BorderRadius borderRadius(double radius) {
    return BorderRadius.circular(width(radius / 10));
  }

  // Responsive spacing
  static SizedBox verticalSpace(double percentage) {
    return SizedBox(height: height(percentage));
  }

  static SizedBox horizontalSpace(double percentage) {
    return SizedBox(width: width(percentage));
  }
}