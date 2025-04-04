import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trainez_miniproject/Screens/resetpasswordscreen.dart';
import 'package:trainez_miniproject/Screens/signupscreen.dart';
import 'package:trainez_miniproject/bottomnavigation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trainez_miniproject/core/mycolors.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future saveLoginState(String userId) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn',true);
  await prefs.setString('userId', userId);
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [
                  MyColor.orange,
                  MyColor.orange,
                  const Color(0xFFFFFFFF),
                ],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(0.0, 1.0),
                stops: [0.0,0.2,1.0],
                tileMode: TileMode.clamp),
          ),
        child:SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 50,),
              SvgPicture.asset("assets/images/LoginpageVector.svg",),
              // Container(height: 250,
              //   decoration: BoxDecoration(color:Color(0xFFFE924A),
              //     borderRadius: BorderRadius.only(bottomLeft:Radius.circular(20),bottomRight: Radius.circular(20)))),
              SizedBox(height: 20,),
              Text('Welcome back!',style: TextStyle(fontWeight: FontWeight.bold,fontSize:30 ),),
              Padding(
                padding:  EdgeInsets.all(20),
                child: Form(
                  key: _formkey,
                  child: Column(
                    children: [
                  
                      Container(width:double.infinity,child: Text('Email',style: TextStyle(fontWeight:FontWeight.bold,fontSize:20 ),textAlign: TextAlign.left,)),
                      SizedBox(height: 10),
                      TextFormField(validator: (value) {
                        if(value == null || value.isEmpty){
                          return 'Enter Your Email';
                        }
                        else{return null;}
                      },
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                      decoration: InputDecoration(border: OutlineInputBorder(),hintText:"Enter Your Email",fillColor: Colors.white,filled: true),),
                      SizedBox(height: 10),
                      Container(width:double.infinity,child: Text('Password',style: TextStyle(fontWeight:FontWeight.bold,fontSize:20))),
                      SizedBox(height: 10),
                      TextFormField(validator: (value) {
                        if(value == null || value.isEmpty){
                          return 'Enter Your Password';
                        }else{return null;}
                      },
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(border: OutlineInputBorder(),hintText:"Enter Your Password",fillColor: Colors.white,filled: true),),
                      TextButton(onPressed: (){
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (ctx){
                          //  return ResetPassword();
                          return ResetPassword();
                          })
                        );
                      }, child:Align(alignment: Alignment.centerRight,child: Text("Forgot Password?"),)),



                      ElevatedButton(onPressed: () async {
                        if(_formkey.currentState!.validate()){
                          try{
                        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: _emailController.text,
                         password: _passwordController.text);
  
                         
                         String userId = userCredential.user!.uid;

                         saveLoginState(userCredential.user!.uid);

                          Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (ctx)=>AllScreen(userId: userId))
                          );
                        }
                        
                        catch(error){
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.all(10),
                                duration: Duration(seconds: 5),
                                content: Text('Incorrect Email or Password')));
                         }
                         
                      }else{print('Data Empty');}
                      },style: ButtonStyle(
                        overlayColor: WidgetStatePropertyAll(Colors.grey),
                        backgroundColor: WidgetStatePropertyAll(Colors.black),
                        minimumSize:WidgetStatePropertyAll(Size(double.infinity, 50))), 
                      child: Text('Login',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20),),),
                      TextButton(onPressed: (){
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (ctx){
                            return SignUpScreen();
                          })
                        );
                      }, child:Text("Don't have an account? Sign Up")),
                    ],),
                ),
              ),
            ],),
        )
        
           
      ));
  }
}