import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddressMapScreen extends StatefulWidget {
  const AddressMapScreen({super.key});

  @override
  _AddressMapScreenState createState() => _AddressMapScreenState();
}

class _AddressMapScreenState extends State<AddressMapScreen> {
  TextEditingController addressController = TextEditingController();
  GoogleMapController? mapController;
  LatLng? currentLocation;
  String savedAddress = '';

  void _searchAddressOnMap() async {
    String address = addressController.text;
    if (address.isNotEmpty) {
      try {
        List<Location> locations = await locationFromAddress(address);
        if (locations.isNotEmpty) {
          Location firstResult = locations.first;
          LatLng latLng = LatLng(firstResult.latitude, firstResult.longitude);
          mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
          setState(() {
            currentLocation = latLng;
          });
        } else {
          _showErrorDialog("No locations found for the provided address.");
        }
      } catch (e) {
        _showErrorDialog("Error finding location: $e");
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onMapSearch(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark firstResult = placemarks.first;
        String address =
            '${firstResult.street}, ${firstResult.locality}, ${firstResult.postalCode}, ${firstResult.country}';
        addressController.text = address;
        setState(() {
          currentLocation = position;
        });
      } else {
        _showErrorDialog("No address found for the selected location.");
      }
    } catch (e) {
      _showErrorDialog("Error retrieving address: $e");
    }
  }

  void _saveAddress() {
    String address = addressController.text;
    setState(() {
      savedAddress = address;
    });

    Navigator.pop(context, {'address': savedAddress, 'location': currentLocation});
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        backgroundColor: const Color.fromARGB(255, 250, 182, 114),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 400,
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: const CameraPosition(
                  target: LatLng(37.7749, -122.4194), // San Francisco as default location
                  zoom: 12,
                ),
                markers: (currentLocation != null)
                    ? {
                        Marker(
                          markerId: const MarkerId('current_location'),
                          position: currentLocation!,
                          onTap: () {
                            _onMapSearch(currentLocation!);
                          },
                        ),
                      }
                    : {},
                onTap: (position) {
                  _onMapSearch(position);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Enter Address',
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _searchAddressOnMap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 250, 182, 114),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    child: const Text('Search on Google Maps'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _saveAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 250, 182, 114),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    child: const Text('Save Address'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



/*import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddressMapScreen extends StatefulWidget {
  @override
  _AddressMapScreenState createState() => _AddressMapScreenState();
}

class _AddressMapScreenState extends State<AddressMapScreen> {
  TextEditingController addressController = TextEditingController();
  GoogleMapController? mapController;
  LatLng? currentLocation;
  String savedAddress = '';

  void _searchAddressOnMap() async {
    String address = addressController.text;
    if (address.isNotEmpty) {
      try {
        List<Location> locations = await locationFromAddress(address);
        if (locations.isNotEmpty) {
          Location firstResult = locations.first;
          LatLng latLng = LatLng(firstResult.latitude, firstResult.longitude);
          mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
          setState(() {
            currentLocation = latLng;
          });
        } else {
          // Handle case where no locations are found
          _showErrorDialog("No locations found for the provided address.");
        }
      } catch (e) {
        // Handle API errors or other exceptions
        _showErrorDialog("Error finding location: $e");
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onMapSearch(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark firstResult = placemarks.first;
        String address =
            '${firstResult.street}, ${firstResult.locality}, ${firstResult.postalCode}, ${firstResult.country}';
        addressController.text = address;
        setState(() {
          currentLocation = position;
        });
      } else {
        // Handle case where no placemarks are found
        _showErrorDialog("No address found for the selected location.");
      }
    } catch (e) {
      // Handle API errors or other exceptions
      _showErrorDialog("Error retrieving address: $e");
    }
  }

  void _saveAddress() {
    String address = addressController.text;
    setState(() {
      savedAddress = address;
    });

    Navigator.pop(context, {'address': savedAddress, 'location': currentLocation});
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pick Location'),
        backgroundColor: Color.fromARGB(255, 250, 182, 114),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200,
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: LatLng(37.7749, -122.4194), // San Francisco as default location
                  zoom: 12,
                ),
                markers: (currentLocation != null)
                    ? {
                        Marker(
                          markerId: MarkerId('current_location'),
                          position: currentLocation!,
                          onTap: () {
                            _onMapSearch(currentLocation!);
                          },
                        ),
                      }
                    : {},
                onTap: (position) {
                  _onMapSearch(position);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: 'Enter Address',
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _searchAddressOnMap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 250, 182, 114),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    child: Text('Search on Google Maps'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _saveAddress, // Save the entered address
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 250, 182, 114),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    child: Text('Save Address'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/
