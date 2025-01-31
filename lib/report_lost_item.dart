import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latestlnf/service/user_provider.dart';
import 'package:latestlnf/utils/pick_adress_screen.dart';
import 'package:provider/provider.dart';

class ReportLostItemPage extends StatefulWidget {
  const ReportLostItemPage({super.key, required this.onTap});

  final Function() onTap;

  @override
  _ReportLostItemPageState createState() => _ReportLostItemPageState();

  Object? toMap() {}

  static fromMap(Map<String, dynamic> data) {}
}

class _ReportLostItemPageState extends State<ReportLostItemPage> {
  final List<File> _imageFiles = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _titleController;
  late TextEditingController _usernameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _addressController;
  String _selectedCategory = 'Wallet';
  String _selectedType = 'Lost';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  User? _currentUser;
  String _pickedAddress = '';
  LatLng? _pickedLocation;
  bool _isLoading = false; // Add this line

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _titleController = TextEditingController();
    _usernameController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _addressController = TextEditingController();
    _currentUser = FirebaseAuth.instance.currentUser;

    if (_currentUser != null) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      _usernameController.text = userProvider.username ?? ''; // Auto-populate username
      _phoneNumberController.text = userProvider.phoneNumber ?? ''; // Auto-populate phone number
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _titleController.dispose();
    _usernameController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null && pickedFiles.length + _imageFiles.length <= 5) {
      setState(() {
        _imageFiles.addAll(pickedFiles.map((pickedFile) => File(pickedFile.path)));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can upload up to 5 images.')),
      );
    }
  }

  Future<void> _captureImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      if (_imageFiles.length < 5) {
        setState(() {
          _imageFiles.add(File(pickedFile.path));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You can upload up to 5 images.')),
        );
      }
    }
  }

  Future<List<String>> _uploadImagesToStorage(List<File> imageFiles) async {
    List<String> downloadURLs = [];
    for (var imageFile in imageFiles) {
      try {
        final Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('lost_items_images/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}');
        final TaskSnapshot uploadTask = await storageRef.putFile(imageFile);
        final String downloadURL = await uploadTask.ref.getDownloadURL();
        downloadURLs.add(downloadURL);
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
    return downloadURLs;
  }

  Future<void> _submitReport(BuildContext context) async {
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      setState(() {
        _isLoading = true; // Set loading to true
      });

      List<String> imageURLs = await _uploadImagesToStorage(_imageFiles);

      if (imageURLs.isEmpty) {
        _showErrorDialog('Image upload failed. Please try again.');
        setState(() {
          _isLoading = false; // Set loading to false if there's an error
        });
        return;
      }

      try {
        DocumentReference reportRef = await FirebaseFirestore.instance.collection('lost_items').add({
          'username': _usernameController.text,
          'phoneNumber': _phoneNumberController.text,
          'category': _selectedCategory,
          'title': _titleController.text,
          'description': _descriptionController.text,
          'type': _selectedType,
          'date': Timestamp.fromDate(_selectedDate),
          'time': '${_selectedTime.hour}:${_selectedTime.minute}',
          'imageURLs': imageURLs,
          'location': _pickedLocation != null ? GeoPoint(_pickedLocation!.latitude, _pickedLocation!.longitude) : null,
          'address': _pickedAddress,
          'userId': _currentUser?.uid, // Add userId for easier reference
        });

        if (_currentUser != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_currentUser!.uid)
              .collection('user_posts')
              .doc(reportRef.id) // Use the same document ID
              .set({
            'username': _usernameController.text,
            'phoneNumber': _phoneNumberController.text,
            'category': _selectedCategory,
            'title': _titleController.text,
            'description': _descriptionController.text,
            'type': _selectedType,
            'date': Timestamp.fromDate(_selectedDate),
            'time': '${_selectedTime.hour}:${_selectedTime.minute}',
            'imageURLs': imageURLs,
            'location': _pickedLocation != null ? GeoPoint(_pickedLocation!.latitude, _pickedLocation!.longitude) : null,
            'address': _pickedAddress,
            'mainDocId': reportRef.id, // Reference to the main collection document
          });
        }

        _descriptionController.clear();
        _titleController.clear();
        setState(() {
          _selectedCategory = 'Wallet';
          _selectedType = 'Lost';
          _selectedDate = DateTime.now();
          _selectedTime = TimeOfDay.now();
          _imageFiles.clear();
          _pickedAddress = '';
          _pickedLocation = null;
          _isLoading = false; // Set loading to false after successful submission
        });

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('Your report has been submitted successfully'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } catch (error) {
        print('Error submitting report: $error');
        _showErrorDialog('An error occurred while submitting your report. Please try again.');
        setState(() {
          _isLoading = false; // Set loading to false if there's an error
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }
  }

  void _pickLocation() async {
    await _checkLocationPermission();

    final Map<String, dynamic>? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddressMapScreen()),
    );

    if (result != null) {
      setState(() {
        _pickedLocation = result['location'];
        _pickedAddress = result['address'];
        _addressController.text = _pickedAddress; // Update address field with picked address
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color here
      appBar: AppBar(
        title: const Text('Report Lost Item'),
        backgroundColor: const Color.fromARGB(255, 250, 182, 114),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Select Image'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              leading: const Icon(Icons.camera_alt),
                                              title: const Text('Capture Image'),
                                              onTap: () {
                                                Navigator.pop(context);
                                                _captureImage();
                                              },
                                            ),
                                            ListTile(
                                              leading: const Icon(Icons.image),
                                              title: const Text('Pick from Library'),
                                              onTap: () {
                                                Navigator.pop(context);
                                                _pickImage();
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Image.asset('assets/captureimage.png', width: 100, height: 100),
                              ),
                              const SizedBox(height: 20),
                              if (_imageFiles.isNotEmpty)
                                Wrap(
                                  spacing: 8.0,
                                  runSpacing: 8.0,
                                  children: _imageFiles.map((file) {
                                    return Stack(
                                      children: [
                                        Image.file(file, width: 100, height: 100),
                                        Positioned(
                                          right: 0,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _imageFiles.remove(file);
                                              });
                                            },
                                            child: const Icon(Icons.close, color: Colors.black),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            filled: true,
                            fillColor: Color.fromARGB(255, 249, 213, 187),
                            border: OutlineInputBorder(borderSide: BorderSide.none),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                          style: const TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            filled: true,
                            fillColor: Color.fromARGB(255, 249, 213, 187),
                            border: OutlineInputBorder(borderSide: BorderSide.none),
                          ),
                          readOnly: true,
                          style: const TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _phoneNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            filled: true,
                            fillColor: Color.fromARGB(255, 249, 213, 187),
                            border: OutlineInputBorder(borderSide: BorderSide.none),
                          ),
                          readOnly: true,
                          style: const TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color.fromARGB(255, 249, 213, 187)),
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: ListTile(
                                  title: const Text('Date'),
                                  subtitle: Text(
                                    '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}',
                                  ),
                                  onTap: () async {
                                    final DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: _selectedDate,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );
                                    if (pickedDate != null && pickedDate != _selectedDate) {
                                      setState(() {
                                        _selectedDate = pickedDate;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color.fromARGB(255, 249, 213, 187)),
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: ListTile(
                                  title: const Text('Time'),
                                  subtitle: Text(
                                    '${_selectedTime.hour}:${_selectedTime.minute}',
                                  ),
                                  onTap: () async {
                                    final TimeOfDay? pickedTime = await showTimePicker(
                                      context: context,
                                      initialTime: _selectedTime,
                                    );
                                    if (pickedTime != null && pickedTime != _selectedTime) {
                                      setState(() {
                                        _selectedTime = pickedTime;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          items: ['Wallet', 'Keys', 'Glasses', 'Smartphone', 'Umbrella', 'Others'].map((category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value!;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            filled: true,
                            fillColor: Color.fromARGB(255, 249, 213, 187),
                            border: OutlineInputBorder(borderSide: BorderSide.none),
                          ),
                          style: const TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            filled: true,
                            fillColor: Color.fromARGB(255, 249, 213, 187),
                            border: OutlineInputBorder(borderSide: BorderSide.none),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                          style: const TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          value: _selectedType,
                          items: ['Lost'].map((type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedType = value!;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Type',
                            filled: true,
                            fillColor: Color.fromARGB(255, 249, 213, 187),
                            border: OutlineInputBorder(borderSide: BorderSide.none),
                          ),
                          style: const TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 140,
                          child: ElevatedButton(
                            onPressed: _pickLocation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 250, 182, 114),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                            ),
                            child: const Text(
                              'Pick Location',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            labelText: 'Address',
                            filled: true,
                            fillColor: Color.fromARGB(255, 249, 213, 187),
                            border: OutlineInputBorder(borderSide: BorderSide.none),
                          ),
                          readOnly: true,
                          style: const TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _submitReport(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 250, 182, 114),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                            ),
                            child: const Text(
                              'Submit',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading) // Show CircularProgressIndicator when loading
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}