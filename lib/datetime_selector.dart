import 'package:flutter/material.dart';
import 'package:date_time_picker/date_time_picker.dart';

class DateTimeSelector extends StatelessWidget {
  final DateTime initialDate;
  final void Function(String) onDateChanged;

  const DateTimeSelector({
    Key? key,
    required this.initialDate,
    required this.onDateChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DateTimePicker(
      type: DateTimePickerType.dateTimeSeparate,
      dateMask: 'd MMM, yyyy',
      initialValue: initialDate.toIso8601String(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      icon: const Icon(Icons.event),
      dateLabelText: 'Data',
      timeLabelText: 'Ora',
      onChanged: onDateChanged,
    );
  }
}
