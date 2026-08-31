
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../common/colo_extension.dart';

class RoundTextField extends StatelessWidget {
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String hitText;
  final String icon;
  final Widget? rigtIcon;
  final bool obscureText;
  final EdgeInsets? margin;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputAction? textInputAction;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  const RoundTextField(
      {super.key,
      required this.hitText,
      required this.icon,
      this.controller,
      this.margin,
      this.keyboardType,
      this.obscureText = false,
      this.rigtIcon,
      this.validator,
      this.readOnly = false,
      this.onTap,
      this.textInputAction,
      this.onChanged,
      this.inputFormatters});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
          color: TColor.lightGray, borderRadius: BorderRadius.circular(15)),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        readOnly: readOnly,
        onTap: onTap,
        textInputAction: textInputAction,
        onChanged: onChanged,
        inputFormatters: inputFormatters,
        style: TextStyle(color: TColor.black, fontSize: 14),
        decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            hintText: hitText,
            suffixIcon: rigtIcon,
            prefixIcon: Container(
                alignment: Alignment.center,
                width: 20,
                height: 20,
                child: Image.asset(
                 icon,
                  width: 20,
                  height: 20,
                  fit: BoxFit.contain,
                  color: TColor.gray,
                )),
            hintStyle: TextStyle(color: TColor.gray, fontSize: 12)),
      ),
    );
  }
}
