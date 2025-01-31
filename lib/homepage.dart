import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latestlnf/add_post_tab.dart';
import 'package:latestlnf/drawer_contain.dart/drawer.dart';
import 'package:latestlnf/item_detail_page.dart';
import 'package:latestlnf/my_posts_tab.dart';
import 'package:latestlnf/service/user_provider.dart';
import 'package:latestlnf/utils/location_utils.dart';
import 'package:provider/provider.dart';

import 'filter_dialog.dart'; // Import the FilterWidget
 
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  String _selectedCategory = 'All'; // Add selected category state
  late Stream<QuerySnapshot> _lostItemsStream = Stream.empty(); // Initialize with empty streams
  late Stream<QuerySnapshot> _foundItemsStream = Stream.empty(); // Initialize with empty streams
  User? _currentUser;
  late UserProvider _userProvider;
  Position? _userPosition;
  bool _isLoading = true;
  bool _isDisposed = false; // Track if the widget is disposed

  @override
  void initState() {
    super.initState();
    _updateStreams();
    checkUserLoginStatus();
    _initializeUserPosition();
  }

  @override
  void dispose() {
    _isDisposed = true; // Set the flag to true when disposing
    super.dispose();
  }

  void _updateStreams() {
    _lostItemsStream = _selectedCategory == 'All'
        ? FirebaseFirestore.instance.collection('lost_items').snapshots()
        : FirebaseFirestore.instance.collection('lost_items').where('category', isEqualTo: _selectedCategory).snapshots();
    _foundItemsStream = _selectedCategory == 'All'
        ? FirebaseFirestore.instance.collection('found_items').snapshots()
        : FirebaseFirestore.instance.collection('found_items').where('category', isEqualTo: _selectedCategory).snapshots();
  }

  Future<void> _initializeUserPosition() async {
    bool hasPermission = await _checkLocationPermission();
    if (hasPermission) {
      _userPosition = await _getCurrentPosition();
    }
    if (!_isDisposed) {
      setState(() {
        _isLoading = false;
      });
    }
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

  final List<Widget> _tabs = [
    HomeTab(lostItemsStream: Stream.empty(), foundItemsStream: Stream.empty()), // Initialize with empty streams
    const AddPostTab(),
    MyPostsTab(),
  ];

  void checkUserLoginStatus() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          _userProvider.updateUser(user.uid, userData['username'], userData['phoneNumber']);
        }
      }
      if (!_isDisposed) {
        setState(() {
          _currentUser = user;
        });
      }
    });
  }

  void _applyFilter(String category) {
    setState(() {
      _selectedCategory = category;
      _updateStreams(); // Update streams immediately
    });
  }

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserProvider>(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Lostify'),
          backgroundColor: const Color.fromARGB(255, 250, 182, 114),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Lostify'),
        backgroundColor: const Color.fromARGB(255, 250, 182, 114),
        centerTitle: true,
      ),
      drawer: CustomDrawer(userName: _userProvider.username),
      body: Column(
        children: [
          if (_currentIndex == 0) // Only show filter on homepage
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerRight, // Align filter to the right
                child: Container(
                  width: 120, // Set width to match the example image
                  child: FilterWidget(onFilter: _applyFilter),
                ),
              ),
            ),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _tabs.map((tab) {
                if (tab is HomeTab) {
                  return HomeTab(
                    lostItemsStream: _lostItemsStream,
                    foundItemsStream: _foundItemsStream,
                  );
                }
                return tab;
              }).toList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Add Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'My Posts',
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  final Stream<QuerySnapshot> lostItemsStream;
  final Stream<QuerySnapshot> foundItemsStream;

  HomeTab({Key? key, required this.lostItemsStream, required this.foundItemsStream}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildItemsGrid(context, lostItemsStream),
        _buildItemsGrid(context, foundItemsStream),
      ],
    );
  }

  Widget _buildItemsGrid(BuildContext context, Stream<QuerySnapshot> stream) {
    final userProvider = Provider.of<UserProvider>(context);

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        final data = snapshot.data;

        if (data == null || data.size == 0) {
          return SliverToBoxAdapter(
            child: Center(child: Text('No items report.')),
          );
        }

        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 0.7,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = data.docs[index];
              final itemData = item.data() as Map<String, dynamic>?;

              if (itemData == null) {
                return Container();
              }

              final imageURL = itemData.containsKey('imageURLs') ? (itemData['imageURLs'] as List).first : null;
              final date = itemData['date'] as Timestamp;
              final category = itemData['category'] as String?;
              final username = itemData['username'] as String? ?? userProvider.username ?? "Unknown";
              final location = itemData['location'] as GeoPoint?;

              int? distanceBetweenTwoPoints;
              final homeState = context.findAncestorStateOfType<_MyHomePageState>();
              final userPosition = homeState?._userPosition;

              if (homeState != null && homeState._userPosition != null && location != null) {
                distanceBetweenTwoPoints = LocationUtils.calculateDistance(
                  homeState._userPosition!.latitude,
                  homeState._userPosition!.longitude,
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
                              'Post by $username', // Use item's username
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
            childCount: data.docs.length,
          ),
        );
      },
    );
  }

  String _formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return DateFormat.yMMMd().format(date);
  }
}

