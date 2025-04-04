import 'package:flutter/material.dart';
import 'package:trainez_miniproject/Screens/exercisescreen.dart';
import 'package:trainez_miniproject/core/mycolors.dart';

class ActivityScreen extends StatelessWidget {

  final List<Map<String, String>> exercises = [
    {
      "name": "Squats",
      "image": "assets/images/Squats.jpg",
      "description": "Squats help in strengthening legs and glutes."
    },
    {
      "name": "Push-ups",
      "image": "assets/images/PushUp.jpg",
      "description": "Push-ups help in building upper body strength."
    },
    {
      "name": "Lunges",
      "image": "assets/images/lunges.jpg",
      "description": "Lunges improve lower body strength and balance."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Goals',style: TextStyle(
          color: Colors.white,
          fontSize: 35,
          fontWeight: FontWeight.bold
        ),),
        backgroundColor: MyColor.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView.separated(
          itemCount: exercises.length,
          itemBuilder: (ctx, index) {
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => ExerciseScreen(
                      name: exercises[index]['name']!,
                      image: exercises[index]['image']!,
                      description: exercises[index]['description']!,
                    ),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(exercises[index]['image']!),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  exercises[index]['name']!,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    //backgroundColor: Colors.black54,
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (ctx, index) => SizedBox(height: 10),
        ),
      ),
    );
  }
}