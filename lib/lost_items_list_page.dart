import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latestlnf/item_detail_page.dart';
import 'package:latestlnf/service/user_provider.dart';
import 'package:latestlnf/utils/location_utils.dart';
import 'package:provider/provider.dart';

class LostItemsListPage extends StatefulWidget {
  @override
  _LostItemsListPageState createState() => _LostItemsListPageState();
}

class _LostItemsListPageState extends State<LostItemsListPage> {
  Position? _userPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeUserPosition();
  }

  Future<void> _initializeUserPosition() async {
    bool hasPermission = await _checkLocationPermission();
    if (hasPermission) {
      _userPosition = await _getCurrentPosition();
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<bool> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse || permission == LocationPermission.always;
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      debugPrint('Error obtaining position: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lost Items'),
        backgroundColor: Color.fromARGB(255, 250, 182, 114),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('lost_items').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final data = snapshot.data;

                if (data == null || data.size == 0) {
                  return Center(child: Text('No lost items found.'));
                }

                final userProvider = Provider.of<UserProvider>(context);

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Two items per row
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 0.7, // Adjust this ratio to your needs
                  ),
                  itemCount: data.docs.length,
                  itemBuilder: (context, index) {
                    final item = data.docs[index];
                    final itemData = item.data() as Map<String, dynamic>;

                    final imageURL = itemData.containsKey('imageURLs') ? (itemData['imageURLs'] as List).first : null;
                    final date = itemData['date'] as Timestamp;
                    final category = itemData['category'] as String?;
                    final username = itemData['username'] as String? ?? userProvider.username ?? "Unknown";
                    final location = itemData['location'] as GeoPoint?;

                    int? distanceBetweenTwoPoints;

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
                              username: itemData['username'] as String? ?? userProvider.username ?? "Unknown",
                              phoneNumber: itemData['phoneNumber'] as String? ?? userProvider.phoneNumber,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
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
                                child: imageURL != null
                                    ? Image.network(
                                        imageURL,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        color: Colors.grey,
                                        child: const Icon(Icons.image, color: Colors.white),
                                      ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category ?? 'Unknown Category',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDate(date),
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
                  },
                );
              },
            ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return DateFormat.yMMMd().format(date);
  }
}




/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:latestlnf/item_detail_page.dart';

class LostItemsListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lost Items'),
        backgroundColor: Color.fromARGB(255, 250, 182, 114),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('lost_items').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final data = snapshot.data;

          if (data == null || data.size == 0) {
            return Center(child: Text('No lost items found.'));
          }

          return ListView.builder(
            itemCount: data.docs.length,
            itemBuilder: (context, index) {
              final item = data.docs[index];
              final itemData = item.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(itemData['title'] ?? 'No Title'),
                subtitle: Text('Posted by: ${itemData['username'] ?? 'Unknown'}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItemDetailPage(item: item, username: '',),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}*/

/*import 'package:flutter/material.dart';

class LostItemDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color here
      appBar: AppBar(
        title: Text('Lost Item'),
         backgroundColor: const Color.fromARGB(255, 250, 182, 114),
          centerTitle: true,
      ),
     body: const Center(
      ),
    );
  }
}*/
