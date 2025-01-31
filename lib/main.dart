import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latestlnf/homepage.dart';
import 'package:latestlnf/posting/image_similarity_screen.dart';
import 'package:latestlnf/posting/match_image.dart';
import 'package:latestlnf/service/auth_page.dart';
import 'package:latestlnf/service/login.dart';
import 'package:latestlnf/service/register.dart';
import 'package:latestlnf/service/user_provider.dart';
import 'package:latestlnf/splash_screen.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]); // Lock orientation to portrait mode
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home:  const SplashScreenPage(), // Navigate to the splash screen first
        routes: {
          '/homepage': (context) => const MyHomePage(),
          '/auth': (context) => const AuthPage(),
          '/register': (context) => RegisterPage(
                onTap: () {
                  Navigator.pushNamed(context, '/auth');
                },
              ),
          '/login': (context) => LoginPage(
                onTap: () {
                  Navigator.pushNamed(context, '/register');
                },
              ),
          '/image_similarity': (context) => ImageSimilarityScreen(),
          '/match_item': (context) => MatchItemPage(), // Add this route
        },
      ),
    );
  }
}

