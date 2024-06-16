import 'package:flutter/material.dart';

class DefaultLayout extends StatelessWidget {
  final Color? backgroundColor;
  final Widget child;
  final String? title;
  final Widget? bottomNavigationBar;

  const DefaultLayout({
    required this.child,
    this.backgroundColor,
    this.title,
    this.bottomNavigationBar,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Colors.white,
      //backgroundColor가 null이면 하얀색으로 적용한다!
      appBar: renderAppBar(),
      body: child,
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  AppBar? renderAppBar(){
    if(title==null){
      return null;
    }else{
      return AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text(
          title!,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
  }
}
