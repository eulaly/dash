import 'package:flutter/material.dart';
// import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:dash/utils/garage_model.dart';
// import 'package:dash/main.dart';
import 'package:dash/models/car.dart';
import 'package:dash/screens/screens.dart';
import 'package:google_fonts/google_fonts.dart';

class CarDetailScreen extends StatefulWidget {
  const CarDetailScreen({super.key, required this.carIndex});
  final int carIndex;
  // late Car car;

  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {
  //investigate
  // late Car car = context.watch<GarageModel>()._cars[widget.carIndex];

  @override
  Widget build(BuildContext context) {
    late Car car = Provider.of<GarageModel>(context).cars[widget.carIndex];
    // late Car car = context.watch<GarageModel>()_cars[widget.carIndex];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 185, 47, 5),
        title: Text(car.nickname ?? ""),
        // title: const Text("View Car"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Center(
                  // edit car
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
                              builder: (context) =>
                                  EditCarScreen(carIndex: widget.carIndex)),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            Consumer<GarageModel>(
              builder: (context, garage, child) => Column(
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("${garage.cars[widget.carIndex].nickname}"),
                      ]),
                  Text(
                    "Nickname: ${garage.cars[widget.carIndex].nickname}",
                    style: GoogleFonts.crimsonPro(),
                  ),
                  Text(
                    "VIN: ${garage.cars[widget.carIndex].vin}",
                    style: GoogleFonts.crimsonPro(),
                  ),
                  Text("License Plate: ${garage.cars[widget.carIndex].plate}"),
                  Text(
                      "Mileage: ${garage.cars[widget.carIndex].mileage.toString()}"),
                  CircleAvatar(
                      backgroundImage: AssetImage(
                          garage.cars[widget.carIndex].icon ??
                              'images/car.png'),
                      backgroundColor: Colors.white),
                ],
              ),
            ),
            CarTxns(carIndex: widget.carIndex),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => NewTxnScreen(carIndex: widget.carIndex),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CarTxns extends StatefulWidget {
  const CarTxns({super.key, required this.carIndex});
  final int carIndex;

  @override
  State<CarTxns> createState() => _CarTxns();
}

class _CarTxns extends State<CarTxns> {
  late Future _txns;
  late Car car;

  @override
  void initState() {
    car =
        Provider.of<GarageModel>(context, listen: false).cars[widget.carIndex];
    _txns = Provider.of<GarageModel>(context, listen: false).getTxns(car.id!);
    super.initState();
  }

  Icon getIcon(String? txntype) {
    if (txntype == 'Gas') {
      return (const Icon(Icons.local_gas_station));
    } else if (txntype == 'Oil') {
      return (const Icon(Icons.water_drop));
    } else if (txntype == 'Other') {
      return (const Icon(Icons.build));
    } else {
      return (const Icon(Icons.question_mark));
    }
  }

  @override
  Widget build(BuildContext context) {
    // car =
    // Provider.of<GarageModel>(context, listen: false).cars[widget.carIndex];
    // _txns = Provider.of<GarageModel>(context, listen: false).getTxns(car.id!);
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
                        leading: getIcon(garage.txns[index].txntype),
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
