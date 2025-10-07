import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/router/app_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    required this.isLoading,
    required this.error,
    required this.onClearError,
    required this.onRegister,
    super.key,
  });

  final bool isLoading;
  final String? error;
  final VoidCallback onClearError;
  final Function(String name, String email, String password) onRegister;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.mediumSpacing),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Logo or Title
                const Icon(
                  Icons.person_add,
                  size: 80,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: AppTheme.largeSpacing),
                Text(
                  'Join ${AppConstants.appName}',
                  style: AppTheme.headingStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.extraLargeSpacing),

                // Name Field
                TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.mediumSpacing),

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
                const SizedBox(height: AppTheme.mediumSpacing),

                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
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

                // Register Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: widget.isLoading
                        ? null
                        : () => _handleRegister(),
                    child: widget.isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.onPrimaryColor,
                            ),
                          )
                        : const Text('Create Account'),
                  ),
                ),
                const SizedBox(height: AppTheme.mediumSpacing),

                // Login Link
                TextButton(
                  onPressed: () {
                    context.goToLogin();
                  },
                  child: const Text('Already have an account? Sign in'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      widget.onClearError();
      widget.onRegister(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }
}
