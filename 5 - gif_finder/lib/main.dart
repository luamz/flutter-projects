import 'package:flutter/material.dart';
import "package:gif_finder/ui/home_page.dart";


void main() {
  runApp(MaterialApp(
    title: "Gif Finder",
    home: HomePage(),
    theme: ThemeData(
      primaryColor: Colors.white
    ),
    debugShowCheckedModeBanner: false,
  ));
}


