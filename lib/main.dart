import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:trainez_miniproject/Screens/splashscreen.dart';
import 'package:trainez_miniproject/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(
    url:'https://ocsvsyuaxvwgfngamahi.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9jc3ZzeXVheHZ3Z2ZuZ2FtYWhpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDA3NjAzMTksImV4cCI6MjA1NjMzNjMxOX0.5viYUcI_SQnDptakz8SXjQ2XegCtMVh7MA5RxAa2gFc',
  );
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
 // bool isLoggedIn = (prefs.getBool('isLoggedIn') as bool?) ?? false;

  String? userId = prefs.getString('userId');
  runApp(MyApp(isLoggedIn:isLoggedIn,userId:userId));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? userId;


  const MyApp({required this.isLoggedIn, this.userId,super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:false,
      theme: ThemeData(
        fontFamily: 'Outfit',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home:SplashScreen(isLoggedIn: isLoggedIn,userId:userId ,)
    );
  }
}

