import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dash/utils/garage_model.dart';
import 'package:dash/models/car.dart';

class EditCarScreen extends StatefulWidget {
  const EditCarScreen({super.key, required this.carIndex});
  final int carIndex;

  @override
  State<EditCarScreen> createState() => _EditCarScreenState();
}

class _EditCarScreenState extends State<EditCarScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late GarageModel garage;
  late Car car;
  late int carIndex = widget.carIndex;

  @override
  void initState() {
    super.initState();
    // garage = Provider.of<GarageModel>(context);
    // car = garage.cars[carIndex];
    // car = Provider.of<GarageModel>(context).cars[carIndex];
    // may need to add garage here, too
  }

  @override
  Widget build(BuildContext context) {
    // var garage = context.read<GarageModel>();
    garage = Provider.of<GarageModel>(context);
    car = garage.cars[carIndex];
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
                      Navigator.pop(context);
                      // Navigator.pushNamed(context, '/');
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
                    Navigator.pop(context);
                    // Navigator.pushNamed(context, '/');
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
