import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../global.dart';

class CustomBoxTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final InputDecoration decoration;
  final TextInputType? keyboardType;
  final String? hintText;
  final double? hintFontSize;
  final Color? hintColor;
  final double? horizontalPadding;
  final String? errorText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool? obscureText;
  final bool? readOnly;
  final bool? filled;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final Color? borderColor;
  final bool isBorder;
  final Color? fillColor;
  final Color? focusedBorderColor;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String> validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final BorderRadius? borderRadius;
  final double? padding;
  final EdgeInsetsGeometry? suffixPadding;
  final EdgeInsetsGeometry? contentPadding;
  final TextAlign? textAlign;
  final TextStyle? textStyle;
  final TextDirection? textDirection;

  const CustomBoxTextFormField(
      {super.key,
      required this.controller,
      this.keyboardType,
        required this.decoration,
      this.hintText,
      this.hintColor,
      this.focusNode,
      this.contentPadding,
      this.errorText,
      this.textStyle,
      this.textDirection,
      this.fillColor,
      this.textAlign,
      this.padding,
      this.focusedBorderColor,
      this.suffixPadding,
      this.filled,
      this.minLines,
      this.hintFontSize,
      this.borderColor,
      this.borderRadius,
      this.maxLines,
      this.suffixIcon,
      this.obscureText,
      this.maxLength,
      this.horizontalPadding,
      this.onChanged,
      this.readOnly,
      this.isBorder = true,
      this.inputFormatters,
      required this.validator,
      this.textInputAction,
      this.prefixIcon,
      this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textDirection: textDirection ?? TextDirection.ltr,
      focusNode: focusNode,
      textAlignVertical: TextAlignVertical.top,
      readOnly: readOnly ?? false,
      keyboardType: keyboardType,
      controller: controller,
      textAlign: textAlign ?? TextAlign.start,
      obscureText: obscureText ?? false,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      minLines: minLines ?? 1,
      validator: validator,
      maxLines: maxLines ?? 1,
      onChanged: onChanged ?? (text) {},
      onFieldSubmitted: onSubmitted ??
          (term) {
            FocusScope.of(context).nextFocus();
          },
      style: textStyle ??
          TextStyle(
            fontSize: 14,
            color: Colors.white,
            //fontFamily: AppConstants.fontFamily,
            fontWeight: FontWeight.w500,
          ),
      textInputAction: textInputAction ?? TextInputAction.next,
      decoration: InputDecoration(
          isDense: true,
          contentPadding: contentPadding ??
              EdgeInsets.symmetric(
                  horizontal: padding ?? 10, vertical: padding ?? 12),
          border: isBorder
              ? OutlineInputBorder(
                  borderSide: BorderSide(
                    color: borderColor ?? AppColors.textFieldBorderColor,
                  ),
                  borderRadius: borderRadius ?? BorderRadius.circular(4))
              : InputBorder.none,
          enabledBorder: isBorder
              ? OutlineInputBorder(
                  borderSide: BorderSide(
                    color: borderColor ?? AppColors.textFieldBorderColor,
                  ),
                  borderRadius: borderRadius ?? BorderRadius.circular(4))
              : InputBorder.none,
          focusedBorder: isBorder
              ? OutlineInputBorder(
                  borderSide: BorderSide(
                      color: focusedBorderColor ?? AppColors.primaryColor),
                  borderRadius: borderRadius ?? BorderRadius.circular(4))
              : InputBorder.none,
          filled: filled ?? true,
          fillColor: fillColor ?? AppColors.textFieldFillBorderColor,
          errorMaxLines: 2,
          hintText: hintText,
          hintStyle: TextStyle(
            color: hintColor ?? Colors.grey,
            fontSize: hintFontSize ?? 14,
            //  fontFamily: AppConstants.fontFamily,
            fontWeight: FontWeight.w400,
          ),
          labelStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
          prefixIconConstraints: BoxConstraints.loose(const Size.square(36)),
          suffixIconConstraints: BoxConstraints.loose(const Size.square(36)),
          suffixIcon: Padding(
              padding: suffixPadding ??
                  EdgeInsets.symmetric(horizontal: horizontalPadding ?? 10),
              child: suffixIcon),
          prefixIcon: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: horizontalPadding ?? 10),
              child: prefixIcon)),
    );
  }
}
