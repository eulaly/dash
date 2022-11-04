// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dash/utils/dbhelper_sqflite.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/provider.dart';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


void main() async {
  runApp(MaterialApp(home: MyApp()));
  final dbHelper = DbHelperSqlite.instance; //medium method

  var newCar = const Car(
    vin: '123abc',
    plate: 'n1ce',
    nickname: 'My Car',
    owner: 'Ben',
    mileage: 7,
  );
}

class Car {
  final String vin;
  final String plate;
  final String nickname;
  final int mileage;
  final String owner;

  const Car({
    required this.vin,
    required this.plate,
    required this.nickname,
    required this.owner,
    required this.mileage,
  });

  // build map, keys must match db col names
  Map<String, dynamic> toMap() {
    return {
      'vin': vin,
      'plate': plate,
      'nickname': nickname,
      'owner': owner,
      'mileage': mileage,
    };
  }

  @override
  String toString() {
    return 'Car{nickname: $nickname, vin: $vin, plate: $plate, owner: $owner}';
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    Widget carInfo = Container(
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        Image.asset(
          'images/mazda.png',
        ),
        Icon(
          Icons.directions_car_filled,
          color: Colors.red[500],
        ),
        const Text('Nickname'),
      ]),
    );

    return MaterialApp(
      title: 'Dashboard App',
      // home: const ManageScreen(),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.indigo,
          title: const Text('Dashboard'),
          // leading: IconButton(
          //   icon: const Icon(Icons.menu),
          // ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const SizedBox(
                height: 64.0,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Text(
                    'Header',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                onTap: () {
                  print('settings');
                },
                // do something
              ),
              ListTile(
                leading: Icon(Icons.sync),
                title: Text('Setup Database'),
                onTap: () {
                  print('dbsetup');
                  
                },
              ),
              ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('About'),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const AboutScreen()));
                },
              ),
            ],
          ),
        ),
        body: ListView.builder(itemBuilder: (_, index) {
          return Container(
            padding: const EdgeInsets.all(8),
            child: carInfo,
          );
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const NewCarScreen()));
          },
        ),
      ),
    );
  }
}

class AboutScreen extends StatelessWidget { // change to AboutDialog
  const AboutScreen({super.key});           //https://api.flutter.dev/flutter/material/AboutDialog-class.html

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('About Page'),
          backgroundColor: Colors.indigo,
        ),
        body: const Center(
          child: Text('About Page Text, Lorum Ipsum and whatnot.'),
        ));
  }
}

class NewCarScreen extends StatefulWidget {
  const NewCarScreen({super.key});

  @override
  State<NewCarScreen> createState() => _NewCarScreenState();
}

class _NewCarScreenState extends State<NewCarScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Car'),
        backgroundColor: Colors.indigo,
      ),
      body: Container(
        padding: EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Text('Add new car form here'),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Nickname for this car',
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a nickname';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Unique VIN',
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a unique VIN';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Mileage',
                ),
                keyboardType: TextInputType.number,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter car\'s current mileage';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // process
                    }
                  },
                  child: Row(
                    children: const <Widget>[
                      Icon(Icons.add),
                      Text('Add Car'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class SelectCarIconScreen extends StatelessWidget {
  const SelectCarIconScreen({super.key});

  @override 
  Widget build(BuildContext context) {
    return 
  }
}