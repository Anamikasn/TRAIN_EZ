import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trainez_miniproject/Screens/userinfoscreen.dart';
import 'package:trainez_miniproject/core/mycolors.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formkey,
        child: Container(
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
              stops: [0.0, 0.2, 1.0],
              tileMode: TileMode.clamp,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 25),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Image.asset("assets/images/SignUpVector.png", height: 180, width: 180),
                      SizedBox(height: 20),
                      Text('Hi there!', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                      Text('Create your account', style: TextStyle(fontSize: 20)),
                      SizedBox(height: 30),
                      Align(alignment: Alignment.centerLeft, child: Text('Username', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
                      SizedBox(height: 10),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter Your Username';
                          } else if (RegExp(r'[A-Z]').hasMatch(value) || RegExp(r'[^a-z0-9_]').hasMatch(value)) {
                            return 'Username must only contain lowercase letters, numbers and _';
                          }
                          return null;
                        },
                        controller: _usernameController,
                        decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'Enter UserName', fillColor: Colors.white, filled: true),
                      ),
                      SizedBox(height: 10),
                      Align(alignment: Alignment.centerLeft, child: Text('Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
                      SizedBox(height: 10),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter Your Email';
                          }
                          return null;
                        },
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'Enter Email', fillColor: Colors.white, filled: true),
                      ),
                      SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter Your Password';
                          } else if (value.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                        controller: _passwordController,
                        decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'Enter Password', fillColor: Colors.white, filled: true),
                      ),
                      SizedBox(height: 35),
                      ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                if (_formkey.currentState!.validate()) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  try {
                                    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                    );

                                    String userId = userCredential.user!.uid;

                                    await FirebaseFirestore.instance.collection('users').doc(userId).set({
                                      'username': _usernameController.text,
                                      'email': _emailController.text,
                                      'userId': userId,
                                    });

                                    print('Created New Account: ${userCredential.user!.uid}');
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (ctx) => PersonalInfoScreen(userId: userId),
                                      ),
                                    );
                                  } catch (error) {
                                    print('Error: ${error.toString()}');
                                  } finally {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                } else {
                                  print('Data Empty');
                                }
                              },
                        child: isLoading
                            ? CircularProgressIndicator(color: Colors.white,strokeWidth: 2,)
                            : Text('Sign Up', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                        style: ButtonStyle(
                          overlayColor: WidgetStateProperty.all(Colors.grey),
                          backgroundColor: WidgetStateProperty.all(Colors.black),
                          minimumSize: WidgetStateProperty.all(Size(double.infinity, 50)),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Already have an account? Login'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
