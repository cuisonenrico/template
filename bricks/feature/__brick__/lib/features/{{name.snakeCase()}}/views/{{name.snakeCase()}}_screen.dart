import 'package:flutter/material.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../models/{{name.snakeCase()}}_models.dart';

class {{name.pascalCase()}}Screen extends StatelessWidget {
  const {{name.pascalCase()}}Screen({
    required this.items,
    required this.isLoading,
    required this.error,
    required this.selected{{name.pascalCase()}},
    required this.onRefresh,
    required this.onSelect,
    required this.onDelete,
    required this.onClearError,
    super.key,
  });

  final List<{{name.pascalCase()}}> items;
  final bool isLoading;
  final String? error;
  final {{name.pascalCase()}}? selected{{name.pascalCase()}};
  final VoidCallback onRefresh;
  final Function({{name.pascalCase()}}) onSelect;
  final Function(String) onDelete;
  final VoidCallback onClearError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('{{name.titleCase()}}'),
        centerTitle: true,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAdd{{name.pascalCase()}}Dialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading && items.isEmpty) {
      return const LoadingWidget(message: 'Loading {{name.titleCase()}}...');
    }

    if (error != null) {
      return ErrorWidget(
        message: error!,
        onRetry: onRefresh,
      );
    }

    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: AppTheme.mediumSpacing),
            Text(
              'No {{name.titleCase()}} found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: AppTheme.smallSpacing),
            Text(
              'Tap the + button to add your first {{name.titleCase()}}',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final {{name.camelCase()}} = items[index];
          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: AppTheme.mediumSpacing,
              vertical: AppTheme.smallSpacing,
            ),
            child: ListTile(
              title: Text({{name.camelCase()}}.name),
              subtitle: Text('ID: ${{{name.camelCase()}}.id}'),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _showEdit{{name.pascalCase()}}Dialog(context, {{name.camelCase()}});
                      break;
                    case 'delete':
                      _showDelete{{name.pascalCase()}}Dialog(context, {{name.camelCase()}});
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
              onTap: () => onSelect({{name.camelCase()}}),
            ),
          );
        },
      ),
    );
  }

  void _showAdd{{name.pascalCase()}}Dialog(BuildContext context) {
    // TODO: Implement add {{name.camelCase()}} dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add {{name.titleCase()}}'),
        content: const Text('Add {{name.titleCase()}} dialog not implemented yet.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEdit{{name.pascalCase()}}Dialog(BuildContext context, {{name.pascalCase()}} {{name.camelCase()}}) {
    // TODO: Implement edit {{name.camelCase()}} dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit {{name.titleCase()}}'),
        content: Text('Edit {{name.titleCase()}} "${{{name.camelCase()}}.name}" not implemented yet.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDelete{{name.pascalCase()}}Dialog(BuildContext context, {{name.pascalCase()}} {{name.camelCase()}}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete {{name.titleCase()}}'),
        content: Text('Are you sure you want to delete "${{{name.camelCase()}}.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete({{name.camelCase()}}.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}