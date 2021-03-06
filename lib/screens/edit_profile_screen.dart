import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:not_instagram/model/user.dart' as model;
import 'package:not_instagram/providers/user_provider.dart';
import 'package:not_instagram/resources/storage_methods.dart';
import 'package:not_instagram/screens/login_screen.dart';
import 'package:not_instagram/utils/global_variables.dart';
import 'package:not_instagram/utils/utils.dart';
import 'package:not_instagram/widgets/customTextField.dart';
import 'package:provider/provider.dart';

import '../constants/layout_constraints.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _bioTextController = TextEditingController();
  final TextEditingController _userNameTextController = TextEditingController();
  Uint8List? _image;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailTextController.dispose();
    _bioTextController.dispose();
    _userNameTextController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  late model.UserModel _user;
  void getData() {
    _user = Provider.of<UserProvider>(context, listen: false).user;
    _emailTextController.text = _user.email;
    _bioTextController.text = _user.bio;
    _userNameTextController.text = _user.userName;
    _emailTextController.text = _user.email;
  }

  bool showLoading = false;

  bool hasProfilePicturebeenChanged = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,
        title: Text(
          'Edit profile.',
          style: headerTextStyle.copyWith(fontSize: 20),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.close,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              setState(() {
                showLoading = true;
              });

              if (hasProfilePicturebeenChanged) {
                String newProfilePictureImageLink = await StorageMethods()
                    .uploadImageToStorage(
                        childName: 'profilePics', file: _image!, isPost: false);

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(_user.userId)
                    .update({
                      'username': _userNameTextController.text,
                      'photoUrl': newProfilePictureImageLink,
                      'bio': _bioTextController.text,
                    })
                    .then((value) => print('updated'))
                    .catchError((error) => print('Update failed: $error'));

                await Provider.of<UserProvider>(context, listen: false)
                    .refreshUser();

                var temp = await FirebaseFirestore.instance
                    .collection('posts')
                    .where('uid', isEqualTo: _user.userId)
                    .get();
                _user = Provider.of<UserProvider>(context, listen: false).user;

                print(newProfilePictureImageLink);
                for (int i = 0; i < temp.size; i++) {
                  await FirebaseFirestore.instance
                      .collection('posts')
                      .doc(temp.docs[i]['postId'])
                      .update({
                    'username': _user.userName,
                    'profilePhotoUrl': newProfilePictureImageLink
                  });
                }

                print(newProfilePictureImageLink);
                var temp2 = await FirebaseFirestore.instance
                    .collection('stories')
                    .where('uid', isEqualTo: _user.userId)
                    .get();
                for (int i = 0; i < temp2.size; i++) {
                  await FirebaseFirestore.instance
                      .collection('stories')
                      .doc(temp2.docs[i]['postId'])
                      .update({
                    'username': _user.userName,
                    'profilePhotoUrl': newProfilePictureImageLink
                  });
                }

                Navigator.of(context).pop();
              } else {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(_user.userId)
                    .update({
                      'username': _userNameTextController.text,
                      'bio': _bioTextController.text,
                    })
                    .then((value) => print('updated'))
                    .catchError((error) => print('Update failed: $error'));

                await Provider.of<UserProvider>(context, listen: false)
                    .refreshUser();

                var temp = await FirebaseFirestore.instance
                    .collection('posts')
                    .where('uid', isEqualTo: _user.userId)
                    .get();
                _user = Provider.of<UserProvider>(context, listen: false).user;

                for (int i = 0; i < temp.size; i++) {
                  await FirebaseFirestore.instance
                      .collection('posts')
                      .doc(temp.docs[i]['postId'])
                      .update({'username': _user.userName});
                }

                Navigator.of(context).pop();
              }
            },
            icon: Icon(
              Icons.check,
              color: Colors.pink,
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      body: Stack(
        children: [

          Container(
            height: getHeight(context),
            width: getWidth(context),
            child: Image.asset(
              'assets/edit_profile_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            height: getHeight(context),
            width: getWidth(context),
            color: Colors.black.withOpacity(.85),
          ),

          Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                showLoading
                    ? LinearProgressIndicator(
                        color: Colors.pink,
                        minHeight: 1,
                      )
                    : Container(),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 25,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            alignment: Alignment.center,
                            child: Stack(
                              children: [
                                hasProfilePicturebeenChanged
                                    ? CircleAvatar(
                                        radius: 60,
                                        backgroundImage: MemoryImage(_image!),
                                      )
                                    : CircleAvatar(
                                        radius: 60,
                                        backgroundColor: backgroundColor,
                                        backgroundImage:
                                            NetworkImage(_user.photoUrl),
                                      ),
                                Positioned(
                                  bottom: -15,
                                  left: 80,
                                  child: IconButton(
                                    onPressed: () async {
                                      Uint8List? image =
                                          await pickImage(ImageSource.gallery);
                                      if (image != null) {
                                        setState(() {
                                          _image = image;
                                          hasProfilePicturebeenChanged = true;
                                        });
                                      }
                                    },
                                    icon: Icon(
                                      Icons.add_a_photo,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          // SizedBox(
                          //   height: 15,
                          // ),
                          // Container(
                          //   width: MediaQuery.of(context).size.width,
                          //   alignment: Alignment.center,
                          //   child: Text(
                          //     'Change profile picture',
                          //     style: headerTextStyle.copyWith(color: Colors.pink),
                          //   ),
                          // ),
                          SizedBox(
                            height: 25,
                          ),
                          getTextField(
                              textEditingController: _userNameTextController,
                              maxLines: 1,
                              hintText: 'Enter your user name here.',
                              textInputType: TextInputType.emailAddress),
                          SizedBox(
                            height: 10,
                          ),
                          getTextField(
                              textEditingController: _emailTextController,
                              maxLines: 1,
                              hintText: 'Enter your email here.',
                              textInputType: TextInputType.emailAddress),
                          SizedBox(
                            height: 10,
                          ),
                          getTextField(
                              textEditingController: _bioTextController,
                              hintText: 'Enter your bio here.',
                              maxLines: 4,
                              textInputType: TextInputType.emailAddress),
                          SizedBox(
                            height: 10,
                          ),
                          // _isLoading
                          //     ? CircularProgressIndicator(
                          //         color: Theme.of(context).primaryColor,
                          //       )
                          //     : Container(
                          //         width: MediaQuery.of(context).size.width,
                          //         child: ElevatedButton(
                          //           onPressed: () async {
                          //             // setState(() {
                          //             //   _isLoading = true;
                          //             // });
                          //             // if (_image != null &&
                          //             //     _emailTextController.text.isNotEmpty &&
                          //             //     _passwordTextController.text.isNotEmpty &&
                          //             //     _userNameTextController.text.isNotEmpty &&
                          //             //     _bioTextController.text.isNotEmpty) {
                          //             //   String res = await AuthMethods().signUpUser(
                          //             //     email: _emailTextController.text,
                          //             //     password: _passwordTextController.text,
                          //             //     userName: _userNameTextController.text,
                          //             //     bio: _bioTextController.text,
                          //             //     file: _image!,
                          //             //   );
                          //             //   if (res == 'success') {
                          //             //     await Provider.of<UserProvider>(context,
                          //             //             listen: false)
                          //             //         .refreshUser();
                          //             //     Navigator.of(context).pushReplacement(
                          //             //       MaterialPageRoute(
                          //             //         builder: (context) =>
                          //             //             ResponsiveLayout(
                          //             //           mobileScreenLayout:
                          //             //               MobileScreenLayout(),
                          //             //           webScreenLayout: WebScreenLayout(),
                          //             //         ),
                          //             //       ),
                          //             //     );
                          //             //   }
                          //             // } else {
                          //             //   showSnackbar(context, "Invalid input.");
                          //             // }
                          //             // setState(() {
                          //             //   _isLoading = false;
                          //             // });
                          //           },
                          //           child: Text('Save'),
                          //           style: ElevatedButton.styleFrom(
                          //               primary: Theme.of(context).primaryColor),
                          //         ),
                          //       ),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    child: Text(
                      'Switch to a different user.',
                      style: headerTextStyle.copyWith(color: Colors.pink),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
