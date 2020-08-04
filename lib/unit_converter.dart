import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'category.dart';
import 'api.dart';
import 'unit.dart';

const _padding = EdgeInsets.all(16.0);

/// [UnitConverter] where users can input amounts to convert in one [Unit]
/// and retrieve the conversion in another [Unit] for a specific [Category].
///
/// While it is named ConverterRoute, a more apt name would be ConverterScreen,
/// because it is responsible for the UI at the route's destination.
class UnitConverter extends StatefulWidget {
  /// Color for this [Category].
  final Category category;

  /// Units for this [Category].

  /// This [UnitConverter] requires the color and units to not be null.
  const UnitConverter({
    @required this.category,
  }) : assert(category != null);

  @override
  _UnitConverterState createState() => _UnitConverterState();
}

class _UnitConverterState extends State<UnitConverter> {
  // ignore: todo
  // TODO: Set some variables, such as for keeping track of the user's input
  // value and units
  Unit _fromValue;
  Unit _toValue;
  double _inputValue;
  double _outputValue;
  String _convertedValue = "";
  bool _showErrorMessage = false;
  List<DropdownMenuItem> _unitMenuItems;
  final _inputKey = GlobalKey(debugLabel: 'inputText');
  final _outputKey = GlobalKey(debugLabel: 'outputText');
  final _updateOutputText = TextEditingController();
  final _updateInputText = TextEditingController();

  // ignore: todo
  // TODO: Determine whether you need to override anything, such as initState()
  @override
  void initState() {
    super.initState();
    _createDropDownItems();
    _setDefaults();
  }

  @override
  void didUpdateWidget(UnitConverter old) {
    super.didUpdateWidget(old);
    // We update our [DropdownMenuItem] units when we switch [Categories].
    if (old.category != widget.category) {
      _createDropDownItems();
      _setDefaults();
    }
  }

  // ignore: todo
  // TODO: Add other helper functions. We've given you one, _format()
  void _createDropDownItems() {
    var newItems = <DropdownMenuItem>[];
    for (var unit in widget.category.units) {
      newItems.add(DropdownMenuItem(
        value: unit.name,
        child: Container(
          child: Text(
            unit.name,
            softWrap: true,
          ),
        ),
      ));
    }
    setState(() {
      _unitMenuItems = newItems;
    });
  }

