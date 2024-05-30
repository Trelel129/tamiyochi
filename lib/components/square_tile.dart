import 'package:flutter/material.dart';

class SquareTile extends StatelessWidget {
  final String imagePath;
  final bool online;
  const SquareTile({
    super.key,
    required this.online,
    required this.imagePath
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
        ),
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[200],
      ),
      child: online ? (Image.network(imagePath,height: 40,))
          : Image.asset(imagePath,height: 40,),
    );
  }
}