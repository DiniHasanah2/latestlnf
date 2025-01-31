import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting the selected date

class DatePickerTextFieldWidget extends StatefulWidget {
  final String hintText;

  const DatePickerTextFieldWidget({
    super.key,
    required this.hintText, required TextEditingController dobController,
  });

  @override
  // ignore: library_private_types_in_public_api
  _DatePickerTextFieldWidgetState createState() =>
      _DatePickerTextFieldWidgetState();
}

class _DatePickerTextFieldWidgetState extends State<DatePickerTextFieldWidget> {
  DateTime? selectedDate; // The selected date

  TextEditingController dobController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dobController.text = DateFormat('dd-MM-yyyy').format(selectedDate!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: TextField(
            controller: dobController,
            onTap: () => _selectDate(context),
            decoration: InputDecoration(
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color:  Color.fromARGB(255, 255, 219, 189),
                  width: 1.5,
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color.fromARGB(255, 97, 97, 93)),
              ),
              fillColor:  const Color.fromARGB(255, 255, 219, 189),
              filled: true,
              hintText: 'Date of Birth',
              hintStyle: const TextStyle(
                color: Colors.white,
              ),
              suffixIcon: IconButton(
                onPressed: () => _selectDate(context),
                icon: const Icon(Icons.calendar_today),
              ),
            )));
  }
  /*@override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: dobController,
      onTap: () => _selectDate(context),
      decoration: InputDecoration(
        labelText: 'Date',
        suffixIcon: IconButton(
          onPressed: () => _selectDate(context),
          icon: Icon(Icons.calendar_today),
        ),
      ),
    );
  }*/
}