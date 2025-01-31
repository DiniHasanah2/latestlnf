import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ViewItemScreen extends StatefulWidget {
  final DocumentSnapshot item;

  const ViewItemScreen({Key? key, required this.item}) : super(key: key);

  @override
  _ViewItemScreenState createState() => _ViewItemScreenState();
}

class _ViewItemScreenState extends State<ViewItemScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _categoryController;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _typeController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late List<String> _imageURLs;
  GoogleMapController? mapController;
  LatLng? itemLocation;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.item['username']);
    _phoneNumberController = TextEditingController(text: widget.item['phoneNumber']);
    _categoryController = TextEditingController(text: widget.item['category']);
    _titleController = TextEditingController(text: widget.item['title']);
    _descriptionController = TextEditingController(text: widget.item['description']);
    _typeController = TextEditingController(text: widget.item['type']);
    _selectedDate = (widget.item['date'] as Timestamp).toDate();
    final timeParts = (widget.item['time'] as String).split(':');
    _selectedTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
    _imageURLs = List<String>.from(widget.item['imageURLs']);
    _setItemLocation();
  }

  Future<void> _setItemLocation() async {
    String address = widget.item['address'];
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        Location firstLocation = locations.first;
        setState(() {
          itemLocation = LatLng(firstLocation.latitude, firstLocation.longitude);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog("Error finding location: $e");
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color here
      appBar: AppBar(
        title: const Text('Item Details'),
        backgroundColor: const Color.fromARGB(255, 250, 182, 114),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              if (_imageURLs.isNotEmpty)
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  alignment: WrapAlignment.center,
                  children: _imageURLs.map((url) {
                    return Image.network(url, width: 200, height: 200);
                  }).toList(),
                ),
              const SizedBox(height: 20),
              _buildDetailText(_titleController.text, 'Title'),
              const SizedBox(height: 20),
              _buildDetailText(_usernameController.text, 'Username'),
              const SizedBox(height: 20),
              _buildDetailText(_phoneNumberController.text, 'Phone Number'),
              const SizedBox(height: 20),
              _buildDetailText(_categoryController.text, 'Category'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDetailText('${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}', 'Date'),
                  const SizedBox(width: 20),
                  _buildDetailText('${_selectedTime.hour}:${_selectedTime.minute}', 'Time'),
                ],
              ),
              const SizedBox(height: 20),
              _buildDetailText(_descriptionController.text, 'Description'),
              const SizedBox(height: 20),
              _buildDetailText(_typeController.text, 'Type'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Address: ',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    widget.item['address'] as String,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (!isLoading && itemLocation != null)
                SizedBox(
                  height: 200,
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: itemLocation!,
                      zoom: 12,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('item_location'),
                        position: itemLocation!,
                      ),
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailText(String value, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 16),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneNumberController.dispose();
    _categoryController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _typeController.dispose();
    super.dispose();
  }
}


