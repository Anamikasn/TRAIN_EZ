import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trainez_miniproject/core/mycolors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'dart:async';

Future<void> logout() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}

class WelcomeScreen extends StatefulWidget {
  final String? userId;
  const WelcomeScreen({required this.userId, super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int stepsToday = 0;
  bool isStepLoading = true;
  late Timer stepTimer;

  String getBMICategory(double bmi) {
    if (bmi < 18.5) return "Underweight";
    else if (bmi < 25) return "Normal Weight";
    else if (bmi < 30) return "Overweight";
    else return "Obese";
  }

  Color getCategoryColor(String category) {
    switch (category) {
      case "Underweight":
        return Colors.blue;
      case "Normal Weight":
        return Colors.green;
      case "Overweight":
        return const Color.fromARGB(255, 210, 126, 0);
      case "Obese":
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchStepsToday();

    // Update step count every 1 minute
    stepTimer = Timer.periodic(Duration(minutes: 1), (_) {
      fetchStepsToday();
    });
  }

  @override
  void dispose() {
    stepTimer.cancel();
    super.dispose();
  }

  Future<void> fetchStepsToday() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayKey = "${now.year}-${now.month}-${now.day}";
    final lastSavedDate = prefs.getString("step_date") ?? "";
    final savedSteps = prefs.getInt("step_value") ?? 0;

    // Simulate getting total steps from pedometer or sensor
    int totalStepsFromSensor = 5000 + Random().nextInt(1000); // Replace with real sensor value

    if (lastSavedDate != todayKey) {
      // New day: save current total steps as base
      await prefs.setString("step_date", todayKey);
      await prefs.setInt("step_value", totalStepsFromSensor);
      if (mounted) {
        setState(() {
          stepsToday = 0;
          isStepLoading = false;
        });
      }
    } else {
      int newSteps = totalStepsFromSensor - savedSteps;
      if (mounted) {
        setState(() {
          stepsToday = newSteps;
          isStepLoading = false;
        });
      }
    }
  }

  // 🔥 Calorie Calculation
  double calculateCaloriesBurned(int steps, double weightKg, double heightCm) {
    double strideLength = heightCm * 0.415 / 100; // Estimate stride length in meters
    double distance = steps * strideLength; // Distance in meters
    double calories = (distance * weightKg * 0.57) / 1000; // kcal
    return calories;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: MyColor.orange,
        title: Text('Dashboard',
            style: TextStyle(
                color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("No data found!"));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          double height =
              double.tryParse(userData['height'].toString()) ?? 0.0;
          double weight =
              double.tryParse(userData['weight'].toString()) ?? 0.0;

          if (height == 0.0 || weight == 0.0) {
            return Center(child: Text("Invalid height or weight!"));
          }

          double heightInMeters = height / 100;
          double bmi = weight / (heightInMeters * heightInMeters);
          String category = getBMICategory(bmi);
          Color categoryColor = getCategoryColor(category);

          double caloriesBurned = calculateCaloriesBurned(stepsToday, weight, height);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text('Welcome,', style: TextStyle(fontSize: 20)),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Text(userData['username'],
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(height: 20),

                // BMI CARD
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset("assets/images/BmiSheet.svg"),
                    Positioned(
                      top: 50,
                      left: 45,
                      child: Text("BMI (Body Mass Index)",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ),
                    Positioned(
                      top: 80,
                      left: 45,
                      child: Text("You are $category",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          )),
                    ),
                    Positioned(
                      top: 120,
                      left: 45,
                      child: Text("Your BMI : ${bmi.toStringAsFixed(1)}",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold)),
                    ),
                    Positioned(
                      top: 70,
                      right: 20,
                      child: SizedBox(
                        height: 100,
                        width: 100,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 0,
                            centerSpaceRadius: 0,
                            sections: [
                              PieChartSectionData(
                                value: bmi > 100 ? 100 : bmi,
                                title: bmi.toStringAsFixed(1),
                                color: categoryColor,
                                radius: 45,
                                titleStyle: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              PieChartSectionData(
                                value: bmi > 100 ? 0 : 100 - bmi,
                                color: Colors.white,
                                radius: 45,
                                title: '',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10),

                // STEP COUNT CARD
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Container(
                        height: 140,
                        width: 200,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 10)
                          ],
                        ),
                          child:
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.directions_walk_sharp,size: 55,),
                                // Text(
                                //   'Steps Taken',
                                //   style: TextStyle(
                                //       fontSize: 18, fontWeight: FontWeight.bold),
                                // ),
                                SizedBox(height: 10),
                                isStepLoading
                                    ? Center(child: CircularProgressIndicator())
                                    : Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$stepsToday steps',
                                            style: TextStyle(
                                                fontSize: 25,
                                                color: MyColor.orange,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                              ] ,
                            ),
                      
                            
                      ),
                      SizedBox(width: 20,),
                      Container(
                        height: 140,
                        width: 140,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 10)
                          ],
                        ),
                          child: Align(alignment: Alignment.center,
                            child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                           Icon(Icons.local_fire_department_sharp,
                                           color: Colors.red,
                                           size: 50,),
                                            Text(
                                          caloriesBurned.toStringAsFixed(2),
                                          style: TextStyle(
                                            fontSize: 23,
                                            color: MyColor.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "kcal",
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: MyColor.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                          ],
                                        ),
                          ),
                            
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
