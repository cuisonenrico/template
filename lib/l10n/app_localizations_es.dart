// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Aplicación Plantilla';

  @override
  String get commonOk => 'Aceptar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonLoading => 'Cargando...';

  @override
  String get commonError => 'Error';

  @override
  String get commonSuccess => 'Éxito';

  @override
  String get commonNoData => 'No hay datos disponibles';

  @override
  String get commonPullToRefresh => 'Desliza para actualizar';

  @override
  String get commonEndOfList => 'Fin de la lista';

  @override
  String get authLogin => 'Iniciar sesión';

  @override
  String get authLogout => 'Cerrar sesión';

  @override
  String get authRegister => 'Registrarse';

  @override
  String get authEmail => 'Correo electrónico';

  @override
  String get authPassword => 'Contraseña';

  @override
  String get authConfirmPassword => 'Confirmar contraseña';

  @override
  String get authForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get authNoAccount => '¿No tienes cuenta?';

  @override
  String get authHaveAccount => '¿Ya tienes cuenta?';

  @override
  String get authLoginWithGoogle => 'Continuar con Google';

  @override
  String get authLoginWithApple => 'Continuar con Apple';

  @override
  String get authOrContinueWith => 'O continuar con';

  @override
  String get validationRequired => 'Este campo es obligatorio';

  @override
  String get validationInvalidEmail => 'Por favor ingresa un correo válido';

  @override
  String validationPasswordTooShort(int count) {
    return 'La contraseña debe tener al menos $count caracteres';
  }

  @override
  String get validationPasswordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get errorGeneric => 'Algo salió mal. Por favor intenta de nuevo.';

  @override
  String get errorNetwork => 'Sin conexión a internet';

  @override
  String get errorTimeout =>
      'Tiempo de espera agotado. Por favor intenta de nuevo.';

  @override
  String get errorUnauthorized =>
      'Sesión expirada. Por favor inicia sesión de nuevo.';

  @override
  String get errorNotFound => 'Recurso no encontrado';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsNotifications => 'Notificaciones';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String settingsVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileEditProfile => 'Editar perfil';

  @override
  String get profileName => 'Nombre';

  @override
  String get homeTitle => 'Inicio';

  @override
  String homeWelcome(String name) {
    return '¡Bienvenido, $name!';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos',
      one: '1 elemento',
      zero: 'Sin elementos',
    );
    return '$_temp0';
  }

  @override
  String get dateToday => 'Hoy';

  @override
  String get dateYesterday => 'Ayer';

  @override
  String dateFormat(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }
}
