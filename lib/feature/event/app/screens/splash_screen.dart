import 'package:flutter/material.dart';
import 'package:spot_time/core/constants/app_color.dart';
import 'package:spot_time/core/utils/size_box.dart';
import 'package:spot_time/core/utils/text_style.dart';
import 'package:spot_time/core/widgets/custom_button.dart';

import 'auth_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Image.asset('assets/banner.png'),
          Column(
            children: [
              Image.asset('assets/splash.jpg'),
              Text(
                'Where timing meets memories.',
                style: subHeadingStyle(
                  color: AppColors.secondary,
                  size: 18,
                ),
                textAlign: TextAlign.center,
              )
            ],
          ),
          sizeVar(20),
          CustomButton1(
            label: 'Get Started',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AuthScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
