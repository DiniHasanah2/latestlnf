import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting

import 'myreport_detail.dart'; // Updated import to match the actual filename

class MyPostsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FirebaseAuth.instance.currentUser != null
            ? MyPostsList()
            : ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 234, 160, 107),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                child: Text('Login to view your posts'),
              ),
      ),
    );
  }
}

class MyPostsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('user_posts')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        final List<DocumentSnapshot> posts = snapshot.data!.docs;

        if (posts.isEmpty) {
          return Center(child: Text('No posts to display'));
        }

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final item = posts[index];
            final imageURLs = List<String>.from(item['imageURLs'] ?? []);
            final category = item['category'] as String;
            final description = item['description'] as String;
            final timestamp = item['date'] as Timestamp;

            // Convert Timestamp to DateTime
            final postDate = timestamp.toDate();
            // Format the date
            final formattedDate = _formatDate(postDate);

            return Container(
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imageURLs.isNotEmpty)
                    Container(
                      height: 150.0,  // Set a fixed height for the image
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        image: DecorationImage(
                          image: NetworkImage(imageURLs.first),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  SizedBox(height: 8.0),
                  Text('$category', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.0),
                  Text('$formattedDate'), // Display the formatted date
                  SizedBox(height: 8.0),
                  Text('$description'),
                  SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewItemScreen(item: item),
                            ),
                          );
                        },
                        child: Text('Detail'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 250, 182, 114),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.0),
                      ElevatedButton(
                        onPressed: () {
                          item.reference.delete();
                          FirebaseFirestore.instance.collection('lost_items').doc(item.id).delete();
                          FirebaseFirestore.instance.collection('found_items').doc(item.id).delete();
                        },
                        child: Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 250, 182, 114),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }
}
