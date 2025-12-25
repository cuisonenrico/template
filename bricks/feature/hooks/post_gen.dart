import 'dart:io';
import 'package:mason/mason.dart';

void run(HookContext context) async {
  final logger = context.logger;
  final name = context.vars['name'] as String;
  final hasApi = context.vars['has_api'] as bool;
  final pascalName = _toPascalCase(name);
  final snakeName = _toSnakeCase(name);
  final kebabName = _toKebabCase(name);
  final camelName = _toCamelCase(name);

  logger.info('🚀 Running post-generation tasks...');
  logger.info('');

  // 1. Update app_router.dart
  await _updateAppRouter(logger, snakeName, kebabName, pascalName);

  // 2. Update app_state.dart
  await _updateAppState(logger, snakeName, pascalName, camelName);

  // 3. Create state file
  await _createStateFile(logger, snakeName, pascalName);

  // 4. Update app_constants.dart (if has API)
  if (hasApi) {
    await _updateAppConstants(logger, snakeName, kebabName, pascalName);
  }

  // 5. Register Hive adapter
  await _registerHiveAdapter(logger, snakeName, pascalName);

  // 6. Run build_runner
  await _runBuildRunner(logger);

  logger.info('');
  logger.success('✨ Feature generation complete!');
  logger.info('');
  logger.info('📍 Navigate to your feature:');
  logger.info('   context.goTo$pascalName()');
  logger.info('');
  logger.info('📝 NexRun the app to test Hive integration!');
  logger.info('   4. Use Fetch${pascalName}ListAction to load data');
}

