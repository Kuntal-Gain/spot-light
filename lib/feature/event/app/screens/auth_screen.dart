// ignore_for_file: use_build_context_synchronously

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spot_time/core/utils/validators.dart';

import '../../../../core/constants/app_color.dart';
import '../../../../core/utils/snackbar.dart';
import '../../../../core/utils/text_style.dart';
import '../../../../core/widgets/custom_button.dart';
import '../cubit/cred/cred_cubit.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // *variables here*
  bool isLogin = false;
  bool isHidden = false;
  final formKey = GlobalKey<FormState>();

  // *controllers here*
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signup() {
    // TODO: code here

    context.read<CredCubit>().register(
          name: nameController.text,
          email: emailController.text,
          password: passwordController.text,
        );
  }

  void login() {
    // TODO: code here

    context.read<CredCubit>().login(
          email: emailController.text,
          password: passwordController.text,
        );
  }

  void submit() {
    if (isLogin) {
      login();
    } else {
      signup();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CredCubit, CredState>(
      listener: (context, state) {
        // if (state is CredLoading) {
        //   loadingBar(context, "Loading....");
        // }
        if (state is CredError) {
          errorBar(context, state.message);
        }
        if (state is CredSuccess) {
          successBar(context, "Logged in as ${state.user.name}");

          Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => HomeScreen(user: state.user)));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),

                /// Title & Subtitle with fade animation
                AnimatedSwitcher(
                  duration: const Duration(seconds: 1),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                  child: Column(
                    key: ValueKey<bool>(isLogin),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLogin ? "Welcome Back 👋" : "Join SpotTime 🚀",
                        style:
                            headingStyle(size: 28, color: AppColors.secondary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isLogin
                            ? "Login to continue planning your events"
                            : "Create an account to start organizing",
                        style: bodyStyle(
                            size: 16,
                            color: AppColors.secondary.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                /// Fields with fade animation
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      key: ValueKey<bool>(isLogin),
                      children: [
                        if (!isLogin) ...[
                          TextFormField(
                            controller: nameController,
                            decoration:
                                const InputDecoration(labelText: "Name"),
                            validator: Validators.notEmpty,
                          ),
                          const SizedBox(height: 20),
                        ],
                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(labelText: "Email"),
                          validator: Validators.notEmpty,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: "Password",
                            suffixIcon: IconButton(
                              icon: Icon(
                                isHidden
                                    ? Icons.visibility_off
                                    : Icons.visibility_sharp,
                              ),
                              onPressed: () {
                                setState(() {
                                  isHidden = !isHidden;
                                });
                              },
                            ),
                          ),
                          obscureText: isHidden,
                          validator: Validators.notEmpty,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                /// Button
                CustomButton1(
                  label: isLogin ? "Login" : "Sign Up",
                  onTap: submit,
                ),

                const SizedBox(height: 20),

                /// Toggle Auth Mode
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: bodyStyle(size: 16, color: AppColors.secondary),
                      children: [
                        TextSpan(
                          text: isLogin
                              ? "Don't have an account? "
                              : "Already have an account? ",
                        ),
                        TextSpan(
                          text: isLogin ? "Sign Up" : "Login",
                          style: headingStyle(
                            size: 16,
                            color: Colors.purple,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              setState(() => isLogin = !isLogin);
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
