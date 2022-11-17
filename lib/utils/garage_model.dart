// ignore_for_file: file_names

import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dash/utils/dbhelper_sqflite.dart';
import 'package:dash/models/car.dart';
import 'package:dash/models/txn.dart';
import 'package:dash/screens/screens.dart';

class GarageModel extends ChangeNotifier {
  /// internal state of garage
  late List<Car> _cars = [];
  late List<Txn> _txns = []; // hold current car txns, repl on new load
  final DbHelperSqlite _dbHelper = DbHelperSqlite.instance;
  UnmodifiableListView<Car> get cars => UnmodifiableListView(_cars);
  UnmodifiableListView<Txn> get txns => UnmodifiableListView(_txns);

  void add(Car car) {
    // _cars.add(car);
    _dbHelper.insertCar(car);
    getCars(); // prob nec to update `id`
    notifyListeners();
  }

  void update(Car car, int carIndex) {
    _cars[carIndex] = car; // replace list car with new values
    _dbHelper.updateCar(car);
    print('updated car ${car.toMap()}');
    getCars();
    // print(_cars);
    notifyListeners();
  }

  void delete(Car car) {
    // ignore: no_leading_underscores_for_local_identifiers
    _cars.removeWhere((_car) => _car.id == car.id);
    _dbHelper.deleteCar(car);
    print('$car with id ${car.id} deleted');
    getCars();
    notifyListeners();
  }

  void clearCarList() {
    // clear _cars; doesn't affect database
    // useful for clearing cars that didn't make it into the db
    _cars.clear();
    notifyListeners();
  }

  void deleteAllCars() {
    // delete rows from CarTable AND TxnTable
    _cars.clear();
    _dbHelper.deleteAllCars();
    _dbHelper.deleteAllTxns();
    notifyListeners();
  }

  Future<void> getCars() async {
    // _cars.clear();
    print('getcars');
    _cars = await _dbHelper.fetchCars();
    print(_cars);
    // notifyListeners(); //for some reason this inits db infinitely
  }

  void insertTxn(Txn txn) async {
    await _dbHelper.insertTxn(txn);
    // update car
    await getTxns(txn.carid!);
    notifyListeners();
  }

  void deleteTxn(Txn txn) {
    _dbHelper.deleteTxn(txn);
    // get old mileage from car
    notifyListeners();
  }

  void deleteAllTxns() {
    // delete rows from TxnTabls
    _dbHelper.deleteAllTxns();
    // get old mileage from car
    notifyListeners();
  }

  Future<void> getTxns(int carid) async {
    _txns = await _dbHelper.fetchTxns(carid);
    print('get txns: $_txns');
  }
}

class Garage extends StatefulWidget {
  const Garage({super.key});
  @override
  State<Garage> createState() => _Garage();
}

class _Garage extends State<Garage> {
  late Future _cars;

  @override
  Widget build(BuildContext context) {
    _cars = Provider.of<GarageModel>(context, listen: false).getCars();
    return FutureBuilder(
      future: _cars,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          if (snapshot.error != null) {
            return const Center(
              child: Text('An error occurred'),
            );
          } else {
            return Expanded(
                child: Consumer<GarageModel>(builder: (context, garage, child) {
              return ListView.separated(
                itemCount: garage._cars.length,
                itemBuilder: (context, index) => ListTile(
                  leading: CircleAvatar(
                      backgroundImage: AssetImage(
                          garage.cars[index].icon ?? 'images/car.png'),
                      backgroundColor: Colors.white),
                  title: Text(garage.cars[index].nickname ?? "nick_ph"),
                  subtitle: Text(garage.cars[index].vin ?? "vin_ph"),
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(
                          builder: (context) =>
                              CarDetailScreen(carIndex: index),
                        ))
                        .then((value) => setState(() {}));
                  },
                ),
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
              );
            }));
          }
        }
      },
    );
  }
}
