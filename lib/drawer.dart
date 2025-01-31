import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:latestlnf/drawer_contain.dart/found_items_list_page.dart';
import 'package:latestlnf/drawer_contain.dart/lost_items_list_page.dart';

import 'privacy_policy.dart'; // Import PrivacyPolicyPage
import 'subscription.dart'; // Import SubscriptionPage

class CustomDrawer extends StatelessWidget {
  final String? userName;

  const CustomDrawer({super.key, this.userName});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    void logOut() async {
      await FirebaseAuth.instance.signOut();
      Navigator.pop(context); // Close the drawer
      Navigator.pushReplacementNamed(context, '/homepage'); // Navigate back to home
    }

    void navigateToAuthPage() {
      Navigator.pop(context); // Close the drawer
      Navigator.pushReplacementNamed(context, '/auth'); // Navigate to login page
    }

    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      elevation: 0,
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 250, 182, 114),
                border: Border(
                  bottom: BorderSide.none,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome ${userName ?? 'Guest'}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.remove_circle),
              title: Text('Lost Items'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LostItemsListPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.add_circle),
              title: Text('Found Items'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FoundItemsListPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy Policy'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.subscriptions),
              title: const Text('Subscription'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SubscriptionPage()),
                );
              },
            ),
            ListTile(
              leading: user != null ? const Icon(Icons.logout) : const Icon(Icons.login),
              title: Text(user != null ? 'Log Out' : 'Log In'),
              onTap: user != null ? logOut : navigateToAuthPage,
            ),
          ],
        ),
      ),
    );
  }
}


/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'privacy_policy.dart'; // Import PrivacyPolicyPage
import 'subscription.dart'; // Import SubscriptionPage

class CustomDrawer extends StatelessWidget {
  final String? userName;

  const CustomDrawer({super.key, this.userName});
  
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    void logOut() async {
      await FirebaseAuth.instance.signOut();
      Navigator.pop(context); // Close the drawer
      Navigator.pushReplacementNamed(context, '/homepage'); // Navigate back to home
    }

    void navigateToAuthPage() {
      Navigator.pop(context); // Close the drawer
      Navigator.pushReplacementNamed(context, '/auth'); // Navigate to login page
    }

    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      elevation: 0,
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 250, 182, 114),
                border: Border(
                  bottom: BorderSide.none,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome ${userName ?? 'Guest'}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            /*ListTile(
              leading: Icon(Icons.remove_circle),
              title: Text('Lost Items'),
              onTap: () async {
                Navigator.pop(context);
                // Fetch the lost item document from Firestore
                QuerySnapshot lostItemsSnapshot = await FirebaseFirestore.instance.collection('lost_items').limit(1).get();
                if (lostItemsSnapshot.docs.isNotEmpty) {
                  DocumentSnapshot lostItemDoc = lostItemsSnapshot.docs.first;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LostItemDetailPage(item: lostItemDoc),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No lost items found')),
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.add_circle),
              title: Text('Found Items'),
              onTap: () async {
                Navigator.pop(context);
                // Fetch the found item document from Firestore
                QuerySnapshot foundItemsSnapshot = await FirebaseFirestore.instance.collection('found_items').limit(1).get();
                if (foundItemsSnapshot.docs.isNotEmpty) {
                  DocumentSnapshot foundItemDoc = foundItemsSnapshot.docs.first;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FoundItemDetailPage(item: foundItemDoc),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No found items found')),
                  );
                }
              },
            ),*/
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy Policy'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.subscriptions),
              title: const Text('Subscription'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SubscriptionPage()),
                );
              },
            ),
            ListTile(
              leading: user != null ? const Icon(Icons.logout) : const Icon(Icons.login),
              title: Text(user != null ? 'Log Out' : 'Log In'),
              onTap: user != null ? logOut : navigateToAuthPage,
            ),
          ],
        ),
      ),
    );
  }
}*/


















/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'founditem_detail.dart';
import 'lostitem_detail.dart';
import 'privacy_policy.dart'; // Import PrivacyPolicyPage
import 'subscription.dart'; // Import SubscriptionPage

class CustomDrawer extends StatelessWidget {
  final String? userName;

  const CustomDrawer({super.key, this.userName});
  
  get itemDocumentSnapshot => null;

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    void logOut() async {
      await FirebaseAuth.instance.signOut();
      Navigator.pop(context); // Close the drawer
      Navigator.pushReplacementNamed(context, '/homepage'); // Navigate back to home
    }

    void navigateToAuthPage() {
      Navigator.pop(context); // Close the drawer
      Navigator.pushReplacementNamed(context, '/auth'); // Navigate to login page
    }

    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      elevation: 0,
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 250, 182, 114),
                border: Border(
                  bottom: BorderSide.none,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome ${userName ?? 'Guest'}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
  leading: Icon(Icons.remove_circle),
  title: Text('Lost Items'),
  onTap: () {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LostItemDetailPage()),
    );
  },
),
ListTile(
  leading: Icon(Icons.add_circle),
  title: Text('Found Items'),
  onTap: () {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FoundItemDetailPage()),
    );
  },
),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy Policy'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.subscriptions),
              title: const Text('Subscription'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SubscriptionPage()),
                );
              },
            ),
            ListTile(
              leading: user != null ? const Icon(Icons.logout) : const Icon(Icons.login),
              title: Text(user != null ? 'Log Out' : 'Log In'),
              onTap: user != null ? logOut : navigateToAuthPage,
            ),
          ],
        ),
      ),
    );
  }
}*/


/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'privacy_policy.dart'; // Import PrivacyPolicyPage
import 'subscription.dart'; // Import SubscriptionPage

class CustomDrawer extends StatelessWidget {
  final String? userName;

  const CustomDrawer({Key? key, this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      elevation: 0, // Remove default elevation to avoid double border
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              color: Color.fromARGB(255, 250, 182, 114),
              padding: EdgeInsets.symmetric(vertical: 30.0),
              child: Center(
                child: Text(
                  'Welcome ${userName ?? ''}',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.subscriptions),
              title: Text('Subscribe'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SubscriptionPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text('Privacy Policy'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PrivacyPolicyPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout), // Add icon for log out
              title: Text('Log In'),
              onTap: () {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login'); // Navigate to login page
  },
              /*onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pop(context);
              },*/
            ),
          ],
        ),
      ),
    );
  }
}*/
