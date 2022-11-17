import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
// import '../images/car_icons.svg';

class IconPicker extends StatefulWidget {
  IconPicker({super.key});

  late final String? selectedIcon;

  @override
  State<IconPicker> createState() => _IconPickerState();
}

class _IconPickerState extends State<IconPicker> {
  late Future mfst;
  late final Future<String> manifestJson;
  late final Future<List<String>> icons;
  late List<String> iconList;
  late List<String> iconNames;
  late Map iconMap;
  late List<String> searchableList = [];
  late List<String> items;

  TextEditingController editingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    icons = loadAssets();
    // iconNames = buildIconList(icons);
  }

  Future<List<String>> loadAssets() async {
    final manifestJson =
        await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    // ignore: no_leading_underscores_for_local_identifiers
    final _icons = json
        .decode(manifestJson)
        .keys
        .where((String key) => key.startsWith('images/car_icons/'))
        .toList();
    return _icons;
  }

  List<String> buildIconList(List icons) {
    List<String> iN = [];
    for (var i in icons) {
      iN.add(i.substring(17, i.length - 4));
    }
    return iN;
  }

  void filterSearch(String query, List<String> iconList) {
    if (query.isNotEmpty) {
      for (var item in iconList) {
        if (item.contains(query)) {
          searchableList.add(item);
        }
      }
      setState(() {
        items.clear();
        items.addAll(searchableList);
        print(items);
      });
      return;
    } else {
      setState(() {
        items.clear();
        items.addAll(iconList);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // mfst = DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    // icons = json.decode(mfst).keys.where((String key) => key.startsWith('assets/images/car_icons_svg')).toList();
    // icons = loadAssets() as List;
    return FutureBuilder(
        future: icons,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.error != null) {
              return const Center(
                child: Text('An error occurred'),
              );
            } else {
              iconList = snapshot.data!;
              iconNames = buildIconList(iconList);
              print('iconlist is ${iconList.sublist(0, 5)}...');
              print('iconNames is ${iconNames.sublist(0, 5)}...');
              return Scaffold(
                  appBar: AppBar(
                    title: const Text('test'),
                    backgroundColor: const Color.fromARGB(255, 185, 47, 5),
                  ),
                  body: Column(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        onChanged: (value) {
                          filterSearch(value, snapshot.data!);
                        },
                        controller: editingController,
                      ),
                    ),
                    Expanded(
                        child: ListView.builder(
                      itemCount: iconList.length,
                      itemBuilder: (context, index) => ListTile(
                          leading: CircleAvatar(
                            backgroundImage: AssetImage(iconList[index]),
                            backgroundColor: Colors.white,
                          ),
                          title: Text(iconNames[index]),
                          onTap: (() => VoidCallback)),
                    ))
                  ]));
            }
          }
        });
  }

/*   Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: icons.length,
      itemBuilder: (context, index) => ListTile(
        leading: Image(image: AssetImage(icons[index])),
        title: const Text('title'),
      ),
    );
  } */
}
