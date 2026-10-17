import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Contrato para gestão de privacidade de tela e controle dinâmico de capturas (RN-SEC-092).
abstract class ScreenSecurityService {
  /// Retorna se o Modo de Máxima Privacidade está ativado.
  Future<bool> isScreenSecurityEnabled();

  /// Habilita ou desabilita a proteção contra prints/gravação de tela.
  Future<void> setScreenSecurityEnabled(bool enabled);

  /// Aplica a preferência persistida na inicialização do aplicativo.
  Future<void> applyPersistedScreenSecurity();
}

/// Implementação padrão que utiliza [SharedPreferences] e [MethodChannel] nativo.
class ScreenSecurityServiceImpl implements ScreenSecurityService {
  static const String prefKey = 'screen_security_enabled';
  static const MethodChannel _channel = MethodChannel(
    'br.com.jhhsolutions.praywithme/security',
  );

  final SharedPreferences prefs;

  ScreenSecurityServiceImpl({required this.prefs});

  @override
  Future<bool> isScreenSecurityEnabled() async {
    return prefs.getBool(prefKey) ?? false;
  }

  @override
  Future<void> setScreenSecurityEnabled(bool enabled) async {
    await prefs.setBool(prefKey, enabled);
    await _applyNative(enabled);
  }

  @override
  Future<void> applyPersistedScreenSecurity() async {
    final enabled = await isScreenSecurityEnabled();
    await _applyNative(enabled);
  }

  Future<void> _applyNative(bool enabled) async {
    if (kIsWeb) return;
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    try {
      await _channel.invokeMethod('setSecureScreen', {'enabled': enabled});
    } on PlatformException catch (e) {
      debugPrint('[ScreenSecurityService] Falha ao alternar FLAG_SECURE: $e');
    } catch (e) {
      debugPrint(
        '[ScreenSecurityService] Erro inesperado ao aplicar segurança de tela: $e',
      );
    }
  }
}
