import 'package:flutter/material.dart';
import 'package:numeric_keyboard/numeric_keyboard.dart';

typedef TextChangedF = void Function({String? s});

class NumericKeypad extends StatefulWidget {
  final String label;
  final String initialValue;
  final Function(String s) onClosedF;

  const NumericKeypad({
    required this.label,
    this.initialValue = "0",
    required this.onClosedF,
  });

  @override
  _NumericKeyboardState createState() => _NumericKeyboardState();
}

class _NumericKeyboardState extends State<NumericKeypad> {
  late String text;


  @override
  void initState() {
    super.initState();
    text = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.purpleAccent,
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(widget.label, style: TextStyle(color:Colors.white60, fontSize: 24),),
          Spacer(),
          Text(text, style: TextStyle(color:Colors.white, fontSize: 48, fontWeight: FontWeight.bold),),
          NumericKeyboard(
            onKeyboardTap: _onKeyboardTap,
            textColor: Colors.white,
            rightButtonFn: () {
              setState(() {
                text = text.substring(0, text.length - 1);
              });
            },
            rightIcon: Icon(
              Icons.backspace,
              color: Colors.white,
            ),
            leftButtonFn: () {
              widget.onClosedF.call(text);
            },
            leftIcon: Icon(
              Icons.check,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  _onKeyboardTap(String value) {
    setState(() {
      text = text + value;
    });
  }
}
