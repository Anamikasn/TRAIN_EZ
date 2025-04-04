import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trainez_miniproject/Screens/loginscreen.dart';
import 'package:trainez_miniproject/Screens/userinfoscreen.dart';
import 'package:trainez_miniproject/core/mycolors.dart';
//import 'package:trainez_miniproject/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> logout() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // Clears saved login data
  await FirebaseAuth.instance.signOut(); // Ensure Firebase logout
}

class ProfileScreen extends StatefulWidget {
  final String? userId;
  const ProfileScreen({required this.userId, super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  //File? _image;
  final ImagePicker _picker = ImagePicker();
  //final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<String, dynamic>? userData; // Store user data
  ValueNotifier<String> _imageUrl = ValueNotifier(
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRKaiKiPcLJj7ufrj6M2KaPwyCT4lDSFA5oog&s');

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  /// Fetch user details from Firestore
  Future<void> _fetchUserData() async {
    if (widget.userId == null) return;

    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    if (snapshot.exists) {
      setState(() {
        userData = snapshot.data() as Map<String, dynamic>;
        _imageUrl.value = (userData!.containsKey('profileImage') &&
                userData!['profileImage'] != null &&
                userData!['profileImage'].isNotEmpty)
            ? userData!['profileImage']
            : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRKaiKiPcLJj7ufrj6M2KaPwyCT4lDSFA5oog&s';
      });
      // _imageUrl.value = userData!['profileImage'];
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null) return;

    File imageFile = File(pickedFile.path);
    String fileName = "public/${widget.userId}.jpg"; // Unique file name

    try {
      // Upload the image to Supabase Storage
      await Supabase.instance.client.storage.from('profile_pictures').upload(
          fileName, imageFile,
          fileOptions: FileOptions(cacheControl: '3600', upsert: true));

      // Get the public URL of the uploaded image
      final imageUrl = Supabase.instance.client.storage
              .from('profile_pictures')
              .getPublicUrl(fileName) +
          "?t=${DateTime.now().millisecondsSinceEpoch}";

      // Update Firestore with the new image URL
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({'profileImage': imageUrl});

      // Update the ValueNotifier so the UI updates dynamically
      _imageUrl.value = imageUrl;

      print("New Image URL: $imageUrl");

      // Close the bottom sheet
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      print("Error uploading image: $error");
    }
  }

  //   setState(() {
  //     _image = null;
  //   });

  //   Navigator.pop(context);
  // }

  Future<void> _removeImage() async {
    if (widget.userId == null) return;

    try {
      // Remove image from Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({'profileImage': FieldValue.delete()});

      // Remove image from Supabase Storage
      String fileName = "public/${widget.userId}.jpg";
      await Supabase.instance.client.storage
          .from('profile_pictures')
          .remove([fileName]);

      // Update the UI by setting the default placeholder
      _imageUrl.value =
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRKaiKiPcLJj7ufrj6M2KaPwyCT4lDSFA5oog&s';

      // Close bottom sheet if open
      if (mounted) {
        Navigator.pop(context);
      }

      print("Profile image removed successfully.");
    } catch (error) {
      print("Error removing image: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: MyColor.orange,
        actions: [
          IconButton(
            color: Colors.white,
            onPressed: () {
              logout();
              FirebaseAuth.instance.signOut().then((_) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (ctx) => LoginScreen()),
                );
              });
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      backgroundColor: MyColor.orange,
      body: userData == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 550,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(35),
                          topRight: Radius.circular(35),
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 100),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  userData!['name'],
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                InkWell(
                                  child: Icon(Icons.edit),
                                  onTap: () async {
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (ctx) => PersonalInfoScreen(
                                          userId: widget.userId!,
                                          isEditing: true,
                                        ),
                                      ),
                                    );
                                    _fetchUserData();
                                  },
                                ),
                              ]),
                          Text(
                            "@${userData!['username']}",
                            style: TextStyle(fontSize: 15),
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildInfoCard("${userData!['age']}", "Age"),
                                _buildInfoCard(
                                    "${userData!['height']}cm", "Height"),
                                _buildInfoCard(
                                    "${userData!['weight']}kg", "Weight"),
                              ],
                            ),
                          ),
                          _buildInfoContainer(userData!['gender'], "Gender"),
                          SizedBox(height: 20),
                          _buildInfoContainer(userData!['email'], "Email"),
                        ],
                      ),
                    ),
                    // Profile Image
                    Positioned(
                      left: 0,
                      right: 0,
                      top: -80,
                      child: ValueListenableBuilder(
                        valueListenable: _imageUrl,
                        builder: (context, value, child) {
                          return CircleAvatar(
                            radius: 80,
                            backgroundColor: Colors.grey[300],
                            child: ClipOval(
                                child: Image.network(
                              value,
                              width: 160,
                              height: 160,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return
                                    //Icon(Icons.person,size: 110,color: Colors.grey,);
                                    Image.asset(
                                  'assets/images/idle_avatar.jpg', // Ensure this image is in the assets folder
                                  width: 160,
                                  height: 160,
                                  fit: BoxFit.cover,
                                );
                              },
                            )),
                          );
                        },
                      ),
                    ),

                    // Change Profile Image Button
                    Positioned(
                      top: 30,
                      left: 230,
                      child: InkWell(
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: MyColor.orange,
                          child: Icon(Icons.camera_alt, color: Colors.white),
                        ),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20)),
                            ),
                            builder: (BuildContext context) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    title: Text('Gallery'),
                                    leading: Icon(Icons.image),
                                    subtitle:
                                        Text('Select an Image from Gallery'),
                                    onTap: () =>
                                        _pickImage(ImageSource.gallery),
                                  ),
                                  ListTile(
                                    title: Text('Camera'),
                                    leading: Icon(Icons.camera_alt),
                                    subtitle: Text('Take a Photo'),
                                    onTap: () => _pickImage(ImageSource.camera),
                                  ),
                                  ListTile(
                                    title: Text('Remove'),
                                    leading:
                                        Icon(Icons.delete, color: Colors.red),
                                    subtitle:
                                        Text('Remove Current Profile Picture'),
                                    onTap: _removeImage,
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    )
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildInfoCard(String value, String label) {
    return Container(
      height: 80,
      width: 105,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 255, 170, 113),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          SizedBox(height: 15),
          Text(value, style: TextStyle(fontSize: 18, color: Colors.white)),
          Text(label, style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildInfoContainer(String value, String label) {
    return Container(
      width: 350,
      height: 80,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 255, 170, 113),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 20, color: Colors.white)),
          Text(label, style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
