import 'package:flutter/material.dart';
import 'package:trainez_miniproject/Screens/exercisescreen.dart';
import 'package:trainez_miniproject/core/mycolors.dart';

class ActivityScreen extends StatelessWidget {

  final List<Map<String, String>> exercises = [
    {
      "name": "Squats",
      "image": "assets/images/Squats.jpg",
      "description": "Squats help in strengthening legs and glutes.",
      "instruction":'''
    1. Stand straight with your feet shoulder-width apart and toes slightly pointing outward.  
    2. Keep your back straight and engage your core for balance.  
    3. Lower your body by bending your knees and pushing your hips back until your knees are at a 90° angle.  
    4. Hold the position for 2-3 seconds, keeping your balance and engaging your muscles.  
    5. Push back up to the starting position and repeat for 10-15 reps.  
    ''' 
    },
    {
      "name": "Push-ups",
      "image": "assets/images/PushUp.jpg",
      "description": "Push-ups help in building upper body strength.",
      "instruction":'''  
      1. Start in a plank position with your hands shoulder-width apart and your body in a straight line from head to heels.
      2. Lower your body by bending your elbows until your chest is just above the ground.
      3. Hold the position for 1-2 seconds, keeping your core engaged.
      4. Push back up to the starting position by straightening your arms.
      5. Repeat for 10-15 reps, maintaining a controlled movement. 
    '''
    },
    {
      "name": "Lunges",
      "image": "assets/images/Lunges.jpg",
      "description": "Lunges improve lower body strength and balance.",
      "instruction":'''  
      1. Stand straight with your feet hip-width apart and hands on your hips or at your sides.
      2. Step forward with one leg and lower your hips until both knees form a 90° angle.
      3. Hold the position for 2-3 seconds, keeping your back straight and core engaged.
      4. Push back up to the starting position using your front leg.
      5. Repeat on the other leg and continue alternating for 10-12 reps per leg.
    '''
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
                      instruction:exercises[index]['instruction']!,
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