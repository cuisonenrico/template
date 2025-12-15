import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_theme.dart';
import '../../core/router/app_router.dart';
import '../../features/auth/models/auth_models.dart' show User;
import '../../features/theme/widgets/theme_switcher.dart';

class AppNavigationDrawer extends StatelessWidget {
  const AppNavigationDrawer({
    required this.user,
    required this.onLogout,
    required this.onShowComingSoon,
    required this.onShowAboutDialog,
    super.key,
  });

  final User? user;
  final VoidCallback onLogout;
  final VoidCallback onShowComingSoon;
  final VoidCallback onShowAboutDialog;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            accountName: Text(
              user?.name ?? 'Welcome User',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            accountEmail: Text(
              user?.email ?? 'No email',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onPrimary.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.primary,
                size: 32,
              ),
            ),
            otherAccountsPictures: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showLogoutDialog(context, onLogout);
                },
                icon: Icon(
                  Icons.logout,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 20,
                ),
                tooltip: 'Logout',
              ),
            ],
          ),

          // Navigation Items
          _buildDrawerItem(
            context,
            icon: Icons.home,
            title: 'Home',
            subtitle: 'Main dashboard',
            onTap: () {
              Navigator.of(context).pop();
              // Already on home screen
            },
            isSelected: true,
          ),

          _buildDrawerItem(
            context,
            icon: Icons.add_circle,
            title: 'Counter Demo',
            subtitle: 'Redux state example',
            onTap: () {
              Navigator.of(context).pop();
              context.goToCounter();
            },
          ),

          _buildDrawerItem(
            context,
            icon: Icons.person,
            title: 'Profile',
            subtitle: 'User settings',
            onTap: () {
              Navigator.of(context).pop();
              onShowComingSoon();
            },
          ),

          const Divider(),

          // Settings Section
          _buildDrawerItem(
            context,
            icon: Icons.palette,
            title: 'Theme',
            subtitle: 'Appearance settings',
            trailing: const ThemeSwitcher(
              type: ThemeSwitcherType.iconButton,
              showLabel: false,
            ),
            onTap: () {
              // Theme switcher in trailing handles the action
            },
          ),

          _buildDrawerItem(
            context,
            icon: Icons.settings,
            title: 'Settings',
            subtitle: 'App preferences',
            onTap: () {
              Navigator.of(context).pop();
              onShowComingSoon();
            },
          ),

          _buildDrawerItem(
            context,
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'App information',
            onTap: () {
              Navigator.of(context).pop();
              onShowAboutDialog();
            },
          ),

          const Divider(),

          // App Info
          Padding(
            padding: const EdgeInsets.all(AppTheme.mediumSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version ${AppConstants.appVersion}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool isSelected = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            )
          : null,
      trailing: trailing,
      selected: isSelected,
      selectedTileColor: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTheme.mediumSpacing,
        vertical: 4,
      ),
      onTap: onTap,
    );
  }
}
