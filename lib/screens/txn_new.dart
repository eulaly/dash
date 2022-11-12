import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dash/utils/garage_model.dart';
import 'package:dash/models/car.dart';
import 'package:dash/models/txn.dart';
import 'package:dash/screens/txn_type.dart';

class NewTxnScreen extends StatefulWidget {
  const NewTxnScreen({super.key, required this.carIndex});
  final int carIndex;

  @override
  State<NewTxnScreen> createState() => _NewTxnScreenState();
}

class _NewTxnScreenState extends State<NewTxnScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Car car;
  late int carIndex = widget.carIndex;
  // late var garage;
  DateTime datetime = DateTime.now();
  Txn txn = Txn();
  late TxnType txnType = TxnType();

  @override
  void initState() {
    car = Provider.of<GarageModel>(context, listen: false).cars[carIndex];
    // garage = Provider.of<GarageModel>(context, listen: false);
    super.initState();
  }

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
    // txnType = TxnType();
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
              txnType,
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
                        txn.txntype = txnType.selectedText;
                        print(
                            "txntype set to ${txn.txntype} from radio ${txnType.selectedText}");
                        txn.carid = car.id;
                        car.mileage = txn.mileage; // update car mileage too
                      });
                      print(txn.toMap());
                      Provider.of<GarageModel>(context, listen: false)
                          .update(car, carIndex);
                      Provider.of<GarageModel>(context, listen: false)
                          .insertTxn(txn);
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
