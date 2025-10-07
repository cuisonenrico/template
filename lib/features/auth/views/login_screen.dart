import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/router/app_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    required this.isLoading,
    required this.error,
    required this.onClearError,
    required this.onLogin,
    super.key,
  });

  final bool isLoading;
  final String? error;
  final VoidCallback onClearError;
  final Function(String email, String password) onLogin;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.mediumSpacing),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Logo or Title
                const Icon(Icons.lock, size: 80, color: AppTheme.primaryColor),
                const SizedBox(height: AppTheme.largeSpacing),
                Text(
                  'Welcome Back',
                  style: AppTheme.headingStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.extraLargeSpacing),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(AppConstants.emailRegex).hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.mediumSpacing),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < AppConstants.minPasswordLength) {
                      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.largeSpacing),

                // Error Message
                if (widget.error != null)
                  Container(
                    padding: const EdgeInsets.all(AppTheme.smallSpacing),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                      border: Border.all(color: AppTheme.errorColor),
                    ),
                    child: Text(
                      widget.error!,
                      style: const TextStyle(color: AppTheme.errorColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (widget.error != null)
                  const SizedBox(height: AppTheme.mediumSpacing),

                // Login Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: widget.isLoading ? null : () => _handleLogin(),
                    child: widget.isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.onPrimaryColor,
                            ),
                          )
                        : const Text('Login'),
                  ),
                ),
                const SizedBox(height: AppTheme.mediumSpacing),

                // Register Link
                TextButton(
                  onPressed: () {
                    context.goToRegister();
                  },
                  child: const Text(
                    'Don\'t have an account? Register here',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      widget.onClearError();
      widget.onLogin(_emailController.text.trim(), _passwordController.text);
    }
  }
}
