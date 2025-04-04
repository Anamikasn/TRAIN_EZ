import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:trainez_miniproject/bottomnavigation.dart';
import 'package:trainez_miniproject/core/mycolors.dart';
//import 'package:mini_project/home.dart';

class PersonalInfoScreen extends StatefulWidget {
  final String userId;
  final bool isEditing; // Flag to differentiate between signup and edit mode
  PersonalInfoScreen({required this.userId,this.isEditing = false,super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {


  @override
void initState() {
  super.initState();
  _loadUserData();
}

Future<void> _loadUserData() async {
  DocumentSnapshot userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(widget.userId)
      .get();

  if (userDoc.exists) {
    var userData = userDoc.data() as Map<String, dynamic>;
    String? gender = userData['gender'];

    setState(() {
      _nameController.text = userData['name'] ?? '';
      _ageController.text = userData['age'] ?? '';
     // selectedItem = userData['gender'] ?? '';
      // Ensure gender is valid
      selectedItem = _genderlist.contains(gender) ? gender : null;
      _heightController.text = userData['height'] ?? '';
      _weightController.text = userData['weight'] ?? '';
    });
  }
}

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  final _genderlist = ['Male','Female','Other'];

  String? selectedItem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body:Container(
        height: double.infinity,
        width: double.infinity,
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Form(
              key: _formkey,
              child: Column(
                children: [
                  SizedBox(height: 50,),
                  Align(alignment: Alignment.centerLeft,child: Text('Personal Data',style: TextStyle(color: Colors.black,fontSize:35,fontWeight: FontWeight.bold),)),
                  SizedBox(height: 15,),
                  TextFormField(
                    validator: (value) {
                        if(value == null || value.isEmpty){
                          return 'Enter Your Name';
                        }else{return null;}
                      },
                    
                    controller:_nameController,
                    decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),labelText:'Name',fillColor: Colors.white,filled: true),
                  ),
                  SizedBox(height: 20,),
                  TextFormField(
                    validator: (value) {
                        if(value == null || value.isEmpty){
                          return 'Enter Your Age';
                        }
                        else if(value.length > 3){
                          return 'Enter a valid age';
                        }
                        else{return null;}
                      },
                    
                    controller:_ageController,
                    decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),labelText:'Age',fillColor: Colors.white,filled:true),
                    keyboardType: TextInputType.numberWithOptions(),
                  ),
                  SizedBox(height: 20,),
                  // 
                  Container(
                    
                    //decoration: BoxDecoration(color: Colors.white,border: Border.all(),borderRadius:BorderRadius.circular(10) ),
                    child: DropdownButtonFormField(
                    borderRadius: BorderRadius.circular(20),
                    
                    validator: (value) {
                        if(value == null || value.isEmpty){
                          return 'Select Your Gender';
                        }else{return null;}
                    },
                    
                    dropdownColor: Colors.white,
                    //hint: Text('Gender',style: TextStyle(),),
                    //padding: EdgeInsets.only(left: 10),
                    value: selectedItem,
                    decoration: InputDecoration(border: OutlineInputBorder(),labelText: 'Gender',fillColor: Colors.white,filled: true),
                    items:_genderlist.map((String list){
                      return DropdownMenuItem(
                      value: list,
                      child: Text(list,));
                    },).toList(),
                    onChanged: (String? newValue){
                       setState(() {
                         selectedItem = newValue;
                       }); 
                    }),
                  ),
                  SizedBox(height: 20,),
                  TextFormField(
                    validator: (value) {
                        if(value == null || value.isEmpty){
                          return 'Enter Your Height';
                        }
                        else if(value.length > 3){
                          return 'Enter a valid height';
                        }

                        else{return null;}
                      },
                    controller:_heightController,
                    decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),labelText:'Height(cm)',fillColor: Colors.white,filled: true),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20,),
                  TextFormField(
                    validator: (value) {
                        if(value == null || value.isEmpty){
                          return 'Enter Your Weight';
                        }
                        else if(value.length > 3){
                          return 'Enter a valid weight';
                        }
                        
                        else{return null;}
                      },
                    controller:_weightController,
                    decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),labelText:'Weight(kg)',fillColor: Colors.white,filled: true),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 35,),
                  ElevatedButton(onPressed: ()async{
                  FocusScope.of(context).unfocus();
                
                  if(_formkey.currentState!.validate()){
                    await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
                      'name':_nameController.text,
                      'age':_ageController.text,
                      'gender':selectedItem,
                      'height':_heightController.text,
                      'weight':_weightController.text,
                    });
                    // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx) =>AllScreen(userId:widget.userId)));
                    // }
                    // else{
                    //   print('Data Empty');
                    // };},
                        if (widget.isEditing) {
                          // If editing profile, go back to ProfileScreen
                          Navigator.of(context).pop();
                        } else {
                          // If signing up, navigate to AllScreen
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (ctx) => AllScreen(userId: widget.userId)),
                          );
                        }
                      } else {
                        print('Data Empty');
                      }
                    },
                      style: ButtonStyle(
                        overlayColor: WidgetStatePropertyAll(Colors.grey),
                        backgroundColor: WidgetStatePropertyAll(Colors.black),minimumSize:WidgetStatePropertyAll(Size(double.infinity, 50))),
                  child: Text( widget.isEditing ? 'Save Changes' : 'Submit', // Change button text dynamically,
                  style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20),)),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}