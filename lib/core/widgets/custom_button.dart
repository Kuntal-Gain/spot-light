import 'package:flutter/material.dart';
import '../constants/app_color.dart';
import '../utils/text_style.dart';

class CustomButton1 extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const CustomButton1({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  State<CustomButton1> createState() => _CustomButton1State();
}

class _CustomButton1State extends State<CustomButton1> {
  bool _isPressed = false;

  void _onTapDown(_) {
    setState(() => _isPressed = true);
  }

  void _onTapUp(_) {
    setState(() => _isPressed = false);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(
          _isPressed ? 9 : 0,
          _isPressed ? 9 : 0,
          0,
        ),
        height: 70,
        width: double.infinity,
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: AppColors.primary,
          border: Border.all(color: AppColors.secondary, width: 2.5),
          boxShadow: _isPressed
              ? [] // when pressed, no shadow
              : [
                  const BoxShadow(
                    color: AppColors.secondary,
                    spreadRadius: 5,
                    offset: Offset(9, 9),
                  ),
                ],
        ),
        child: Center(
          child: Text(
            widget.label,
            style: headingStyle(
              color: AppColors.secondary,
              size: 16,
            ),
          ),
        ),
      ),
    );
  }
}
