import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'api.dart';
import 'backdrop.dart';
import 'category.dart';
import 'category_tile.dart';
import 'unit.dart';
import 'unit_converter.dart';

/// Category Route (screen).
///
/// This is the 'home' screen of the Unit Converter. It shows a header and
/// a list of [Categories].
///
/// While it is named CategoryRoute, a more apt name would be CategoryScreen,
/// because it is responsible for the UI at the route's destination.
class CategoryRoute extends StatefulWidget {
  const CategoryRoute();

  @override
  _CategoryRouteState createState() => _CategoryRouteState();
}

class _CategoryRouteState extends State<CategoryRoute> {
  // TODO: Keep track of a default [Category], and the currently-selected
  Category _defaultCategory;
  Category _currentCategory;
  final _categories = <Category>[];

  static const _baseColors = <ColorSwatch>[
    ColorSwatch(0xFF6AB7A8, {
      'highlight': Color(0xFF6AB7A8),
      'splash': Color(0xFF0ABC9B),
    }),
    ColorSwatch(0xFFFFD28E, {
      'highlight': Color(0xFFFFD28E),
      'splash': Color(0xFFFFA41C),
    }),
    ColorSwatch(0xFFFFB7DE, {
      'highlight': Color(0xFFFFB7DE),
      'splash': Color(0xFFF94CBF),
    }),
    ColorSwatch(0xFF8899A8, {
      'highlight': Color(0xFF8899A8),
      'splash': Color(0xFFA9CAE8),
    }),
    ColorSwatch(0xFFEAD37E, {
      'highlight': Color(0xFFEAD37E),
      'splash': Color(0xFFFFE070),
    }),
    ColorSwatch(0xFF81A56F, {
      'highlight': Color(0xFF81A56F),
      'splash': Color(0xFF7CC159),
    }),
    ColorSwatch(0xFFD7C0E2, {
      'highlight': Color(0xFFD7C0E2),
      'splash': Color(0xFFCA90E5),
    }),
    ColorSwatch(0xFFCE9A9A, {
      'highlight': Color(0xFFCE9A9A),
      'splash': Color(0xFFF94D56),
      'error': Color(0xFF912D2D),
    }),
  ];
  static const _icons = <String>[
    'assets/icons/length.png',
    'assets/icons/area.png',
    'assets/icons/volume.png',
    'assets/icons/mass.png',
    'assets/icons/time.png',
    'assets/icons/digital_storage.png',
    'assets/icons/power.png',
    'assets/icons/currency.png',
  ];
  // @override
  // void initState() {
  //   super.initState();
  //   for (var i = 0; i < _categoryNames.length; i++) {
  //     _categories.add(Category(
  //       name: _categoryNames[i],
  //       color: _baseColors[i],
  //       iconLocation: Icons.cake,
  //       units: _retrieveUnitList(_categoryNames[i]),
  //     ));
  //   }
  //   setState(() {
  //     _defaultCategory = _categories[0];
  //   });
  // }
  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    if (_categories.isEmpty) {
      await _retrieveLocalCategories();
      await _retriveApiCategories();
    }
  }

  Future<void> _retrieveLocalCategories() async {
    final json = DefaultAssetBundle.of(context)
        .loadString('assets/data/regular_units.json');
    final data = JsonDecoder().convert(await json);
    if (data is! Map) {
      throw ("Data Retrived from local API is not Map");
    }
    var _categoryIndex = 0;
    data.keys.forEach((key) {
      final List<Unit> units =
          data[key].map<Unit>((dynamic data) => Unit.fromJson(data)).toList();

      var category = Category(
          name: key,
          color: _baseColors[_categoryIndex],
          iconLocation: _icons[_categoryIndex],
          units: units);
      setState(() {
        if (_categoryIndex == 0) {
          _defaultCategory = category;
        }
        _categories.add(category);
      });
      _categoryIndex += 1;
    });
  }

  Future<void> _retriveApiCategories() async {
    setState(() {
      _categories.add(Category(
        name: currency['name'],
        units: [],
        color: _baseColors.last,
        iconLocation: _icons.last,
      ));
    });
    final api = API();
    final response = await api.getUnits(currency['route']);
    if (response != null) {
      final List<Unit> units =
          response.map((dynamic data) => Unit.fromJson(data)).toList();
      setState(() {
        _categories.removeLast();
        _categories.add(Category(
            name: currency['name'],
            color: _baseColors.last,
            iconLocation: _icons.last,
            units: units));
      });
    }
  }

  // ignore: todo
  // TODO: Fill out this function
  void _onCategoryTap(Category category) {
    setState(() {
      // FocusScope.of(context).requestFocus(new FocusNode());
      _currentCategory = category;
    });
  }

  /// Makes the correct number of rows for the list view.
  ///
  /// For portrait, we use a [ListView].
  /// TODO: Use a GridView for landscape mode, passing in the device orientation
  /// Makes the correct number of rows for the list view, based on whether the
  /// device is portrait or landscape.
  ///
  /// For portrait, we use a [ListView]. For landscape, we use a [GridView].
  Widget _buildCategoryWidgets(Orientation orientation) {
    if (orientation == Orientation.portrait) {
      return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return CategoryTile(
            category: _categories[index],
            onTap: _onCategoryTap,
          );
        },
        itemCount: _categories.length,
      );
    } else {
      return GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 3.0,
        children: _categories.map((Category category) {
          return CategoryTile(
            category: category,
            onTap: _onCategoryTap,
          );
        }).toList(),
      );
    }
  }

  // /// Returns a list of mock [Unit]s.
  // List<Unit> _retrieveUnitList(String categoryName) {
  //   return List.generate(10, (int i) {
  //     i += 1;
  //     return Unit(
  //       name: '$categoryName Unit $i',
  //       conversion: i.toDouble(),
  //     );
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // TODO: Import and use the Backdrop widget
    if (_categories.isEmpty) {
      return Center(
        child: Container(
          height: 180.0,
          width: 180.0,
          child: CircularProgressIndicator(),
        ),
      );
    }
    final listView = Padding(
      padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 48.0),
      child: _buildCategoryWidgets(MediaQuery.of(context).orientation),
    );

    return Backdrop(
      backTitle: Text("Select Category"),
      frontTitle: Text("Unit Converter"),
      currentCategory:
          _currentCategory == null ? _defaultCategory : _currentCategory,
      frontPanel: _currentCategory == null
          ? UnitConverter(category: _defaultCategory)
          : UnitConverter(category: _currentCategory),
      backPanel: listView,
    );
  }
}
