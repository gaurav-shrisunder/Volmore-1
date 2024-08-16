

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



AppBar simpleAppBar(BuildContext context, String title){

  return AppBar(
   centerTitle: false,
    title: title != "" ? Text(title): null,
    leading: IconButton(onPressed: (){
      Navigator.pop(context);
    }, icon: const Icon(CupertinoIcons.chevron_left)),
  //  backgroundColor: Colors.white,
  );
}

class AppbarTitleWidget extends StatelessWidget {
  const AppbarTitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(onPressed: (){
        Navigator.pop(context);
      }, icon: const Icon(CupertinoIcons.chevron_left)),
      backgroundColor: Colors.white,);
  }
}
