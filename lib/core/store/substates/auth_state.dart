import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../features/auth/models/auth_models.dart';

part 'auth_state.freezed.dart';
part 'auth_state.g.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    @Default(false) bool isLoggedIn,
    @Default(false) bool isLoading,
    User? user,
    String? accessToken,
    String? refreshToken,
    String? error,
  }) = _AuthState;

  factory AuthState.fromJson(Map<String, dynamic> json) =>
      _$AuthStateFromJson(json);

  factory AuthState.initialState() => const AuthState();
}
