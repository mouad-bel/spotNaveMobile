import 'package:spotnav/common/app_assets.dart';
import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/common/app_constants.dart';
import 'package:spotnav/common/blocs/auth/auth_bloc.dart';
import 'package:spotnav/common/utils/snackbar_util.dart';
import 'package:spotnav/common/widgets/custom_filled_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'auth_input.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _obscureText = ValueNotifier(true);
  final _rememberMe = ValueNotifier(true);

  void _onLoginSubmitted() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      SnackbarUtil.showError(context, 'Please fill in all fields.');
      return;
    }

    if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email)) {
      SnackbarUtil.showError(context, 'Please enter a valid email address.');
      return;
    }

    if (password.length < 8) {
      SnackbarUtil.showError(
        context,
        'Password must be at least 8 characters.',
      );
      return;
    }

    context.read<AuthBloc>().add(
      LoginSubmittedEvent(email: email, password: password),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.background],
              ),
            ),
          ),
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  constraints: BoxConstraints(
                    maxHeight: constraints.maxHeight * 0.8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 10,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Gap(30),
                        Image.asset(
                          AppConstants.appLogo,
                          width: 100,
                          height: 100,
                        ),
                        const Gap(20),
                        const Text(
                          AppConstants.appName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                        ),
                        const Gap(12),
                        const Text(
                          'Enter your account to login!',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const Gap(24),
                        AuthInput(
                          controller: _emailController,
                          hint: 'youremail@mail.com',
                          prefix: UnconstrainedBox(
                            child: ImageIcon(
                              AssetImage(AppAssets.icons.email),
                              size: 20,
                            ),
                          ),
                        ),
                        const Gap(12),
                        ValueListenableBuilder(
                          valueListenable: _obscureText,
                          builder: (_, obscure, _) {
                            return AuthInput(
                              controller: _passwordController,
                              hint: 'xxxxxx',
                              obscureText: obscure,
                              prefix: UnconstrainedBox(
                                child: ImageIcon(
                                  AssetImage(AppAssets.icons.password),
                                  size: 20,
                                ),
                              ),
                              suffix: IconButton(
                                onPressed: () => _obscureText.value = !obscure,
                                icon: ImageIcon(
                                  AssetImage(
                                    obscure
                                        ? AppAssets.icons.visibility.inactive
                                        : AppAssets.icons.visibility.active,
                                  ),
                                  size: 20,
                                ),
                              ),
                            );
                          },
                        ),
                        const Gap(16),
                        Row(
                          children: [
                            ValueListenableBuilder(
                              valueListenable: _rememberMe,
                              builder: (_, isRemember, _) {
                                return Checkbox(
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: const VisualDensity(
                                    horizontal: -4,
                                    vertical: -4,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  side: const BorderSide(
                                    color: AppColors.textSecondary,
                                    width: 1.5,
                                  ),
                                  value: isRemember,
                                  onChanged: (value) {
                                    _rememberMe.value = value ?? false;
                                  },
                                );
                              },
                            ),
                            const Gap(8),
                            const Text(
                              'Remember me',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: Colors.black45,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {},
                              style: const ButtonStyle(
                                visualDensity: VisualDensity(vertical: -4),
                                padding: WidgetStatePropertyAll(
                                  EdgeInsets.all(0),
                                ),
                              ),
                              child: const Text('Forgot Password?'),
                            ),
                          ],
                        ),
                        const Gap(20),
                        BlocConsumer<AuthBloc, AuthState>(
                          listener: (context, state) {
                            if (state is AuthFailed) {
                              SnackbarUtil.showError(context, state.message);
                            }
                          },
                          builder: (context, state) {
                            if (state is AuthLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            return CustomFilledButton(
                              text: 'Login',
                              onPressed: _onLoginSubmitted,
                            );
                          },
                        ),
                        const Gap(20),
                        const Row(
                          children: [
                            Expanded(child: Divider(color: AppColors.textThin)),
                            Gap(12),
                            Text(
                              'or login via',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: Colors.black45,
                              ),
                            ),
                            Gap(12),
                            Expanded(child: Divider(color: AppColors.textThin)),
                          ],
                        ),
                        const Gap(20),
                        Row(
                          spacing: 24,
                          children: AppAssets.images.loginMethods.map((e) {
                            return Expanded(
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.center,
                                child: Image.asset(e, height: 24),
                              ),
                            );
                          }).toList(),
                        ),
                        const Gap(20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Don\'t have an account?',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: Colors.black45,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.go('/register'),
                              child: const Text('Register'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _obscureText.dispose();
    _rememberMe.dispose();
    super.dispose();
  }
}
