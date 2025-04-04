
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trainez_miniproject/Screens/loginscreen.dart';

// import 'package:mini_project/login.dart';
// import 'package:mini_project/goal.dart';

class HomeScreen extends StatelessWidget {

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      //appBar:AppBar(),
      body:SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child:Column(
            children: [
              Image.asset("assets/images/TrainEZ Logo.png"),
              SizedBox(height:10,),
              SvgPicture.asset("assets/images/TrainEZ Text.svg",),
              SizedBox(height: 10,),
              Text('Fitness Perfected!',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,),),
              SizedBox(height:130,),
              ElevatedButton(onPressed: (){
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:(ctx){
                      return LoginScreen();
                    })
                );
              },
                style: ButtonStyle(
                  overlayColor: WidgetStatePropertyAll(Colors.grey),
                  elevation: WidgetStatePropertyAll(20),
                  backgroundColor:WidgetStatePropertyAll(Colors.black),
                  minimumSize: WidgetStatePropertyAll(Size(180,70)),),
                child: Text("GET STARTED",style: TextStyle(color: Colors.white,fontWeight:FontWeight.bold,fontSize: 17),),),
            ],
          )
        ))
    );
  }
}