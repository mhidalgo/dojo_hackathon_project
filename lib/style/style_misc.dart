import 'package:flutter/material.dart';

borderRadius1() {
  return BorderRadius.only(
    topLeft: Radius.circular(6),
    topRight: Radius.circular(6),
    bottomLeft: Radius.circular(6),
    bottomRight: Radius.circular(6),
  );
}

borderRadius2() {
  return BorderRadius.only(
    topLeft: Radius.circular(12),
    topRight: Radius.circular(12),
    bottomLeft: Radius.circular(12),
    bottomRight: Radius.circular(12),
  );
}

roundCornersRadius() {
  return BorderRadius.only(
    topLeft: Radius.circular(80),
    topRight: Radius.circular(80),
    bottomLeft: Radius.circular(80),
    bottomRight: Radius.circular(80),
  );
}

boxShadow1() {
  return BoxShadow(
    color: Colors.black.withOpacity(0.3),
    blurRadius: 5,
    offset: Offset(5, 5),
  );
}