import 'dart:collection';
import 'package:dash/utils/dbhelper_sqflite.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
import 'package:dash/models/car.dart';
import 'package:dash/models/txn.dart';
// import 'package:flutter/src/widgets/form.dart';

void main() async {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GarageModel(),
      child: const MaterialApp(
        title: 'Dashboard',
        home: MyApp(),
/*         initialRoute: '/',
        routes: {
          '/': (context) => const MyApp(),
          '/about': (context) => const AboutScreen(),
          '/newcar': (context) => const NewCarScreen(),
          '/detail': (context) => CarDetailScreen(),
          '/edit': (context) => EditCarScreen(),
        }, */
      ),
    ),
  );
  // WidgetsFlutterBinding.ensureInitialized(); // is this necessary?
}

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
    // delete rows from CarTable
    _cars.clear();
    _dbHelper.deleteAll();
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
  void initState() {
    _cars = Provider.of<GarageModel>(context, listen: false).getCars();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                  leading: const Icon(Icons.directions_car),
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

class CurrentCar extends StatefulWidget {
  const CurrentCar({super.key, required this.car});
  final Car car;

  @override
  State<CurrentCar> createState() => _CurrentCar();
}

class _CurrentCar extends State<CurrentCar> {
  late Future _txns;
  late Car car = widget.car;

  @override
  void initState() {
    _txns = Provider.of<GarageModel>(context, listen: false).getTxns(car.id!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _txns,
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
              return Expanded(child: Consumer<GarageModel>(
                builder: (context, garage, child) {
                  return ListView.separated(
                    // padding: const EdgeInsets.all(8),
                    itemCount: garage.txns.length,
                    itemBuilder: (context, index) => ListTile(
                        // dense: true, //only affects text, use visualDensity instead
                        visualDensity:
                            const VisualDensity(horizontal: 0, vertical: -4),
                        leading: const Icon(Icons.local_gas_station),
                        title: Text(garage.txns[index].txntype ?? "type"),
                        subtitle: Text(garage.txns[index].note ?? "note"),
                        onTap: (() => VoidCallback)),
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(),
                  );
                },
              ));
            }
          }
        });
  }
}

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const SizedBox(
            height: 80.0,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 185, 47, 5),
              ),
              child: Text(
                'Options',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              print('settings');
            },
            // do something
          ),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Setup Database'),
            onTap: () {
              print('dbsetup');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AboutScreen()));
            },
          ),
        ],
      ),
    );
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
    var garage = context.watch<GarageModel>(); // testing
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 185, 47, 5),
        title: const Text('Dashboard'),
      ),
      drawer: const MyDrawer(),
      body: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: ElevatedButton(
                onPressed: (() => garage.clearCarList()),
                // onPressed: (() => VoidCallback),
                onLongPress: () {
                  garage.deleteAllCars();
                  // VoidCallback;
                },
                child: Row(
                  children: const <Widget>[
                    Icon(Icons.delete),
                    Text('Remove All Cars'),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: ElevatedButton(
                onPressed: (() => garage.getCars()),
                // onPressed: (() => VoidCallback),
                child: Row(
                  children: const <Widget>[
                    Icon(Icons.sync),
                    Text('Refresh garage'),
                  ],
                ),
              ),
            ),
            const Garage(), // list of cars in garage
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const NewCarScreen()));
        },
      ),
    );
  }
}

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

class NewCarScreen extends StatefulWidget {
  const NewCarScreen({super.key});

  @override
  State<NewCarScreen> createState() => _NewCarScreenState();
}