  Widget _createDropdown(String currentValue, ValueChanged<dynamic> onChanged) {
    return Container(
        margin: EdgeInsets.only(top: 16.0),
        padding: EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          // This sets the color of the [DropdownButton] itself
          color: Colors.grey[50],
          border: Border.all(
            style: BorderStyle.solid,
            color: Colors.grey[400],
            width: 1.0,
          ),
        ),
        child: Theme(
          // This sets the color of the [DropdownMenuItem]
          data: Theme.of(context).copyWith(
            canvasColor: Colors.grey[50],
          ),
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton(
                value: currentValue,
                items: _unitMenuItems,
                onChanged: onChanged,
                onTap: (() =>
                    FocusScope.of(context).requestFocus(new FocusNode())),
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
          ),
        ));
  }

  void _setDefaults() {
    setState(() {
      _fromValue = widget.category.units[0];
      _toValue = widget.category.units[1];
      _inputValue = 0;
      _outputValue = 0;
      _updateInputText.text = "";
      _updateOutputText.text = "";
      _convertedValue = "";
      _showErrorMessage = false;
    });
  }

  void _updateFromConversion(dynamic unitName) {
    setState(() {
      FocusScope.of(context).requestFocus(new FocusNode());
      _fromValue = _getUnit(unitName);
    });
    if (_inputValue != null) {
      _updateConversion(1);
    }
  }

  void _updateToConversion(dynamic unitName) {
    setState(() {
      FocusScope.of(context).requestFocus(new FocusNode());
      _toValue = _getUnit(unitName);
    });
    if (_inputValue != null) {
      _updateConversion(0);
    }
  }

  Unit _getUnit(String unitName) {
    return widget.category.units.firstWhere(
      (Unit unit) {
        return unit.name == unitName;
      },
      orElse: null,
    );
  }

  Future<void> _updateConversion(int type) async {
    if (widget.category.name == currency['name']) {
      final api = API();
      if (type == 1) {
        final conversion = await api.getConversion(currency['route'],
            _inputValue.toString(), _fromValue.name, _toValue.name);
        if (conversion != null) {
          setState(() {
            _convertedValue = _format(conversion);
            _updateOutputText.text = _convertedValue;
          });
        }
      } else {
        final conversion = await api.getConversion(currency['route'],
            _outputValue.toString(), _toValue.name, _fromValue.name);
        if (conversion != null) {
          setState(() {
            _convertedValue = _format(conversion);
            _updateInputText.text = _convertedValue;
          });
        }
      }
    } else {
      if (type == 1) {
        setState(() {
          _convertedValue = _format(
              _inputValue * (_toValue.conversion / _fromValue.conversion));
          _updateOutputText.text = _convertedValue;
        });
      } else {
        setState(() {
          _convertedValue = _format(
              _outputValue * (_fromValue.conversion / _toValue.conversion));
          _updateInputText.text = _convertedValue;
        });
      }
    }
  }

  void _updateInputValue(String input) {
    setState(() {
      if (input == null || input.isEmpty) {
        _convertedValue = "";
      } else {
        try {
          final inputDouble = double.parse(input);
          _inputValue = inputDouble;
          _updateConversion(1);
          _showErrorMessage = false;
        } on Exception catch (e) {
          print("Error: $e");
          _showErrorMessage = true;
        }
      }
    });
  }

  void _updateOutputValue(String input) {
    setState(() {
      if (input == null || input.isEmpty) {
        _convertedValue = "";
      } else {
        try {
          final outputDouble = double.parse(input);
          _outputValue = outputDouble;
          _updateConversion(0);
          _showErrorMessage = false;
        } on Exception catch (e) {
          print("Error: $e");
          _showErrorMessage = true;
        }
      }
    });
  }

  /// Clean up conversion; trim trailing zeros, e.g. 5.500 -> 5.5, 10.0 -> 10
  String _format(double conversion) {
    var outputNum = conversion.toStringAsPrecision(7);
    if (outputNum.contains('.') && outputNum.endsWith('0')) {
      var i = outputNum.length - 1;
      while (outputNum[i] == '0') {
        i -= 1;
      }
      outputNum = outputNum.substring(0, i + 1);
    }
    if (outputNum.endsWith('.')) {
      return outputNum.substring(0, outputNum.length - 1);
    }
    return outputNum;
  }

  @override
  Widget build(BuildContext context) {
    // ignore: todo
    // TODO: Create the 'input' group of widgets. This is a Column that
    // includes the input value, and 'from' unit [Dropdown].
    final input = Padding(
      padding: _padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            controller: _updateInputText,
            style: Theme.of(context).textTheme.headline4,
            key: _inputKey,
            decoration: InputDecoration(
                labelText: "Input",
                labelStyle: Theme.of(context).textTheme.headline4,
                errorText: _showErrorMessage ? "Invalid Number Entered" : null,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.5))),
            keyboardType: TextInputType.number,
            onChanged: _updateInputValue,
          ),
          _createDropdown(_fromValue.name, _updateFromConversion)
        ],
      ),
    );
    // ignore: todo
    // TODO: Create a compare arrows icon.

    // ignore: todo
    // TODO: Create the 'output' group of widgets. This is a Column that
    final output = Padding(
      padding: _padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            controller: _updateOutputText,
            style: Theme.of(context).textTheme.headline4,
            key: _outputKey,
            decoration: InputDecoration(
                labelStyle: Theme.of(context).textTheme.headline4,
                labelText: "Output",
                errorText: _showErrorMessage ? "Invalid Number Entered" : null,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0))),
            keyboardType: TextInputType.number,
            onChanged: _updateOutputValue,
          ),
          _createDropdown(_toValue.name, _updateToConversion)
        ],
      ),
    );
    // includes the output value, and 'to' unit [Dropdown].

    // ignore: todo
    // TODO: Return the input, arrows, and output widgets, wrapped in a Column.
    final arrow = RotatedBox(
      quarterTurns: 1,
      child: Icon(
        Icons.compare_arrows,
        size: 40.0,
      ),
    );

    // ignore: todo
    // TODO: Delete the below placeholder code.
    final converter = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[input, arrow, output],
    );

    return Padding(
      padding: _padding,
      child: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          if (orientation == Orientation.portrait) {
            return SingleChildScrollView(
              child: converter,
            );
          } else {
            return SingleChildScrollView(
              child: Center(
                child: Container(
                  child: converter,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