Future<void> _registerHiveAdapter(
  Logger logger,
  String snakeName,
  String pascalName,
) async {
  logger.detail('Registering Hive adapter...');

  final mainCommonPath = 'lib/main_common.dart';
  final mainCommonFile = File(mainCommonPath);

  if (!mainCommonFile.existsSync()) {
    logger.err('main_common.dart not found at $mainCommonPath');
    return;
  }

  String content = mainCommonFile.readAsStringSync();

  // Add import for the model
  final modelImport = "import 'features/$snakeName/models/${snakeName}_models.dart';";
  if (!content.contains(modelImport)) {
    final lastFeatureImport = content.lastIndexOf("import 'features/");
    if (lastFeatureImport != -1) {
      final endOfLineIndex = content.indexOf('\n', lastFeatureImport);
      content = content.substring(0, endOfLineIndex + 1) +
          modelImport +
          '\n' +
          content.substring(endOfLineIndex + 1);
    } else {
      // Add after core imports
      final lastCoreImport = content.lastIndexOf("import 'core/");
      if (lastCoreImport != -1) {
        final endOfLineIndex = content.indexOf('\n', lastCoreImport);
        content = content.substring(0, endOfLineIndex + 1) +
            '\n' +
            modelImport +
            '\n' +
            content.substring(endOfLineIndex + 1);
      }
    }
  }

  // Add Hive adapter registration after HiveService().init()
  final adapterRegistration = "  HiveService().registerAdapter(${pascalName}Adapter());";
  if (!content.contains('${pascalName}Adapter()')) {
    final hiveInitIndex = content.indexOf('await HiveService().init();');
    if (hiveInitIndex != -1) {
      final endOfLineIndex = content.indexOf('\n', hiveInitIndex);
      content = content.substring(0, endOfLineIndex + 1) +
          '\n  // Register Hive adapters\n' +
          adapterRegistration +
          '\n' +
          content.substring(endOfLineIndex + 1);
    }
  }

  mainCommonFile.writeAsStringSync(content);
  logger.detail('✓ Registered $pascalName Hive adapter in main_common.dart
  logger.info('   1. Check lib/core/store/substates/${snakeName}_state.dart');
  logger.info('   2. Customize your models and actions');
  logger.info('   3. Start building your UI!');
}

Future<void> _updateAppRouter(
  Logger logger,
  String snakeName,
  String kebabName,
  String pascalName,
) async {
  final routerPath = 'lib/core/router/app_router.dart';
  final routerFile = File(routerPath);

  if (!routerFile.existsSync()) {
    logger.err('app_router.dart not found at $routerPath');
    return;
  }

  logger.detail('Updating app_router.dart...');

  String content = routerFile.readAsStringSync();

  // 1. Add import for the new connector
  final importStatement =
      "import '../../features/$snakeName/views/${snakeName}_connector.dart';";

  if (!content.contains(importStatement)) {
    // Find the last import line and add after it
    final lastImportIndex = content.lastIndexOf("import '../../");
    if (lastImportIndex != -1) {
      final endOfLineIndex = content.indexOf('\n', lastImportIndex);
      content =
          content.substring(0, endOfLineIndex + 1) +
          importStatement +
          '\n' +
          content.substring(endOfLineIndex + 1);
      logger.detail('Added import statement');
    }
  }

  // 2. Add the route before the error page builder
  final routeDefinition =
      '''
      // $pascalName Route
      GoRoute(
        path: '/$kebabName',
        name: '$snakeName',
        pageBuilder: (context, state) =>
            _buildPageWithTransition(context, state, const ${pascalName}Connector(), '$pascalName'),
      ),
  logger.detail('✓ Added routes to app_router.dart');
}

Future<void> _updateAppState(
  Logger logger,
  String snakeName,
  String pascalName,
  String camelName,
) async {
  final appStatePath = 'lib/core/store/app_state.dart';
  final appStateFile = File(appStatePath);

  if (!appStateFile.existsSync()) {
    logger.err('app_state.dart not found at $appStatePath');
    return;
  }

  logger.detail('Updating app_state.dart...');

  String content = appStateFile.readAsStringSync();

  // Add import for the new state
  final stateImport = "import 'substates/${snakeName}_state.dart';";
  if (!content.contains(stateImport)) {
    final lastSubstateImport = content.lastIndexOf("import 'substates/");
    if (lastSubstateImport != -1) {
      final endOfLineIndex = content.indexOf('\n', lastSubstateImport);
 

String _toCamelCase(String input) {
  final pascal = _toPascalCase(input);
  return pascal[0].toLowerCase() + pascal.substring(1);
}     content = content.substring(0, endOfLineIndex + 1) +
          stateImport +
          '\n' +
          content.substring(endOfLineIndex + 1);
    }
  }

  // Add state field to AppState class
  final stateField =
      '    @Default(${pascalName}State()) ${pascalName}State $camelName,';
  
  // Find the last @Default line before the closing parenthesis
  if (!content.contains('$pascalName}State $camelName')) {
    final lastDefaultIndex = content.lastIndexOf('@Default(');
    if (lastDefaultIndex != -1) {
      final endOfLineIndex = content.indexOf('\n', lastDefaultIndex);
      content = content.substring(0, endOfLineIndex + 1) +
          stateField +
          '\n' +
          content.substring(endOfLineIndex + 1);
    }
  }

  appStateFile.writeAsStringSync(content);
  logger.detail('✓ Added state to app_state.dart');
}

Future<void> _createStateFile(
  Logger logger,
  String snakeName,
  String pascalName,
) async {
  final statePath = 'lib/core/store/substates/${snakeName}_state.dart';
  final stateFile = File(statePath);

  if (stateFile.existsSync()) {
    logger.detail('State file already exists, skipping...');
    return;
  }

  logger.detail('Creating ${snakeName}_state.dart...');

  final stateContent = '''import 'package:freezed_annotation/freezed_annotation.dart';
import '../../features/$snakeName/models/${snakeName}_models.dart';

part '${snakeName}_state.freezed.dart';
part '${snakeName}_state.g.dart';

@freezed
class ${pascalName}State with _\$${pascalName}State {
  const factory ${pascalName}State({
    @Default([]) List<$pascalName> items,
    @Default(false) bool isLoading,
    String? error,
    $pascalName? selected$pascalName,
  }) = _${pascalName}State;

  factory ${pascalName}State.fromJson(Map<String, dynamic> json) =>
      _\$${pascalName}StateFromJson(json);

  factory ${pascalName}State.initialState() => const ${pascalName}State();
}
''';

  stateFile.writeAsStringSync(stateContent);
  logger.detail('✓ Created ${snakeName}_state.dart');
}

Future<void> _updateAppConstants(
  Logger logger,
  String snakeName,
  String kebabName,
  String pascalName,
) async {
  final constantsPath = 'lib/core/constants/app_constants.dart';
  final constantsFile = File(constantsPath);

  if (!constantsFile.existsSync()) {
    logger.warn('app_constants.dart not found, skipping endpoint registration');
    return;
  }

  logger.detail('Updating app_constants.dart...');

  String content = constantsFile.readAsStringSync();

  // Add endpoint constant
  final endpointConstant =
      "  static const String ${camelName}Endpoint = '/$kebabName';";

  // Find the API Endpoints section
  final endpointsSection = content.indexOf('// API Endpoints');
  if (endpointsSection != -1 && !content.contains('${camelName}Endpoint')) {
    // Find the last endpoint definition in that section
    final routeNamesSection = content.indexOf('// Route Names');
    if (routeNamesSection != -1) {
      final lastEndpoint = content.lastIndexOf('Endpoint = ', routeNamesSection);
      if (lastEndpoint != -1) {
        final endOfLineIndex = content.indexOf(';', lastEndpoint) + 1;
        content = content.substring(0, endOfLineIndex) +
            '\n$endpointConstant' +
            content.substring(endOfLineIndex);
      }
    }
  }

  constantsFile.writeAsStringSync(content);
  logger.detail('✓ Added API endpoint to app_constants.dart');
}

Future<void> _runBuildRunner(Logger logger) async {
  logger.info('');
  logger.info('🔨 Running build_runner...');
  
  final result = await Process.run(
    'dart',
    ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
    runInShell: true,
  );

  if (result.exitCode == 0) {
    logger.detail('✓ Code generation complete');
  } else {
    logger.warn('Build runner encountered issues:');
    logger.warn(result.stderr.toString());
    logger.info('You may need to run: dart run build_runner build --delete-conflicting-outputs');
  }
      content =
          content.substring(0, insertPosition) +
          '\n$routeDefinition' +
          content.substring(insertPosition);
      logger.detail('Added route definition');
    }
  }

  // 3. Add navigation extension methods
  final extensionMethods =
      '''
  void goTo$pascalName() => go('/$kebabName');
  void push$pascalName() => push('/$kebabName');''';

  // Find the AppRouterExtension and add methods before the closing brace
  final extensionIndex = content.indexOf(
    'extension AppRouterExtension on BuildContext {',
  );
  if (extensionIndex != -1 && !content.contains("goTo$pascalName")) {
    final closingBraceIndex = content.indexOf('}', content.lastIndexOf('push'));
    if (closingBraceIndex != -1) {
      content =
          content.substring(0, closingBraceIndex) +
          '\n$extensionMethods\n' +
          content.substring(closingBraceIndex);
      logger.detail('Added navigation extension methods');
    }
  }

  // Write the updated content back
  routerFile.writeAsStringSync(content);

  logger.success(
    'Successfully updated app_router.dart with $pascalName route!',
  );
  logger.info('');
  logger.info('Navigation methods available:');
  logger.info('  • context.goTo$pascalName()');
  logger.info('  • context.push$pascalName()');
}

String _toPascalCase(String input) {
  return input
      .split(RegExp(r'[_\s-]+'))
      .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
      .join();
}

String _toSnakeCase(String input) {
  return input
      .replaceAll(RegExp(r'([A-Z])'), '_\$1')
      .toLowerCase()
      .replaceAll(RegExp(r'^_'), '')
      .replaceAll(RegExp(r'[_\s-]+'), '_');
}

String _toKebabCase(String input) {
  return _toSnakeCase(input).replaceAll('_', '-');
}
