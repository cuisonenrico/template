import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final Color? color;

  const LoadingWidget({super.key, this.message, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? AppTheme.primaryColor,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppTheme.mediumSpacing),
            Text(
              message!,
              style: AppTheme.bodyStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool isOutlined;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon ?? Icons.arrow_forward),
        label: Text(text),
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor ?? AppTheme.primaryColor,
          side: BorderSide(color: backgroundColor ?? AppTheme.primaryColor),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Icon(icon ?? Icons.arrow_forward),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppTheme.primaryColor,
        foregroundColor: textColor ?? Colors.white,
      ),
    );
  }
}

class ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorWidget({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.mediumSpacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: AppTheme.mediumSpacing),
            Text('Something went wrong', style: AppTheme.headingStyle),
            const SizedBox(height: AppTheme.smallSpacing),
            Text(
              message,
              style: AppTheme.bodyStyle,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppTheme.largeSpacing),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
