import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_theme.dart';
import '../../core/router/app_router.dart';
import '../../core/services/connectivity_service.dart';
import '../../features/auth/models/auth_models.dart' show User;
import '../../features/theme/widgets/theme_switcher.dart';
import 'app_navigation_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.user, required this.onLogout, super.key});

  final User? user;
  final VoidCallback onLogout;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, ConnectivityAware {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    // Simulate refresh delay
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isRefreshing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✓ Data refreshed'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;
    final colorScheme = Theme.of(context).colorScheme;

    return ConnectivityBanner(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppConstants.appName),
          centerTitle: true,
          automaticallyImplyLeading: !isWideScreen,
          actions: [
            const ThemeSwitcher(
              type: ThemeSwitcherType.iconButton,
              showLabel: false,
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'profile':
                    _showComingSoon(context);
                    break;
                  case 'logout':
                    _showLogoutDialog(context, widget.onLogout);
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(Icons.person, color: colorScheme.onSurface),
                      const SizedBox(width: 8),
                      const Text('Profile'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: colorScheme.error),
                      const SizedBox(width: 8),
                      Text('Logout', style: TextStyle(color: colorScheme.error)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        drawer: isWideScreen
            ? null
            : AppNavigationDrawer(
                user: widget.user,
                onLogout: widget.onLogout,
                onShowComingSoon: () => _showComingSoon(context),
                onShowAboutDialog: () => _showAboutDialog(context),
              ),
        body: isWideScreen
            ? Row(
                children: [
                  _buildNavigationRail(context),
                  const VerticalDivider(width: 1),
                  Expanded(child: _buildMainContent(context)),
                ],
              )
            : _buildMainContent(context),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppTheme.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome Hero Card
                _buildWelcomeCard(context),
                const SizedBox(height: AppTheme.space24),

                // Quick Stats Row
                _buildQuickStats(context),
                const SizedBox(height: AppTheme.space24),

                // Template Features Section
                _buildSectionHeader(context, 'Template Features', Icons.star),
                const SizedBox(height: AppTheme.space12),
                _buildFeatureShowcase(context),
                const SizedBox(height: AppTheme.space24),

                // Quick Actions Section
                _buildSectionHeader(context, 'Quick Actions', Icons.bolt),
                const SizedBox(height: AppTheme.space12),
                _buildQuickActions(context),
                const SizedBox(height: AppTheme.space24),

                // Built-in Utilities Section
                _buildSectionHeader(context, 'Built-in Utilities', Icons.build),
                const SizedBox(height: AppTheme.space12),
                _buildUtilitiesGrid(context),
                const SizedBox(height: AppTheme.space32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = widget.user;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space24),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.onPrimary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.onPrimary.withValues(alpha: 0.5),
                  width: 3,
                ),
              ),
              child: Icon(
                Icons.person,
                size: 40,
                color: colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: AppTheme.space20),
            // Welcome Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back!',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onPrimary.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.name ?? 'Developer',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  if (user?.email != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      user!.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Connectivity indicator
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.space12,
                vertical: AppTheme.space8,
              ),
              decoration: BoxDecoration(
                color: colorScheme.onPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isOnline ? Icons.wifi : Icons.wifi_off,
                    size: 16,
                    color: colorScheme.onPrimary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.architecture,
            value: 'MVC',
            label: 'Architecture',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: AppTheme.space12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.storage,
            value: 'Redux',
            label: 'State Mgmt',
            color: Colors.purple,
          ),
        ),
        const SizedBox(width: AppTheme.space12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.security,
            value: 'OAuth',
            label: 'Auth System',
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: AppTheme.space8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.space8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 20),
        ),
        const SizedBox(width: AppTheme.space12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureShowcase(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppTheme.space12,
      mainAxisSpacing: AppTheme.space12,
      childAspectRatio: 1.1,
      children: [
        _buildFeatureCard(
          context,
          title: 'Counter Demo',
          subtitle: 'Redux State Example',
          icon: Icons.add_circle_outline,
          color: Colors.blue,
          onTap: () => context.goToCounter(),
        ),
        _buildFeatureCard(
          context,
          title: 'Profile',
          subtitle: 'User Management',
          icon: Icons.person_outline,
          color: Colors.indigo,
          onTap: () => _showComingSoon(context),
        ),
        _buildFeatureCard(
          context,
          title: 'Settings',
          subtitle: 'App Preferences',
          icon: Icons.settings_outlined,
          color: Colors.grey,
          onTap: () => _showComingSoon(context),
        ),
        _buildFeatureCard(
          context,
          title: 'About',
          subtitle: 'Template Info',
          icon: Icons.info_outline,
          color: Colors.teal,
          onTap: () => _showAboutDialog(context),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.space16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.space12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: AppTheme.space12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppTheme.space16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickActionButton(
            context,
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            onTap: () => _showComingSoon(context),
          ),
          _buildQuickActionButton(
            context,
            icon: Icons.analytics_outlined,
            label: 'Analytics',
            onTap: () => _showComingSoon(context),
          ),
          _buildQuickActionButton(
            context,
            icon: Icons.cloud_sync_outlined,
            label: 'Sync',
            onTap: () => _handleRefresh(),
          ),
          _buildQuickActionButton(
            context,
            icon: Icons.help_outline,
            label: 'Help',
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.space12),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: colorScheme.primary),
            ),
            const SizedBox(height: AppTheme.space8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUtilitiesGrid(BuildContext context) {
    final utilities = [
      _UtilityItem(
        icon: Icons.wifi_tethering,
        title: 'Connectivity',
        description: 'Auto offline/online detection',
      ),
      _UtilityItem(
        icon: Icons.check_circle_outline,
        title: 'Validators',
        description: '20+ form validation rules',
      ),
      _UtilityItem(
        icon: Icons.error_outline,
        title: 'Error Boundary',
        description: 'Global error handling',
      ),
      _UtilityItem(
        icon: Icons.image_outlined,
        title: 'Image Utils',
        description: 'Pick, compress, cache',
      ),
      _UtilityItem(
        icon: Icons.refresh,
        title: 'Pull to Refresh',
        description: 'Easy refresh pattern',
      ),
      _UtilityItem(
        icon: Icons.format_list_numbered,
        title: 'Pagination',
        description: 'Infinite scroll ready',
      ),
      _UtilityItem(
        icon: Icons.analytics_outlined,
        title: 'Analytics',
        description: 'Pluggable provider system',
      ),
      _UtilityItem(
        icon: Icons.language,
        title: 'Localization',
        description: 'i18n with EN/ES',
      ),
    ];

    return Wrap(
      spacing: AppTheme.space8,
      runSpacing: AppTheme.space8,
      children: utilities.map((utility) {
        return _buildUtilityChip(context, utility);
      }).toList(),
    );
  }

  Widget _buildUtilityChip(BuildContext context, _UtilityItem utility) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: utility.description,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.space12,
          vertical: AppTheme.space8,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(utility.icon, size: 16, color: colorScheme.primary),
            const SizedBox(width: AppTheme.space8),
            Text(
              utility.title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationRail(BuildContext context) {
    return NavigationRail(
      selectedIndex: 0,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            break;
          case 1:
            context.goToCounter();
            break;
          case 2:
            _showComingSoon(context);
            break;
          case 3:
            _showAboutDialog(context);
            break;
        }
      },
      labelType: NavigationRailLabelType.selected,
      leading: Column(
        children: [
          const SizedBox(height: 8),
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
      trailing: Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () => _showLogoutDialog(context, widget.onLogout),
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text('Home'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.add_circle_outline),
          selectedIcon: Icon(Icons.add_circle),
          label: Text('Counter'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: Text('Profile'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.info_outline),
          selectedIcon: Icon(Icons.info),
          label: Text('About'),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, VoidCallback onLogout) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout, size: 24),
            SizedBox(width: 12),
            Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.pop();
              onLogout();
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.construction, color: Colors.white),
            SizedBox(width: 12),
            Text('Coming Soon!'),
          ],
        ),
        backgroundColor: colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.flutter_dash,
                color: colorScheme.onPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(AppConstants.appName),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version ${AppConstants.appVersion}',
              style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 16),
            const Text(
              'A production-ready Flutter template featuring:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            _buildAboutItem('MVC Architecture with feature-based organization'),
            _buildAboutItem('Async Redux state management'),
            _buildAboutItem('OAuth-first authentication (Firebase optional)'),
            _buildAboutItem('GoRouter navigation with auth guards'),
            _buildAboutItem('Hive local database with offline-first pattern'),
            _buildAboutItem('Mason brick for code generation'),
            _buildAboutItem('Built-in utilities (validation, pagination, etc.)'),
            _buildAboutItem('i18n localization support'),
            const SizedBox(height: 16),
            const Text(
              '© 2024 Flutter Template',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => context.pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _UtilityItem {
  const _UtilityItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}
