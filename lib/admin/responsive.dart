import 'package:flutter/material.dart';

double getFont(BuildContext context, double size) {
  double width = MediaQuery.of(context).size.width;

  double scale = width / 400;

  return (size * scale).clamp(size * 0.85, size * 1.4);
}


double getPadding(BuildContext context, double size) {
  double width = MediaQuery.of(context).size.width;
  double scale = width / 400;
  return (size * scale).clamp(size * 0.7, size * 1.5);
}

