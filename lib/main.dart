import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spot_time/core/widgets/loading_indicators.dart';
import 'package:spot_time/feature/event/app/cubit/chat/chat_cubit.dart';
import 'package:spot_time/feature/event/app/cubit/cred/cred_cubit.dart';
import 'package:spot_time/feature/event/app/screens/splash_screen.dart';
import 'di.dart' as di;
import 'feature/event/app/cubit/auth/auth_cubit.dart';
import 'feature/event/app/cubit/event/event_cubit.dart';
import 'feature/event/app/cubit/poll/poll_cubit.dart';
import 'feature/event/app/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthCubit>()..appStarted()),
        BlocProvider(create: (_) => di.sl<CredCubit>()),
        BlocProvider(create: (_) => di.sl<EventCubit>()),
        BlocProvider(create: (_) => di.sl<ChatCubit>()),
        BlocProvider(create: (_) => di.sl<PollCubit>()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Spot Time',
        home: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              return HomeScreen(user: state.user);
            } else if (state is NotAuthenticated) {
              return const SplashScreen();
            } else if (state is AuthLoading) {
              return const LoadingIndicator();
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }
}
