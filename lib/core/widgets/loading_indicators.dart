import 'package:flutter/cupertino.dart';
import 'package:spot_time/core/constants/app_color.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      backgroundColor: AppColors.primary,
      child: Center(
        child: CupertinoActivityIndicator(
          radius: 20,
          color: AppColors.secondary,
        ),
      ),
    );
  }
}
