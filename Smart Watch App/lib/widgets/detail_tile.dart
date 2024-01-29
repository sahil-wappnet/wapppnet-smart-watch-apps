import 'package:flutter/material.dart';

class Detailtile extends StatelessWidget {

  const Detailtile({Key? key, 
    required this.icon,
    required this.value,
    required this.valueColor,
  }) : super(key: key);

  final Icon icon;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        icon,
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}