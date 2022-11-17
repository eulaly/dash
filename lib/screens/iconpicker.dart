import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';

class IconPicker extends StatefulWidget {
  IconPicker({super.key});

  late String selectedIcon = 'images/car.png';

  @override
  State<IconPicker> createState() => _IconPickerState();
}

class _IconPickerState extends State<IconPicker> {
  late Future<String> manifestJson;
  late List<String> icons;
  late List<String> iconList;
  late List<String> items;

  TextEditingController editingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadAssets();
  }

  Future<List<String>> loadAssets() async {
    final manifestJson =
        await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    // ignore: no_leading_underscores_for_local_identifiers
    final _icons = await json
        .decode(manifestJson)
        .keys
        .where((String key) => key.startsWith('images/car_icons/'))
        .toList();
    setState(() {
      icons = _icons;
      items = _icons;
    });
    return _icons;
  }

  void runFilter(String query) {
    List<String> results = [];
    if (query.isEmpty) {
      results = icons;
    } else {
      results = icons
          .where((i) => i.substring(17, i.length - 4).contains(query))
          .toList();
    }
    setState(() {
      items = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Column(children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: "Search icons",
          ),
          onChanged: (value) {
            // filterSearch(value, iconList);
            runFilter(value);
            print('items found: $items');
          },
          // controller: editingController,
        ),
      ),
      Expanded(
          child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) => ListTile(
          leading: CircleAvatar(
            // backgroundImage: AssetImage(iconList[index]),
            backgroundImage: AssetImage(items[index]),
            backgroundColor: Colors.white,
          ),
          title: Text(items[index].substring(17, items[index].length - 4)),
          // title: Text(items[index]),
          onTap: () =>
              Navigator.of(context, rootNavigator: true).pop(items[index]),
          // onTap: (() => setState(() {
          // widget.selectedIcon = items[index];
          // })))),
        ),
      )),
    ]));
  }
}
