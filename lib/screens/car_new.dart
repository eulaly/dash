import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dash/utils/garage_model.dart';
import 'package:dash/models/car.dart';
import 'package:dash/screens/screens.dart';

class NewCarScreen extends StatefulWidget {
  const NewCarScreen({super.key});

  @override
  State<NewCarScreen> createState() => _NewCarScreenState();
}

class _NewCarScreenState extends State<NewCarScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Car car = Car(); //initialization is required
  late IconPicker ip = IconPicker();
  late String selectedIcon = 'images/car.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Car'),
        backgroundColor: const Color.fromARGB(255, 185, 47, 5),
      ),
      body: Container(
        padding: const EdgeInsets.all(32),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
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
              ListTile(
                  leading: CircleAvatar(
                      backgroundImage: AssetImage(selectedIcon),
                      backgroundColor: Colors.white),
                  title: const Text("Change Icon"),
                  onTap: () => showDialog(
                      barrierColor: Colors.black.withOpacity(.5),
                      context: context,
                      builder: (BuildContext context) {
                        return ip;
                      }).then((value) => setState(
                        () {
                          // selectedIcon = ip.selectedIcon;
                          selectedIcon = value;
                        },
                      ))),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  // onPressed: () => _onSubmit(context),
                  onPressed: () {
                    final form = formKey.currentState!;
                    if (form.validate()) {
                      //validate form
                      form.save(); //save values (reqd before putting them anywhere)
                      setState(() {
                        //modify state of car (necessary?)
                        car = Car(
                            vin: car.vin,
                            nickname: car.nickname,
                            plate: car.plate,
                            icon: selectedIcon,
                            mileage: car.mileage);
                      });
                      // var garage = context.read<GarageModel>();
                      // garage.add(car);
                      Provider.of<GarageModel>(context, listen: false).add(car);
                      form.reset();
                      // Navigator.pop(context);
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
    final form = formKey.currentState!;
    if (form.validate()) {
      //validate form
      form.save(); //save values (reqd before putting them anywhere)
      setState(() {
        //modify state of car (necessary?)
        car = Car(
            vin: car.vin,
            nickname: car.nickname,
            plate: car.plate,
            mileage: car.mileage);
      });
      var garage = context.read<GarageModel>(); //implement Provider
      garage.add(car);
      form.reset();
      Navigator.pushNamed(context, '/');
    }
  }

  void submit(BuildContext context) async {
    var garage = context.read<GarageModel>();

    final form = formKey.currentState!;
    if (form.validate()) {
      //validate form
      form.save(); //save values (reqd before putting them anywhere)
      setState(() {
        //modify state of car (necessary?)
        car = Car(
            vin: car.vin,
            nickname: car.nickname,
            plate: car.plate,
            mileage: car.mileage);
      });
      garage.add(car);
      // Provider.of<GarageModel>(context).add(car);
      form.reset();
      Navigator.pop(context);
      // Navigator.pushNamed(context, '/');
    }
  }
}
