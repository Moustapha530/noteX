import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final actions = [
    {
      'bg_color': Color(0x17f5b839),
      'color': Color(0xfff5b839),
      'text': 'Nouvelle note',
      'icon': Icons.note_add_outlined
    },
    {
      'bg_color': Color(0x17759b4a),
      'color': Color(0xff759b4a),
      'text': 'Checklist',
      'icon': Icons.check_box_outlined
    },
    {
      'bg_color': Color(0x178c7ad5),
      'color': Color(0xff8c7ad5),
      'text': 'Image note',
      'icon': Icons.image_outlined
    },
    {
      'bg_color': Color(0x174894b5),
      'color': Color(0xff4894b5),
      'text': 'Note vocal',
      'icon': Icons.image_outlined
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 95,
          child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    width: 110,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: actions[index]['bg_color'] as Color),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          actions[index]['icon'] as IconData,
                          color: actions[index]['color'] as Color,
                          size: 30,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          actions[index]['text'] as String,
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: 10,
                              fontWeight: FontWeight.w400),
                        )
                      ],
                    ),
                  ),
              separatorBuilder: (context, index) => SizedBox(
                    width: 10,
                  ),
              itemCount: actions.length),
        )
      ],
    );
  }
}
