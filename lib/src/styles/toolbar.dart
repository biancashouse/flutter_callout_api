import 'package:flutter/material.dart';

import 'option_button.dart';
import 'styles_picker.dart';

class Toolbar extends StatefulWidget {
  final StylesPickerState parentState;
  final EditorToolbarAction initialTool;
  final Function(EditorToolbarAction) onToolSelect;

  const Toolbar(
    this.parentState, {super.key,
    this.initialTool = EditorToolbarAction.arrowTypeTool,
    required this.onToolSelect,
  });

  @override
  _ToolbarState createState() => _ToolbarState();
}

class _ToolbarState extends State<Toolbar> {
  late EditorToolbarAction _selectedAction;

  @override
  void initState() {
    _selectedAction = widget.initialTool;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        OptionButton(
          isActive: _selectedAction == EditorToolbarAction.arrowTypeTool,
          child: const Icon(Icons.messenger, color: Colors.white,),
          onPressed: () {
            setState(() => _selectedAction = EditorToolbarAction.arrowTypeTool);
            widget.onToolSelect(EditorToolbarAction.arrowTypeTool);
          },
        ),
        OptionButton(
          isActive: _selectedAction == EditorToolbarAction.fontFamilyTool,
          child: const Icon(Icons.title, color: Colors.white,),
          onPressed: () {
            setState(() => _selectedAction = EditorToolbarAction.fontFamilyTool);
            widget.onToolSelect(EditorToolbarAction.fontFamilyTool);
          },
        ),
        OptionButton(
          isActive: _selectedAction == EditorToolbarAction.fontOptionTool,
          child: const Icon(Icons.strikethrough_s, color: Colors.white,),
          onPressed: () {
            setState(() => _selectedAction = EditorToolbarAction.fontOptionTool);
            widget.onToolSelect(EditorToolbarAction.fontOptionTool);
          },
        ),
        OptionButton(
          isActive: _selectedAction == EditorToolbarAction.fontSizeTool,
          child: const Icon(Icons.format_size, color: Colors.white,),
          onPressed: () {
            setState(() => _selectedAction = EditorToolbarAction.fontSizeTool);
            widget.onToolSelect(EditorToolbarAction.fontSizeTool);
          },
        ),
        OptionButton(
          isActive: _selectedAction == EditorToolbarAction.fontColorTool,
          child: const Icon(Icons.format_color_text, color: Colors.white,),
          onPressed: () {
            setState(() => _selectedAction = EditorToolbarAction.fontColorTool);
            widget.onToolSelect(EditorToolbarAction.fontColorTool);
          },
        ),
        OptionButton(
          isActive: _selectedAction == EditorToolbarAction.backgroundColorTool,
          child: const Icon(Icons.format_color_fill, color: Colors.white,),
          onPressed: () {
            setState(() => _selectedAction = EditorToolbarAction.backgroundColorTool);
            widget.onToolSelect(EditorToolbarAction.backgroundColorTool);
          },
        ),
      ],
    );
  }
}
