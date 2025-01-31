import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<String>> _fetchSimilarImagesFromAPI(List<String> imageUrls) async {
  final response = await http.post(
    Uri.parse('http://192.168.171.226:5000/predict'),  // Replace with your local IP address
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'image_urls': imageUrls}),
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body)['similar_images'];
    return data.map((item) => item as String).toList();
  } else {
    throw Exception('Failed to load similar images');
  }
}
