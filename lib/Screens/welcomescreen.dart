import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fl_chart/fl_chart.dart'; // Import the chart package
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trainez_miniproject/core/mycolors.dart';

import 'package:shared_preferences/shared_preferences.dart';

Future<void> logout() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // Clears saved login data
}


class WelcomeScreen extends StatefulWidget {
  final String? userId;
  const WelcomeScreen({required this.userId, super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  // Function to determine BMI Category
  String getBMICategory(double bmi) {
    if (bmi < 18.5) return "Underweight";
    else if (bmi >= 18.5 && bmi < 24.9) return "Normal Weight";
    else if (bmi >= 25 && bmi < 29.9) return "Overweight";
    else return "Obese";
  }

  // Function to get Color based on BMI Category
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: MyColor.orange,
        title: Text('Dashboard',style: TextStyle(color: Colors.white,fontSize: 30, fontWeight: FontWeight.bold),),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(widget.userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("No data found!"));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;

          double height = double.tryParse(userData['height'].toString()) ?? 0.0; 
          double weight = double.tryParse(userData['weight'].toString()) ?? 0.0;

          if (height == 0.0 || weight == 0.0) {
            return Center(child: Text("Invalid height or weight!"));
          }

          double heightInMeters = height / 100;
          double bmi = weight / (heightInMeters * heightInMeters);
          String category = getBMICategory(bmi);
          Color categoryColor = getCategoryColor(category);

          return Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Align(alignment: Alignment.centerLeft, child: Text('Welcome,', style: TextStyle(fontSize: 20))),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: Align(alignment: Alignment.centerLeft, child: Text(userData['username'], style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
                ),
                //SizedBox(height: 5),
                


              Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(
                      "assets/images/BmiSheet.svg", 
                    ),
                    Positioned(top: 50,left:45 ,child: Text("BMI(Body Mass Index)",style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),)),
                  Positioned(top: 80,left: 45,child: Text("You are $category",style: TextStyle(color: Colors.white,fontSize: 15),)),
                    Positioned(top: 120,left:45 ,child: Text("Your BMI :${bmi.toStringAsFixed(1)}",style: TextStyle(color: Colors.white,fontSize: 25,fontWeight: FontWeight.bold),),),
                    Positioned(top:70,right: 20,
                      child: SizedBox(
                        height: 100,
                        width: 100,
                        child: PieChart(
                            PieChartData(
                              sectionsSpace: 0,
                              centerSpaceRadius: 0,
                              sections: [
                                PieChartSectionData(
                                  value: bmi, // Highlighted sector
                                  title: bmi.toStringAsFixed(1),
                                  
                                  color: categoryColor,
                                  radius: 45,
                                  titleStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                PieChartSectionData(
                                  value: 100 - bmi, // Remaining empty part
                                  color: Colors.white,
                                  radius: 45,
                                  title: '',
                                ),
                              ],
                            ),
                          ),
                      ),)
                      
                  ]),   
              ],
            ),
          );
        },
      ),
     
    );
  }
}

