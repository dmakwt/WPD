import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:validators/validators.dart';
import 'package:wpd_app/ui/widgets/custom_form_field.dart';
import 'package:wpd_app/ui/widgets/loader.dart';
import 'package:wpd_app/utils/app_theme.dart';
import 'package:wpd_app/view_models/auth_state_viewmodel.dart';

class LoginScreen extends HookWidget {
  LoginScreen({Key? key}) : super(key: key);

  final _key = GlobalKey<FormState>();

  String? _validateEmail(String? value) {
    if (value!.isEmpty) {
      return 'Please, type your email';
    } else if (!isEmail(value.trim())) {
      return 'Please, type valid email';
    } else {
      return null;
    }
  }

  String? _validatePassword(String? value) {
    if (value!.length < 6) {
      return 'At least 8 chars!';
    } else {
      return null;
    }
  }

  Future<void> _login(
      BuildContext context,
      AuthStateViewModel viewModel,
      TextEditingController _emailController,
      TextEditingController _passwordController) async {
    if (_key.currentState?.validate() ?? false) {
      await viewModel.login(
        context,
        _emailController.text,
        _passwordController.text,
      );
    } else {
      debugPrint('Error :(');
    }
  }

  @override
  Widget build(BuildContext context) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Form(
        key: _key,
        child: Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 120),
                    Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Image.asset(
                        'assets/logo.png',
                        height: 150,
                        width: 150,
                      ),
                    ),
                    CustomFormField(
                      controller: emailController,
                      hintText: 'Email',
                      icon: Icons.mail,
                      textInputType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    CustomFormField(
                      controller: passwordController,
                      hintText: 'Password',
                      icon: Icons.vpn_key,
                      textInputType: TextInputType.text,
                      obscureText: true,
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 30),
                    Consumer(
                      builder: (context, ref, child) {
                        final viewModel =
                            ref.watch(AuthStateViewModelProvider.provider);

                        return viewModel.isLoading
                            ? const AppLoader()
                            : SizedBox(
                                height: 50,
                                width: 120,
                                child: ElevatedButton(
                                  onPressed: () {
                                    _login(
                                      context,
                                      viewModel,
                                      emailController,
                                      passwordController,
                                    );
                                  },
                                  child: Text(
                                    'Login',
                                    style: AppTheme.lightTextTheme.headline6,
                                  ),
                                ),
                              );
                      },
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
