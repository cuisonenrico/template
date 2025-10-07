import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';

class CounterScreen extends StatelessWidget {
  const CounterScreen({
    required this.onIncrement,
    required this.onDecrement,
    required this.onReset,
    required this.onAsyncIncrement,
    required this.onClearError,
    required this.onSetValue,
    required this.value,
    required this.isLoading,
    required this.error,
    super.key,
  });

  final int value;
  final bool isLoading;
  final String? error;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onReset;
  final VoidCallback onAsyncIncrement;
  final VoidCallback onClearError;
  final Function(int) onSetValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter Demo'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: onReset,
            tooltip: 'Reset Counter',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Counter Title
            Text('Counter Value', style: AppTheme.headingStyle),
            const SizedBox(height: AppTheme.mediumSpacing),

            // Counter Display
            Container(
              padding: const EdgeInsets.all(AppTheme.largeSpacing),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.largeRadius),
                border: Border.all(color: AppTheme.primaryColor, width: 2),
              ),
              child: Text(
                '$value',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.largeSpacing),

            // Loading Indicator
            if (isLoading) const CircularProgressIndicator(),
            const SizedBox(height: AppTheme.mediumSpacing),

            // Error Message
            if (error != null)
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppTheme.mediumSpacing,
                ),
                padding: const EdgeInsets.all(AppTheme.smallSpacing),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                  border: Border.all(color: AppTheme.errorColor),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: AppTheme.errorColor),
                    const SizedBox(width: AppTheme.smallSpacing),
                    Expanded(
                      child: Text(
                        error!,
                        style: const TextStyle(color: AppTheme.errorColor),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: onClearError,
                      color: AppTheme.errorColor,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppTheme.largeSpacing),

            // Button Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Decrement Button
                ElevatedButton.icon(
                  onPressed: isLoading ? null : onDecrement,
                  icon: const Icon(Icons.remove),
                  label: const Text('Decrement'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),

                // Increment Button
                ElevatedButton.icon(
                  onPressed: isLoading ? null : onIncrement,
                  icon: const Icon(Icons.add),
                  label: const Text('Increment'),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.mediumSpacing),

            // Async Increment Button
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.largeSpacing,
                ),
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : onAsyncIncrement,
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('Async Increment (1s delay)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.largeSpacing),

            // Value Input Section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.largeSpacing,
              ),
              child: Column(
                children: [
                  Text('Set Custom Value', style: AppTheme.subHeadingStyle),
                  const SizedBox(height: AppTheme.smallSpacing),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Enter a number',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (value) {
                            final intValue = int.tryParse(value);
                            if (intValue != null) {
                              onSetValue(intValue);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: AppTheme.smallSpacing),
                      ElevatedButton(
                        onPressed: isLoading ? null : () {},
                        child: const Text('Set'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
