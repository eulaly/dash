import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  // change to AboutDialog
  const AboutScreen(
      {super.key}); //https://api.flutter.dev/flutter/material/AboutDialog-class.html

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('About Page'),
          backgroundColor: const Color.fromARGB(255, 185, 47, 5),
        ),
        body: const Center(
          child: Text('About Page Text, Lorum Ipsum and whatnot.'),
        ));
  }
}
