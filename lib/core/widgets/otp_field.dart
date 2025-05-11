import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_starter_package/core/theme/app_colors.dart';

class OtpField extends StatefulWidget {
  final int length;
  final Function(String) onCompleted;
  final bool autofocus;

  const OtpField({
    Key? key,
    this.length = 6,
    required this.onCompleted,
    this.autofocus = false,
  }) : super(key: key);

  @override
  State<OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<OtpField> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late List<String> _values;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (index) => TextEditingController());
    _focusNodes = List.generate(widget.length, (index) => FocusNode());
    _values = List.generate(widget.length, (index) => '');

    // Auto-focus on the first field if autofocus is true
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_focusNodes[0]);
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      _values[index] = value;
      
      // Move to next field if not the last one
      if (index < widget.length - 1) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else {
        // Check if all fields are filled
        if (_values.every((element) => element.isNotEmpty)) {
          widget.onCompleted(_values.join());
        }
      }
    }
  }

  void _onKeyPressed(RawKeyEvent event, int index) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace && 
          _controllers[index].text.isEmpty && 
          index > 0) {
        // Move to previous field on backspace if current field is empty
        FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        widget.length,
        (index) => SizedBox(
          width: 50,
          height: 60,
          child: RawKeyboardListener(
            focusNode: FocusNode(),
            onKey: (event) => _onKeyPressed(event, index),
            child: TextFormField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
              maxLength: 1,
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.mutedLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.mutedLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: (value) => _onChanged(value, index),
            ),
          ),
        ),
      ),
    );
  }
} 