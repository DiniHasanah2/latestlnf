import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ImageSimilarityScreen extends StatefulWidget {
  @override
  _ImageSimilarityScreenState createState() => _ImageSimilarityScreenState();
}

class _ImageSimilarityScreenState extends State<ImageSimilarityScreen> {
  File? _image1;
  File? _image2;
  final picker = ImagePicker();
  String _similarity = '';

  Future<void> _pickImage(int imageNumber) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        if (imageNumber == 1) {
          _image1 = File(pickedFile.path);
        } else {
          _image2 = File(pickedFile.path);
        }
      }
    });
  }

  Future<void> _computeSimilarity() async {
    if (_image1 == null || _image2 == null) return;

    final request = http.MultipartRequest('POST', Uri.parse('http://YOUR_FLASK_SERVER_IP:5000/compute_similarity'));
    request.files.add(await http.MultipartFile.fromPath('image1', _image1!.path));
    request.files.add(await http.MultipartFile.fromPath('image2', _image2!.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final similarity = json.decode(responseData)['similarity'];
      setState(() {
        _similarity = similarity.toString();
      });
    } else {
      setState(() {
        _similarity = 'Error calculating similarity';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Similarity'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_image1 != null)
              Image.file(_image1!, height: 100, width: 100),
            ElevatedButton(
              onPressed: () => _pickImage(1),
              child: Text('Pick First Image'),
            ),
            if (_image2 != null)
              Image.file(_image2!, height: 100, width: 100),
            ElevatedButton(
              onPressed: () => _pickImage(2),
              child: Text('Pick Second Image'),
            ),
            ElevatedButton(
              onPressed: _computeSimilarity,
              child: Text('Compute Similarity'),
            ),
            Text('Similarity: $_similarity'),
          ],
        ),
      ),
    );
  }
}
