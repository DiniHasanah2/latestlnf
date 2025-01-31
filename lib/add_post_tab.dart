import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'posting/match_image.dart';
import 'posting/report_found_item.dart';
import 'posting/report_lost_item.dart';

class AddPostTab extends StatelessWidget {
  const AddPostTab({super.key});

  @override
  Widget build(BuildContext context) {
    void reportLostItem(BuildContext context) {
      if (FirebaseAuth.instance.currentUser != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportLostItemPage(onTap: () {}),
          ),
        );
      } else {
        Navigator.pushNamed(context, '/login');
      }
    }

    void reportFoundItem(BuildContext context) {
      if (FirebaseAuth.instance.currentUser != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportFoundItemPage(onTap: () {}),
          ),
        );
      } else {
        Navigator.pushNamed(context, '/login');
      }
    }

    void uploadImage(BuildContext context) {
      if (FirebaseAuth.instance.currentUser != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>  MatchItemPage()),
        );
      } else {
        Navigator.pushNamed(context, '/login');
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo_lost.png',
              width: 200,
              height: 100,
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              width: 167,
              height: 45,
              child: ElevatedButton(
                onPressed: () => reportLostItem(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 168, 66, 7),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                child: const Text('Report Lost Item'),
              ),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              width: 167,
              height: 45,
              child: ElevatedButton(
                onPressed: () => reportFoundItem(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 206, 101, 9),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                child: const Text('Report Found Item'),
              ),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              width: 167,
              height: 45,
              child: ElevatedButton(
                onPressed: () => uploadImage(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 234, 160, 107),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                child: const Text('Match Item List'),
              ),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}






/*import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'posting/declare_as_found.dart';
import 'posting/match_image.dart';
import 'posting/report_lost_item.dart';

class AddPostTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void reportLostItem(BuildContext context) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ReportLostItemPage(onTap: () {},)),
          /*Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ReportLostItemPage()),
          );
        })),*/
      );
    }

    void declareAsFound(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ReportFoundItemPage(onTap: () {  },)),
      );
    }

    void uploadImage() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UploadImagePage()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Post'),
        automaticallyImplyLeading: false, // No back arrow
        backgroundColor: Color.fromARGB(255, 250, 182, 114),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo_lost.png',
              width: 200,
              height: 100,
            ),
            SizedBox(height: 16.0),
            SizedBox(
              width: 160, // Set the desired width
              height: 45,  // Set the desired height
              child: ElevatedButton(
                onPressed: () => reportLostItem(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 168, 66, 7),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                child: Text('Report Lost Item'),
              ),
            ),
            SizedBox(height: 16.0),
            SizedBox(
              width: 160, // Set the desired width
              height: 45,  // Set the desired height
              child: ElevatedButton(
                onPressed: () => declareAsFound(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 206, 101, 9),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                child: Text('Declare as Found'),
              ),
            ),
            SizedBox(height: 16.0),
            SizedBox(
              width: 160, // Set the desired width
              height: 45,  // Set the desired height
              child: ElevatedButton(
                onPressed: uploadImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 234, 160, 107),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                child: Text('Image matching'),
              ),
            ),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}*/

/*import 'package:flutter/material.dart';
import 'package:fyp_dini/service/login.dart'; // Import the LoginPage

import 'posting/declare_as_found.dart';
import 'posting/match_image.dart';
import 'posting/report_lost_item.dart';

class AddPostTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void reportLostItem(BuildContext context) {
      // Navigate to LoginPage first
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage(onTap: () {
          // Upon successful login, navigate to ReportLostItemPage
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ReportLostItemPage()),
          );
        })),
      );
    }

    void declareAsFound(BuildContext context) {
      // Navigate to LoginPage first
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage(onTap: () {
          // Upon successful login, navigate to ReportFoundItemPage
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ReportFoundItemPage()),
          );
        })),
      );
    }

    void uploadImage() {
      // Implement the functionality for uploading an image
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UploadImagePage()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Post'),
        backgroundColor: Color.fromARGB(255, 250, 182, 114),
        centerTitle: true, // Center-align the title
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Image
            Image.asset(
              'assets/logo_lost.png',
              width: 1000,
              height: 100,
            ),
            SizedBox(height: 16.0),
            // Button 1: Report Lost Item
            ElevatedButton(
              onPressed: () => reportLostItem(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 168, 66, 7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
              child: Text('Report Lost Item'),
            ),
            SizedBox(height: 16.0),
            // Button 2: Declare as Found
            ElevatedButton(
              onPressed: () => declareAsFound(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 206, 101, 9),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
              child: Text('Declare as Found'),
            ),
            SizedBox(height: 16.0),
            // Button 3: Upload an Image
            ElevatedButton(
              onPressed: uploadImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 234, 160, 107),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
              child: Text('Image matching'),
            ),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}*/
