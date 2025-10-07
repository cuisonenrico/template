import 'package:freezed_annotation/freezed_annotation.dart';

part '{{name.snakeCase()}}_models.freezed.dart';
part '{{name.snakeCase()}}_models.g.dart';

{{#model_fields.length}}@freezed
class {{name.pascalCase()}} with _${{name.pascalCase()}} {
  const factory {{name.pascalCase()}}({
{{#model_fields}}    required {{type}} {{name}},
{{/model_fields}}  }) = _{{name.pascalCase()}};

  factory {{name.pascalCase()}}.fromJson(Map<String, dynamic> json) => _${{name.pascalCase()}}FromJson(json);
}

{{/model_fields.length}}
{{^model_fields.length}}class {{name.pascalCase()}} {
  final String id;
  final String name;
  final DateTime createdAt;

  const {{name.pascalCase()}}({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  {{name.pascalCase()}} copy({
    String? id,
    String? name,
    DateTime? createdAt,
  }) {
    return {{name.pascalCase()}}(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory {{name.pascalCase()}}.fromJson(Map<String, dynamic> json) {
    return {{name.pascalCase()}}(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is {{name.pascalCase()}} &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          createdAt == other.createdAt;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ createdAt.hashCode;

  @override
  String toString() {
    return '{{name.pascalCase()}}{id: $id, name: $name, createdAt: $createdAt}';
  }
}

{{/model_fields.length}}

@freezed
class {{name.pascalCase()}}State with _${{name.pascalCase()}}State {
  const factory {{name.pascalCase()}}State({
    @Default([]) List<{{name.pascalCase()}}> items,
    @Default(false) bool isLoading,
    String? error,
    {{name.pascalCase()}}? selected{{name.pascalCase()}},
  }) = _{{name.pascalCase()}}State;

  factory {{name.pascalCase()}}State.fromJson(Map<String, dynamic> json) => _${{name.pascalCase()}}StateFromJson(json);

  factory {{name.pascalCase()}}State.initialState() => const {{name.pascalCase()}}State();
}