import 'package:flutter/material.dart';
import 'package:note_x/pages/favorite.dart';
import 'package:note_x/pages/home.dart';
import 'package:note_x/pages/recycle.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  int _currentPageIndex = 0;
  void setCurrentPageIndex(int index){
    if(index >= 0 && index < 3){
      setState(() {
        _currentPageIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'noteX',
      home: Scaffold(
        body: [
          HomePage(),
          FavoritesPage(),
          RecyclePage()
        ][_currentPageIndex],
        bottomNavigationBar: _navBar(),
      ),
    );
  }

  Widget _navBar(){
    return Container(
      decoration: BoxDecoration(
          color: Color(0xfffcf6ec),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                spreadRadius: 5
            )
          ]
      ),
      child: BottomNavigationBar(
        currentIndex: _currentPageIndex,
        onTap: (index) => setCurrentPageIndex(index),
        selectedItemColor: Color(0xfff7a307),
        unselectedItemColor: Color(0xff595a5c),
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home_outlined,
                size: 18,
              ),
              label: 'Accueil'
          ),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.star_border_outlined,
                size: 18,
              ),
              label: 'Favoris'
          ),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.delete_outline,
                size: 18,
              ),
              label: 'Corbeille'
          )
        ],
      ),
    );
  }
}

