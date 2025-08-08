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

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _obscureText = ValueNotifier(true);

  void _onRegisterSubmitted() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      SnackbarUtil.showError(context, 'Please fill all fields');
      return;
    }

    if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email)) {
      SnackbarUtil.showError(context, 'Invalid email format');
      return;
    }

    if (password.length < 8) {
      SnackbarUtil.showError(context, 'Password must be at least 8 characters');
      return;
    }

    context.read<AuthBloc>().add(
      RegisterSubmittedEvent(name: name, email: email, password: password),
    );
  }

  void _onListenToAuthState(BuildContext context, AuthState state) {
    if (state is AuthFailed) {
      SnackbarUtil.showError(context, state.message);
    }
    if (state is RegistrationSuccess) {
      SnackbarUtil.showSuccess(context, 'Registration successful!');
      context.go('/login');
    }
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
                          'Create your account first!',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const Gap(24),
                        AuthInput(
                          controller: _nameController,
                          hint: 'your name',
                          prefix: UnconstrainedBox(
                            child: ImageIcon(
                              AssetImage(AppAssets.icons.name),
                              size: 20,
                            ),
                          ),
                        ),
                        const Gap(12),
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
                        const Gap(20),
                        BlocConsumer<AuthBloc, AuthState>(
                          listener: _onListenToAuthState,
                          builder: (context, state) {
                            if (state is AuthLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            return CustomFilledButton(
                              text: 'Register',
                              onPressed: _onRegisterSubmitted,
                              height: 46,
                            );
                          },
                        ),
                        const Gap(20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account?',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: Colors.black45,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.go('/login'),
                              child: const Text('Login'),
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _obscureText.dispose();
    super.dispose();
  }
}
