import 'package:flutter/material.dart';

class RoundedIconButton extends StatelessWidget {
  RoundedIconButton(this.title, this.color, this.onPressed, this.icon);

  final Color color;
  final String title;
  final VoidCallback onPressed;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: color,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: onPressed,
          minWidth: 200.0,
          height: 42.0,
          child: Column(
            children: [
              icon,
              Text(
                title,
                style: TextStyle(
                  color: Color(0xFF0A0E21),
                  fontSize: 25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
