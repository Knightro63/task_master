import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom TextFormField widget
class EnterTextFormField extends StatelessWidget {
  const EnterTextFormField(
      {Key? key,
      this.maxLines,
      this.minLines,
      this.label,
      required this.controller,
      this.focusNode,
      this.onTap,
      this.onChanged,
      this.onEditingComplete,
      this.onSubmitted,
      this.width,
      this.height,
      this.color,
      this.textStyle,
      this.margin = const EdgeInsets.fromLTRB(10, 0, 10, 0),
      this.readOnly = false,
      this.keyboardType = TextInputType.multiline,
      this.padding = const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
      this.inputFormatters,
      this.radius = 10.0})
      : super(key: key);

  final int? minLines;
  final int? maxLines;
  final String? label;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final Function()? onTap;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final Function()? onEditingComplete;
  final double? width;
  final double? height;
  final Color? color;
  final bool readOnly;
  final EdgeInsets margin;
  final TextInputType keyboardType;
  final TextStyle? textStyle;
  final EdgeInsets? padding;
  final List<TextInputFormatter>? inputFormatters;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: margin,
        width: width,
        height: height,
        alignment: Alignment.center,
        child: TextField(
          //textAlign: TextAlign.,
          readOnly: readOnly,
          keyboardType: keyboardType,
          minLines: minLines,
          maxLines: maxLines,
          autofocus: false,
          focusNode: focusNode,
          //textAlignVertical: TextAlignVertical.center,
          onTap: onTap,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          onEditingComplete: onEditingComplete,
          inputFormatters: inputFormatters,
          controller: controller,
          style: (textStyle == null)
              ? Theme.of(context).primaryTextTheme.bodyMedium
              : textStyle,
          decoration: InputDecoration(
              isDense: true,
              //labelText: label,
              filled: true,
              fillColor:
                  (color == null) ? Theme.of(context).splashColor : color,
              contentPadding: padding,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(radius),
                ),
                borderSide: const BorderSide(
                  width: 0,
                  style: BorderStyle.none,
                ),
              ),
              hintText: label),
        ));
  }
}
