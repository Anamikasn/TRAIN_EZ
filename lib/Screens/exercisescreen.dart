import 'package:flutter/material.dart';
import 'package:trainez_miniproject/Screens/camerpage.dart';
import 'package:trainez_miniproject/core/mycolors.dart';

class ExerciseScreen extends StatelessWidget {
  final String name;
  final String image;
  final String description;

  const ExerciseScreen({
    required this.name,
    required this.image,
    required this.description,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: MyColor.orange,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              name,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              description,
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
          ),
          Align(alignment: Alignment.bottomCenter,
          child: ElevatedButton(
            onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CameraPage()),
            );
          },
           child: Text("Open Camera",style: TextStyle(color: Colors.white),),
           style: ButtonStyle(backgroundColor:WidgetStatePropertyAll(Colors.black)),))
        ],
      ),
    );
  }
}