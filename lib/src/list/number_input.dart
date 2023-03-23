import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberInput extends StatelessWidget {
  const NumberInput({super.key,
    required this.label,
    this.controller,
    required this.focusNode,
    this.value,
    required this.onChanged,
    required this.onClosed,
    this.error,
    this.icon,
    this.allowDecimal = false,
  });

  final TextEditingController? controller;
  final FocusNode focusNode;
  final String? value;
  final String label;
  final Function onChanged;
  final Function onClosed;
  final String? error;
  final Widget? icon;
  final bool allowDecimal;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode..requestFocus(),
      autofocus: true,
      controller: controller,
      initialValue: value,
      onChanged: onChanged as void Function(String)?,
      readOnly: false,
      keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(_getRegexString())),
        TextInputFormatter.withFunction(
          (oldValue, newValue) => newValue.copyWith(
            text: newValue.text.replaceAll('.', ','),
          ),
        ),
      ],
      decoration: InputDecoration(
        label: Text(label),
        errorText: error,
        icon: icon,
        suffixIcon: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => onClosed.call(),
        ),
        contentPadding: const EdgeInsets.all(6),
      ),
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 32,
        color: Colors.blueAccent,
      ),
    );
  }

  String _getRegexString() => allowDecimal ? r'[0-9]+[,.]{0,1}[0-9]*' : r'[0-9]';
}
