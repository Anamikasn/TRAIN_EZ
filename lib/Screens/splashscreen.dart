import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:trainez_miniproject/Screens/homescreen.dart';
import 'package:trainez_miniproject/bottomnavigation.dart';
import 'package:trainez_miniproject/core/mycolors.dart';

class SplashScreen extends StatelessWidget {
  final bool isLoggedIn;
 final String? userId;
  const SplashScreen({super.key, required this.isLoggedIn, this.userId});

  Future _isUser(ctx) async{
    await Future.delayed(Duration(seconds: 5));
    isLoggedIn ? Navigator.of(ctx).pushReplacement(MaterialPageRoute(builder: (context)=>AllScreen(userId: userId))) : 
    Navigator.of(ctx).pushReplacement(MaterialPageRoute(builder: (context)=>HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
     _isUser(context);
    return Scaffold(
      backgroundColor: Colors.white, // Background color
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(height: 20),
          Center(child:Image.asset("assets/images/Splashlogo.png",height: 200), ),
          SizedBox(height: 30,),
          SizedBox(height: 150,),
          LoadingAnimationWidget.fourRotatingDots(color:MyColor.orange , size: 50),
          Padding(
            padding: EdgeInsets.only(bottom: 50,top: 5),
            child: Text(
              "Strength Loading...",
              style: TextStyle(color: MyColor.orange, fontSize: 20,fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}