import 'package:calendar_scheduler/const/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String label;

  final bool isTime;
  final FormFieldSetter<String> onSaved;

  final String initialValue;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.isTime,
    required this.onSaved,
    required this.initialValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: PRIMARY_COLOR,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (isTime) renderTextField(),
        if (!isTime) Expanded(child: renderTextField()),
      ],
    );
  }

  Widget renderTextField() {
    return TextFormField(
      onSaved: onSaved,
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return '값을 입력해주세요.';
        }

        if (isTime) {
          int time = int.parse(value);

          if (time < 0) {
            return '0 이상의 숫자를 입력해주세요.';
          }

          if (time > 24) {
            return '24 이하의 숫자를 입력해주세요.';
          }
        } else {
          if (value.length > 500) {
            return '500자 이하의 글자를 입력해주세요.';
          }
        }

        return null;
      },
      cursorColor: Colors.grey,
      maxLines: isTime ? 1 : null,
      expands: !isTime,
      initialValue: initialValue,
      // maxLength: 500,
      keyboardType: isTime ? TextInputType.number : TextInputType.multiline,
      inputFormatters: isTime ? [FilteringTextInputFormatter.digitsOnly] : [],
      decoration: InputDecoration(
        border: InputBorder.none,
        filled: true,
        fillColor: Colors.grey[300],
        suffixText: isTime ? '시' : null,
      ),
    );
  }
}
