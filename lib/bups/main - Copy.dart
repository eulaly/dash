import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
// import 'package:flutter/src/widgets/form.dart';

void main() async {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GarageModel(),
      child: MaterialApp(
        title: 'Dashboard',
        initialRoute: '/',
        routes: {
          '/' : (context) => const MyApp(),
          '/newcar' : (context) => const NewCarScreen(),
          '/about': (context) => const AboutScreen(),
        },
        // home: MyApp()
      ),
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();
  final database = openDatabase(
    join(await getDatabasesPath(), 'dash_db_sqlite.db'),
    onCreate: (db, version) {
      return db.execute(
        '''CREATE TABLE cars(
            id INT INCREMENT,
            nickname STRING,
            vin STRING PRIMARY KEY,
            mileage INT,
            owner STRING)''',
      );
    },
    version: 1,
  );

/* 
  Future<void> insertCar(Car car) async {
    final db = await database;
    await db.insert(
      'cars',
      car.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<Car>> getCars() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cars');
    return List.generate(maps.length, (i) {
      return Car(
        nickname: maps[i]['nickname'],
        vin: maps[i]['vin'],
        plate: maps[i]['plate'],
        mileage: maps[i]['mileage'],
        owner: maps[i]['owner'],
      );
    });
  }

  Future<void> updateCar(Car car) async {
    final db = await database;
    await db.update(
      'cars',
      car.toMap(),
      where: 'vin=?',
      whereArgs: [car.vin],
    );
  }

  Future<void> deleteCar(Car car) async {
    final db = await database;
    await db.delete(
      'cars',
      where: 'vin=?',
      whereArgs: ['vin'],
    );
  }
 */
}

class GarageModel extends ChangeNotifier {
   /// internal state of garage
   final List<Car> _cars = [];

   UnmodifiableListView<Car> get cars => UnmodifiableListView(_cars);

  void add(Car car) {
    _cars.add(car);
    notifyListeners();
  }

  void removeAll() {
    _cars.clear();
    notifyListeners();
  }
}

/* class Car {
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
} */

class Car {
  Car({this.vin, this.plate, this.nickname, this.owner, this.mileage});

  String? vin;
  String? plate;
  String? nickname;
  String? owner;
  int? mileage;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _formKey = GlobalKey<FormState>();

/*     _list() => Expanded(
      child: Card(
        margin: EdgeInsets.fromLTRB(20,30,20,0),
        child: ListView.builder(
          padding: EdgeInsets.all(8),
          itemBuilder: (context, index){
            return Column(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.directions_car),
                  title: Text(_cares[index].nickname ?? ''),
                  subtitle: Text(_cares[index].vin ?? '')m
                ),
                Divider(height: 5.0),
              ]
            );
          },
          itemCount: _cares.length,
        )
      )
    ); */

/*     Widget carInfo = Container(
      padding: const EdgeInsets.all(16),
      child: _list(),
    ); */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Container(
        color: Colors.lightBlue,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: _CarList(),
              ),
            ),
            const Divider(height: 3, color: Colors.grey),
          ]
        )
      ),
      /* ListView.builder(itemBuilder: (_, index) {
        return Container(
          padding: const EdgeInsets.all(8),
          child: carInfo,
        );
      }), */
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () { //replace with route
          Navigator.pushNamed(context, '/newcar');
          /* Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const NewCarScreen())); */
        },
      ),
    );
  }

  // _list() => Container();

  void updateCars(Care care) {
    setState(() {
      _cares.add(care);
    });
  } //will this work???????????????????????????
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
  Care _care = Care();
  List<Care> _cares = [];

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
              //new car form text fields
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nickname',
                ),
                onSaved: (val) => setState(() => _care.nickname = val),
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
                onSaved: (val) => setState(() => _care.vin = val),
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
                    setState(() => _care.mileage = int.parse(val ?? "")),
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _onSubmit();
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

  _onSubmit() {
    var form = _formKey.currentState!;
    // _formKey.currentState!.save();
    form.save(); //callback in form text fields
    print(_care.nickname);
    setState(() { //ensure you re-pass values, 
      _cares.add(Care(vin:_care.vin,nickname:_care.nickname,owner:_care.owner, plate:_care.plate, mileage:_care.mileage));
    });
    setState(() {
      widget._list.add(_care));
    });
    // widget.onSubmit(_care); 
    form.reset();
  }

  Future<void> _returnHome(BuildContext context) async {
    final newCar = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyApp()),
    );

    if (!mounted) return;
  }
}



/* class SelectCarIconScreen extends StatelessWidget {
  const SelectCarIconScreen({super.key});

  @override 
  Widget build(BuildContext context) {
    return 
  }
} */