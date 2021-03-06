import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:not_instagram/providers/user_provider.dart';
import 'package:not_instagram/resources/auth_methods.dart';
import 'package:not_instagram/responsive/mainframe.dart';
import 'package:not_instagram/screens/login_screen.dart';
import 'package:not_instagram/utils/global_variables.dart';
import 'package:not_instagram/utils/utils.dart';
import 'package:not_instagram/widgets/customTextField.dart';
import 'package:provider/provider.dart';

import '../constants/layout_constraints.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailTEC = TextEditingController();
  final TextEditingController passwordTEC = TextEditingController();
  final TextEditingController bioTEC = TextEditingController();
  final TextEditingController usernameTEC = TextEditingController();
  Uint8List? _image;
  bool _isLoading = false;

  @override
  void dispose() {
    emailTEC.dispose();
    passwordTEC.dispose();
    bioTEC.dispose();
    usernameTEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: getHeight(context),
        width: getWidth(context),
        child: Stack(
          children: [
            SizedBox(
              height: getHeight(context),
              width: getWidth(context),
              child: Image.asset(
                'assets/signup_bg.png',
                fit: BoxFit.cover,
              ),
            ),
            Container(
              height: getHeight(context),
              width: getWidth(context),
              color: Colors.black.withOpacity(.75),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * .15,
                          ),
                          Text(
                            '!instagram',
                            style: AppTitleTextStyle.copyWith(fontSize: 30),
                          ),
                          Text(
                            "It's !instagram and it's better.",
                            style: subHeaderNotHighlightedTextStyle.copyWith(height: .8, fontSize: 13),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Row(
                            children: [
                             Stack(
                                children: [
                                  _image != null
                                      ? CircleAvatar(
                                          radius: 40,
                                          backgroundImage: MemoryImage(_image!),
                                        )
                                      : CircleAvatar(
                                          radius: 40,
                                          backgroundColor: backgroundColor,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(40),
                                            child: Image.asset(
                                              'assets/defaultProPic.png',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                  Positioned(
                                    bottom: -15,
                                    left: 40,
                                    child: IconButton(
                                      onPressed: () async {
                                        Uint8List? image = await pickImage(
                                            ImageSource.gallery);
                                        if (image != null) {
                                          setState(() {
                                            _image = image;
                                          });
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.add_a_photo,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Text(
                                'Create a \nnew account',
                                style: AppTitleTextStyle.copyWith(fontSize: 25),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          getTextField(
                            textEditingController: usernameTEC,
                            hintText: 'Username',
                            textInputType: TextInputType.emailAddress,
                            maxLines: 1,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          getTextField(
                            textEditingController: emailTEC,
                            hintText: 'Email',
                            textInputType: TextInputType.emailAddress,
                            maxLines: 1,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          getTextField(
                            textEditingController: passwordTEC,
                            hintText: 'Password',
                            textInputType: TextInputType.emailAddress,
                            maxLines: 1,
                            isPass: true,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          getTextField(
                            textEditingController: bioTEC,
                            hintText: 'Bio',
                            textInputType: TextInputType.text,
                            maxLines: 3,
                            isPass: false,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          _isLoading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                )
                              : SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      if (_image != null &&
                                          emailTEC.text.isNotEmpty &&
                                          passwordTEC.text.isNotEmpty &&
                                          usernameTEC.text.isNotEmpty &&
                                          bioTEC.text.isNotEmpty) {
                                        String res =
                                            await AuthMethods().signUpUser(
                                          email: emailTEC.text,
                                          password: passwordTEC.text,
                                          userName: usernameTEC.text,
                                          bio: bioTEC.text,
                                          file: _image!,
                                        );
                                        if (res == 'success') {
                                          await Provider.of<UserProvider>(
                                                  context,
                                                  listen: false)
                                              .refreshUser();
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const MainFrame()),
                                          );
                                        }
                                      } else {
                                        showSnackbar(context, "Invalid input.");
                                      }
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    },
                                    child: Text(
                                      'Sign up',
                                      style: headerTextStyle,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                        primary:
                                            Theme.of(context).primaryColor),
                                  ),
                                ),

                          const SizedBox(
                            height: 30,
                          ),
                          Text(
                            "Already have an account? ",
                            style: subHeaderNotHighlightedTextStyle,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Login',
                              style: subHeaderTextStyle.copyWith(fontSize: 20),
                            ),
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              height: 125,
              width: getWidth(context),
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
