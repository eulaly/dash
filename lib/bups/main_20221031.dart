import 'dart:collection';
import 'package:dash/utils/dbhelper_sqflite.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
import 'package:dash/models/car.dart';
// import 'package:flutter/src/widgets/form.dart';

void main() async {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GarageModel(),
      child: const MaterialApp(
        title: 'Dashboard',
        home: MyApp(),
        /* initialRoute: '/',
        routes: {
          '/': (context) => const MyApp(),
          '/about': (context) => const AboutScreen(),
          '/newcar': (context) => const NewCarScreen(),
          '/detail': (context) => const CarDetailScreen(),
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
  final DbHelperSqlite _dbHelper = DbHelperSqlite.instance;
  UnmodifiableListView<Car> get cars => UnmodifiableListView(_cars);

  void add(Car car) {
    _cars.add(car);
    _dbHelper.insertCar(car);
    // getCars(); // prob nec to update `id`
    notifyListeners();
  }

  void update(Car car, int carIndex) {
    _cars[carIndex] = car; // replace list car with new values
    _dbHelper.updateCar(car);
    print('car.id is ${car.id}');
    getCars();
    notifyListeners();
  }

  void delete(Car car) {
    _cars.removeWhere((_car) => _car.id == car.id);
    _dbHelper.deleteCar(car);
    print('${car} deleted');
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
                // padding: const EdgeInsets.all(8),
                itemCount: garage._cars.length,
                itemBuilder: (context, index) => ListTile(
                    leading: const Icon(Icons.directions_car),
                    title: Text(garage.cars[index].nickname ?? "nick_ph"),
                    subtitle: Text(garage.cars[index].vin ?? "vin_ph"),
                    // onTap: () => Navigator.pushNamed(context, '/detail'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditCarScreen(
                                car: garage._cars[index], carIndex: index)),
                      );
                    }),
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

class _CarList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GarageModel>(
      builder: (context, garage, child) {
        return ListView.separated(
          // padding: const EdgeInsets.all(8),
          itemCount: garage._cars.length,
          itemBuilder: (context, index) => ListTile(
              leading: const Icon(Icons.directions_car),
              title: Text(garage.cars[index].nickname ?? "nick_ph"),
              subtitle: Text(garage.cars[index].vin ?? "vin_ph"),
              // onTap: () => Navigator.pushNamed(context, '/detail'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditCarScreen(
                          car: garage._cars[index], carIndex: index)),
                );
              }),
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
        );
      },
    );
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
    // context.watch<GarageModel>().getCars(); // testing
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
            const Garage(),
/*             FutureBuilder(
              future:
                  Provider.of<GarageModel>(context, listen: false).getCars(),
              builder: (context, dataSnapshot) {
                if (dataSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  if (dataSnapshot.error != null) {
                    return const Center(
                      child: Text('An error occurred'),
                    );
                  } else {
                    return Expanded(
                      child: _CarList(),
                    );
                  }
                }
              }, 
             ), */
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
  Car _car = Car(); //initialization is required

/*   DbHelperSqlite _dbHelper = DbHelperSqlite.instance;
  @override
  void initState() {
    super.initState();
    setState(() {
      _dbHelper = DbHelperSqlite.instance;
    });
  } */

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
                      var garage =
                          context.read<GarageModel>(); //implement Provider
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

class CarDetailScreen extends StatelessWidget {
  const CarDetailScreen({super.key});

  //garage? load car using Provider?
  // then feed to update screen

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 185, 47, 5),
        title: const Text('Vehicle Name'),
      ),
      drawer: const MyDrawer(),
      body: Container(
        padding: const EdgeInsets.all(32),
        child: const Text('Details here'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.edit),
        onPressed: () {
          Navigator.pushNamed(context, '/edit');
        },
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
  late Car car = widget.car; //initialization is required
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
              //new car form text fields
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
                      setState(() {
                        //modify state of car (necessary?)
                        car = Car(
                            vin: car.vin,
                            nickname: car.nickname,
                            plate: car.plate,
                            mileage: car.mileage);
                      }); //implement Provider
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
