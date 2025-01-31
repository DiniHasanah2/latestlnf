import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latestlnf/item_detail_page.dart';
import 'package:latestlnf/service/user_provider.dart';
import 'package:latestlnf/utils/location_utils.dart';
import 'package:provider/provider.dart';

class MatchItemPage extends StatefulWidget {
  @override
  _MatchItemPageState createState() => _MatchItemPageState();
}

class _MatchItemPageState extends State<MatchItemPage> {
  Map<String, dynamic>? match;
  bool _loading = false;
  Position? _userPosition;

  @override
  void initState() {
    super.initState();
    fetchMatches();
    _initializeUserPosition();
  }

  Future<void> _initializeUserPosition() async {
    bool hasPermission = await _checkLocationPermission();
    if (hasPermission) {
      _userPosition = await _getCurrentPosition();
    }
  }

  Future<bool> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      return permission == LocationPermission.whileInUse || permission == LocationPermission.always;
    }
    return true;
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      debugPrint('Error obtaining position: $e');
      return null;
    }
  }

  Future<void> fetchMatches() async {
    setState(() {
      _loading = true;
    });

    try {
      // Fetch lost and found items from Firebase Firestore
      QuerySnapshot lostItemsSnapshot = await FirebaseFirestore.instance.collection('lost_items').get();
      QuerySnapshot foundItemsSnapshot = await FirebaseFirestore.instance.collection('found_items').get();

      // Sort items by date
      var sortedLostItems = lostItemsSnapshot.docs;
      sortedLostItems.sort((a, b) {
        return (b['date'] as Timestamp).compareTo(a['date'] as Timestamp);
      });

      var sortedFoundItems = foundItemsSnapshot.docs;
      sortedFoundItems.sort((a, b) {
        return (b['date'] as Timestamp).compareTo(a['date'] as Timestamp);
      });

      var latestLostItem = sortedLostItems.isNotEmpty ? sortedLostItems.first : null;
      var latestFoundItem = sortedFoundItems.isNotEmpty ? sortedFoundItems.first : null;

      if (latestLostItem != null && latestFoundItem != null) {
        double similarity = await compareImagesWithAPI(
          latestLostItem['imageURLs'][0],
          sortedFoundItems.map((doc) => doc['imageURLs'][0] as String).toList(),
          sortedLostItems.map((doc) => doc['imageURLs'][0] as String).toList(),
        );

        if (mounted) {
          setState(() {
            if (similarity == double.infinity) {
              match = null;
            } else {
              match = {
                'lostItem': latestLostItem,
                'foundItem': latestFoundItem,
                'accuracy': similarity,
              };
            }
            _loading = false;
          });
        }
      } else {
        setState(() {
          match = null;
          _loading = false;
        });
      }
    } catch (e) {
      print("Error fetching matches: $e");
      setState(() {
        _loading = false;
      });
    }
  }

  Future<double> compareImagesWithAPI(String foundImageUrl, List<String> foundImageUrls, List<String> lostImageUrls) async {
    try {
      var payload = {
        'image_url': foundImageUrl,
        'found_image_urls': foundImageUrls,
        'lost_image_urls': lostImageUrls
      };

      var response = await http.post(
        Uri.parse('http://192.168.136.226:5000/predict'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['similar_images'] != null && responseData['similar_images'].isNotEmpty) {
          final similarity = responseData['similar_images'][0]['accuracy']; // Fetch the best match similarity
          return double.parse(similarity.toString());
        } else {
          return double.infinity;  // No similar images found
        }
      } else {
        print('API returned an error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return double.infinity;
      }
    } catch (e) {
      print("Error comparing images with API: $e");
      return double.infinity;
    }
  }

  double calculateAccuracy(double distance) {
    double maxDistance = 1000.0;
    double accuracy = (1 - (distance / maxDistance)) * 100;
    return accuracy.clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Match Item'),
        backgroundColor: const Color.fromARGB(255, 250, 182, 114),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: match != null
                  ? Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Lost Report',
                                    style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                                  ),
                                  buildItemCard(match!['lostItem']),
                                ],
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Found Report',
                                    style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                                  ),
                                  buildItemCard(match!['foundItem']),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              'Accuracy: ${match!['accuracy'].toStringAsFixed(2)}%',
                              style: const TextStyle(fontWeight: FontWeight.normal),
                            ),
                          ),
                        ),
                        if (match != null)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                'Matches found!',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                    )
                  : Column(
                      children: [
                        Center(
                          child: Text(
                            'No matching found',
                            style: const TextStyle(fontWeight: FontWeight.normal),
                          ),
                        ),
                      ],
                    ),
            ),
    );
  }

  Widget buildItemCard(QueryDocumentSnapshot item) {
    if (item == null) return Container(); // Return an empty container if item is null

    final itemData = item.data() as Map<String, dynamic>;
    final imageUrl = itemData['imageURLs'][0];
    final date = itemData['date'] as Timestamp;
    final category = itemData['category'] as String;
    final username = itemData['username'] as String;
    final location = itemData['location'] as GeoPoint?;

    int? distanceBetweenTwoPoints;
    final userProvider = Provider.of<UserProvider>(context);
    if (_userPosition != null && location != null) {
      distanceBetweenTwoPoints = LocationUtils.calculateDistance(
        _userPosition!.latitude,
        _userPosition!.longitude,
        location.latitude,
        location.longitude,
      ).truncate();
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetailPage(
              item: item,
              imageURLs: (itemData['imageURLs'] as List<dynamic>?)?.cast<String>(),
              username: itemData['username'] as String,
              phoneNumber: itemData['phoneNumber'] as String,
            ),
          ),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        color: Color.fromARGB(255, 255, 251, 251), // Set card color to transparent
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8.0),
                topRight: Radius.circular(8.0),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 120,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$category',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatDate(date)}',
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Post by $username',
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                  if (distanceBetweenTwoPoints != null)
                    Text(
                      '$distanceBetweenTwoPoints km away',
                      style: const TextStyle(fontWeight: FontWeight.normal),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildItemCardWithoutDetails() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      color: Color.fromARGB(255, 255, 251, 251), // Set card color to transparent
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No matching found',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return DateFormat.yMMMd().format(date);
  }
}
