import 'package:flutter/material.dart';

class TxnType extends StatefulWidget {
  TxnType({super.key});
  late String selectedText;

  @override
  TxnTypeState createState() => TxnTypeState();
}

class TxnTypeState extends State<TxnType> {
  int selectedIndex = 0;

// should I do this? or set manually in the declaration
  @override
  void initState() {
    super.initState();
    selectedIndex = 0;
    widget.selectedText = "Gas";
  }

// how to cough up value?
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      rIcon(index: 0, text: "Gas", icon: Icons.local_gas_station),
      rIcon(index: 1, text: "Oil", icon: Icons.water_drop),
      rIcon(index: 2, text: "Other", icon: Icons.build),
      // rIcon(index: 3, text: "Renewal", icon: Icons.calendar_view_day),
    ]);
  }

  Widget rIcon(
      {required int index, required String text, required IconData icon}) {
    return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selectedIndex == index
              ? const Color.fromARGB(255, 185, 47, 5)
              : null,
        ),
        child: Ink(
            child: InkResponse(
                child: Column(
                  // mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      color: selectedIndex == index ? Colors.white : null,
                    ),
                    Text(text,
                        style: TextStyle(
                            color:
                                selectedIndex == index ? Colors.white : null))
                  ],
                ),
                onTap: () => setState(() {
                      selectedIndex = index;
                      widget.selectedText = text;
                    }))));
  }
}
