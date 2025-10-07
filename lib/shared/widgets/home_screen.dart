import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_theme.dart';
import '../../core/router/app_router.dart';
import '../../features/auth/models/auth_models.dart' show User;
import '../../features/theme/widgets/theme_switcher.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.user, required this.onLogout, super.key});

  final User? user;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        centerTitle: true,
        actions: [
          const ThemeSwitcher(
            type: ThemeSwitcherType.iconButton,
            showLabel: false,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  // Profile route not implemented in GoRouter yet
                  break;
                case 'logout':
                  _showLogoutDialog(context, onLogout);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.mediumSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.mediumSpacing),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: AppTheme.primaryColor,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: AppTheme.onPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: AppTheme.mediumSpacing),
                    Text('Welcome back!', style: AppTheme.headingStyle),
                    if (user?.name != null) ...[
                      const SizedBox(height: AppTheme.smallSpacing),
                      Text(user!.name!, style: AppTheme.subHeadingStyle),
                    ],
                    if (user?.email != null) ...[
                      const SizedBox(height: AppTheme.smallSpacing),
                      Text(
                        user!.email,
                        style: AppTheme.bodyStyle.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.largeSpacing),

            // Features Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: AppTheme.mediumSpacing,
                mainAxisSpacing: AppTheme.mediumSpacing,
                children: [
                  _buildFeatureCard(
                    context,
                    'Counter Demo',
                    Icons.add_circle,
                    'Try the counter with Redux',
                    () => context.goToCounter(),
                  ),
                  _buildFeatureCard(
                    context,
                    'Profile',
                    Icons.person,
                    'View your profile',
                    () => _showComingSoon(
                      context,
                    ), // Profile route not implemented yet
                  ),
                  _buildFeatureCard(
                    context,
                    'Settings',
                    Icons.settings,
                    'App preferences',
                    () => _showComingSoon(context),
                  ),
                  _buildFeatureCard(
                    context,
                    'About',
                    Icons.info,
                    'About this template',
                    () => _showAboutDialog(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.mediumSpacing),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: AppTheme.primaryColor),
              const SizedBox(height: AppTheme.mediumSpacing),
              Text(
                title,
                style: AppTheme.subHeadingStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.smallSpacing),
              Text(
                subtitle,
                style: AppTheme.bodyStyle.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, VoidCallback onLogout) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              onLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming Soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationLegalese: '© 2024 Flutter Template',
      children: [
        const SizedBox(height: 16),
        const Text(
          'This is a Flutter template with authentication, '
          'MVC architecture, and Async Redux state management.',
        ),
      ],
    );
  }
}
