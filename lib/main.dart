import 'package:flutter/material.dart';

void main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "noteX",
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xfffdfaf8),
          title: Row(
            children: [
              Text(
                'note',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 30,
                  fontWeight: FontWeight.bold
                ),
              ),
              Text(
                'X',
                style: TextStyle(
                  color: Color(0xfff9c35e),
                  fontSize: 33,
                  fontWeight: FontWeight.bold
                ),
              )
            ],
          ),
          actions: [
            Padding(
              padding: EdgeInsetsGeometry.only(
                right: 20
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: Colors.black87,
                    size: 26,
                  ),
                  SizedBox(width: 7,),
                  Icon(
                    Icons.more_vert_rounded,
                    color: Colors.black87,
                    size: 26,
                  )
                ],
              ),
            )
          ],
        ),
        backgroundColor: Color(0xfffdfaf8),
        body: Center(
          child: Text(
            "noteX",
            style: TextStyle(
              color: Colors.yellow,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
