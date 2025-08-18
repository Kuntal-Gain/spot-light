import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle? headingStyle(
    {TextStyle? textstyle = const TextStyle(),
    required double size,
    required Color color}) {
  return GoogleFonts.pressStart2p(
    textStyle: textstyle,
    fontSize: size,
    color: color,
    fontWeight: FontWeight.w900,
  );
}

TextStyle? subHeadingStyle(
    {TextStyle? textstyle = const TextStyle(),
    required double size,
    required Color color}) {
  return GoogleFonts.pressStart2p(
    textStyle: textstyle,
    fontSize: size,
    color: color,
    fontWeight: FontWeight.w600,
  );
}

TextStyle? bodyStyle(
    {TextStyle? textstyle = const TextStyle(),
    required double size,
    required Color color}) {
  return GoogleFonts.pressStart2p(
    textStyle: textstyle,
    fontSize: size,
    color: color,
    fontWeight: FontWeight.w400,
  );
}
