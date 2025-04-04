
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trainez_miniproject/core/mycolors.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> resetPassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Password reset email sent! Check your inbox."),behavior: SnackBarBehavior.floating,margin: EdgeInsets.all(10),),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 150),
                Text('Oopps!!', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                SizedBox(height: 30),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Enter your email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Email',
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 35),
                ElevatedButton(
                  onPressed: resetPassword,
                  child: Text(
                    'Send Reset Email',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  style: ButtonStyle(
                    overlayColor: WidgetStatePropertyAll(Colors.grey),
                    backgroundColor: WidgetStatePropertyAll(Colors.black),
                    minimumSize: WidgetStatePropertyAll(Size(double.infinity, 50)),
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
