import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class MatchItemDetailPage extends StatefulWidget {
  final QueryDocumentSnapshot item;
  final List<String>? imageURLs;
  final String username;
  final String? phoneNumber;

  const MatchItemDetailPage({super.key, required this.item, this.imageURLs, required this.username, this.phoneNumber});

  @override
  _MatchItemDetailPageState createState() => _MatchItemDetailPageState();
}

class _MatchItemDetailPageState extends State<MatchItemDetailPage> {
  GoogleMapController? mapController;
  LatLng? itemLocation;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
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
      backgroundColor: Colors.white, // Set background color here
      appBar: AppBar(
        title: const Text('Matched Item Detail'),
        backgroundColor: const Color.fromARGB(255, 250, 182, 114),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.imageURLs != null && widget.imageURLs!.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.imageURLs!.map((url) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.network(
                          url,
                          width: 140,
                          height: 250,
                          fit: BoxFit.contain,
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 20),
                Text(
                  'Type: ${widget.item['type'] as String}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  'Username: ${widget.username}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  'Title: ${widget.item['title'] as String}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  'Date: ${_formatDate(widget.item['date'] as Timestamp)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  'Time: ${widget.item['time'] as String}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  'Category: ${widget.item['category'] as String}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  'Description: ${widget.item['description'] as String}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  'Address: ${widget.item['address'] as String}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
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
                if (isLoading)
                  const CircularProgressIndicator(),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _launchPhoneCall(widget.phoneNumber ?? ''),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 250, 182, 114),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        textStyle: const TextStyle(fontSize: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      child: const Text(
                        'Call',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 50),
                    ElevatedButton(
                      onPressed: () => _launchSMSorWhatsApp(widget.phoneNumber ?? ''),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 250, 182, 114),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        textStyle: const TextStyle(fontSize: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      child: const Text(
                        'SMS',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return DateFormat.yMMMd().format(date);
  }

  void _launchPhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunch(phoneUri.toString())) {
      await launch(phoneUri.toString());
    } else {
      throw 'Could not launch $phoneUri';
    }
  }

  void _launchSMSorWhatsApp(String phoneNumber) async {
    final Uri smsUri = Uri(scheme: 'sms', path: phoneNumber);
    final Uri whatsappUri = Uri.parse("https://wa.me/$phoneNumber");
    if (await canLaunch(smsUri.toString())) {
      await launch(smsUri.toString());
    } else if (await canLaunch(whatsappUri.toString())) {
      await launch(whatsappUri.toString());
    } else {
      throw 'Could not launch SMS or WhatsApp';
    }
  }
}