class _NewCarScreenState extends State<NewCarScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Car _car = Car(); //initialization is required

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Car'),
        backgroundColor: Colors.indigo,
      ),
      body: Container(
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              //new car form text fields
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nickname',
                ),
                onSaved: (val) => setState(() => _car.nickname = val),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a nickname';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'VIN',
                ),
                onSaved: (val) => setState(() => _car.vin = val),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a unique VIN';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'License Plate',
                ),
                onSaved: (val) => setState(() => _car.plate = val),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a license plate';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Mileage',
                ),
                onSaved: (val) =>
                    setState(() => _car.mileage = int.parse(val ?? "")),
                // inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]  //try this?
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
                  // onPressed: () => _onSubmit(context),
                  onPressed: () {
                    final _form = _formKey.currentState!;
                    if (_form.validate()) {
                      //validate form
                      _form
                          .save(); //save values (reqd before putting them anywhere)
                      setState(() {
                        //modify state of car (necessary?)
                        _car = Car(
                            vin: _car.vin,
                            nickname: _car.nickname,
                            plate: _car.plate,
                            mileage: _car.mileage);
                      });
                      var garage = context.read<GarageModel>();
                      garage.add(_car);
                      _form.reset();
                      Navigator.pushNamed(context, '/');
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

  _onSubmit(context) async {
    final _form = _formKey.currentState!;
    if (_form.validate()) {
      //validate form
      _form.save(); //save values (reqd before putting them anywhere)
      setState(() {
        //modify state of car (necessary?)
        _car = Car(
            vin: _car.vin,
            nickname: _car.nickname,
            plate: _car.plate,
            mileage: _car.mileage);
      });
      var garage = context.read<GarageModel>(); //implement Provider
      garage.add(_car);
      _form.reset();
      Navigator.pushNamed(context, '/');
    }
  }
}

class CarDetailScreen extends StatefulWidget {
  CarDetailScreen({super.key, required this.carIndex});
  final int carIndex;
  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {
  late Car car = context.watch<GarageModel>()._cars[widget.carIndex];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 185, 47, 5),
        title: Text(car.nickname ?? ""),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text("plh img picker"),
                Center(
                  // edit car screen
                  child: Ink(
                    decoration: const ShapeDecoration(
                        color: Colors.lightBlue, shape: CircleBorder()),
                    child: IconButton(
                      icon: const Icon(Icons.edit),
                      color: Colors.white,
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditCarScreen(
                                  car: car, carIndex: widget.carIndex)),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            IconButton(
              iconSize: 48.0,
              icon: const Icon(Icons.directions_car),
              onPressed: (() => VoidCallback),
            ),
            Text("Nickname: ${car.nickname}"),
            Text("VIN: ${car.vin}"),
            Text("License Plate: ${car.plate}"),
            Text("Mileage: ${car.mileage.toString()}"),
            CurrentCar(car: car),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => NewTxn(car: car, carIndex: widget.carIndex),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class EditCarScreen extends StatefulWidget {
  EditCarScreen({super.key, required this.car, required this.carIndex});
  Car car;
  int carIndex;

  @override
  State<EditCarScreen> createState() => _EditCarScreenState();
}

class _EditCarScreenState extends State<EditCarScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Car car = widget.car;
  late int carIndex = widget.carIndex;

  @override
  Widget build(BuildContext context) {
    var garage = context.read<GarageModel>();
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit ${car.nickname}"),
        backgroundColor: const Color.fromARGB(255, 185, 47, 5),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                initialValue: car.nickname,
                decoration: const InputDecoration(
                  labelText: 'Nickname',
                ),
                onSaved: (val) => setState(() => car.nickname = val),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a nickname';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: car.vin,
                decoration: const InputDecoration(
                  labelText: 'VIN',
                ),
                onSaved: (val) => setState(() => car.vin = val),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a unique VIN';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: car.plate,
                decoration: const InputDecoration(
                  labelText: 'License Plate',
                ),
                onSaved: (val) => setState(() => car.plate = val),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a license plate';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: car.mileage.toString(),
                decoration: const InputDecoration(
                  labelText: 'Mileage',
                ),
                onSaved: (val) =>
                    setState(() => car.mileage = int.parse(val ?? "")),
                // inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]  //try this?
                keyboardType: TextInputType.number,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter car\'s current mileage';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ElevatedButton(
                  onPressed: () {
                    final updateForm = _formKey.currentState!;
                    if (updateForm.validate()) {
                      //validate form
                      updateForm
                          .save(); //save values (reqd before putting them anywhere)
                      garage.update(car, carIndex);
                      updateForm.reset();
                      Navigator.pushNamed(context, '/');
                    }
                  },
                  child: Row(
                    children: const <Widget>[
                      //expand these children, too tight
                      Icon(Icons.save),
                      Text('Save Changes'),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ElevatedButton(
                  onPressed: (() => VoidCallback),
                  onLongPress: () {
                    garage.delete(car);
                    Navigator.pushNamed(context, '/');
                  },
                  child: Row(children: const <Widget>[
                    Icon(Icons.delete),
                    Text('Delete'),
                  ]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ElevatedButton(
                  onPressed: (() => VoidCallback),
                  child: Row(children: const <Widget>[
                    Icon(Icons.sync_alt),
                    Text('enable/disable'),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NewTxn extends StatefulWidget {
  NewTxn({super.key, required this.car, required this.carIndex});
  Car car;
  int carIndex;

  @override
  State<NewTxn> createState() => _NewTxnState();
}

class _NewTxnState extends State<NewTxn> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Car car = widget.car;
  late int carIndex = widget.carIndex;
  DateTime datetime = DateTime.now();
  Txn txn = Txn();
  bool refresh = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? timepicked = await showDatePicker(
        context: context,
        initialDate: datetime,
        firstDate: DateTime.utc(1776, 7, 4),
        lastDate: DateTime.utc(2222, 2, 22));
    if (timepicked != null && timepicked != datetime) {
      setState(() => datetime = timepicked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add new txn for ${car.nickname}"),
        backgroundColor: const Color.fromARGB(255, 185, 47, 5),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // txntype - change to dropdown

              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Type',
                ),
                onSaved: (val) => setState(() => txn.txntype = val),
              ),
              Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: IconButton(
                        onPressed: () => _selectDate(context),
                        icon: const Icon(Icons.calendar_month)),
                  ),
                  Flexible(
                    flex: 3,
                    child: InputDatePickerFormField(
                        firstDate: DateTime.utc(1776, 7, 4),
                        lastDate: DateTime.utc(2222, 2, 22),
                        initialDate: datetime,
                        onDateSaved: (val) => setState(
                            () => txn.datetime = val.millisecondsSinceEpoch)),
                  ),
                ],
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Cost',
                ),
                initialValue: "0",
                onSaved: (val) =>
                    setState(() => txn.cost = double.parse(val ?? "0")),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                initialValue: car.mileage.toString(),
                decoration: const InputDecoration(
                  labelText: 'Mileage',
                ),
                onSaved: (val) =>
                    setState(() => txn.mileage = int.parse(val ?? "")),
                keyboardType: TextInputType.number,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Must be >= current mileage";
                  } else if (int.parse(value) < car.mileage!.toInt()) {
                    return 'Must be >= current mileage';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Note',
                ),
                onSaved: (val) => setState(() => txn.note = val),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ElevatedButton(
                  onPressed: () {
                    final form = _formKey.currentState!;
                    if (form.validate()) {
                      form.save();
                      setState(() {
                        txn.datetime = DateTime.now().millisecondsSinceEpoch;
                        txn.carid = car.id;
                        car.mileage = txn.mileage; // update car mileage too
                      });
                      var garage = context.read<GarageModel>();
                      garage.update(car, carIndex);
                      print(txn.toMap());
                      garage.insertTxn(txn);
                      form.reset();
                      Navigator.pop(context);
                    }
                  },
                  child: Row(
                    children: const <Widget>[
                      //expand these children, too tight
                      Icon(Icons.save),
                      Text('Save Changes'),
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

/* class IconPicker extends SimpleDialog {
  IconPicker({super.key})

  @override
  Widget build (BuildContext context) {
    return SimpleDialog(
      title: const Text("Pick an icon"),

    );
  }
} */