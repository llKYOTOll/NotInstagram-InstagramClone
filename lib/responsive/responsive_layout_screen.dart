import 'package:flutter/material.dart';
import 'package:not_instagram/providers/user_provider.dart';
import 'package:not_instagram/utils/global_variables.dart';
import 'package:provider/provider.dart';

class ResponsiveLayout extends StatefulWidget {
  const ResponsiveLayout({Key? key, required this.webScreenLayout, required this.mobileScreenLayout}) : super(key: key);

  final Widget webScreenLayout;
  final Widget mobileScreenLayout;

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
  @override
  void initState() {
    // TODO: implement initState
    addData();
    super.initState();
  }

  addData() async {
    UserProvider _userProvider = Provider.of(context, listen: false);
    await _userProvider.refreshUser();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints){
        if(constraints.maxWidth>webScreenSize){
          //web Screen layout
          return widget.webScreenLayout;
        }
        //mobile screen
        return widget.mobileScreenLayout;
      },
    );
  }
}