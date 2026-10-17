import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pwe/core/services/screen_security_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ScreenSecurityService service;
  final List<MethodCall> channelCalls = [];

  setUp(() {
    channelCalls.clear();
    SharedPreferences.setMockInitialValues({});

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('br.com.jhhsolutions.praywithme/security'),
          (MethodCall methodCall) async {
            channelCalls.add(methodCall);
            if (methodCall.method == 'setSecureScreen') {
              return true;
            }
            if (methodCall.method == 'isSecureScreenEnabled') {
              return false;
            }
            return null;
          },
        );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('br.com.jhhsolutions.praywithme/security'),
          null,
        );
  });

  group('ScreenSecurityService', () {
    test('deve retornar false por padrão quando não configurado', () async {
      final prefs = await SharedPreferences.getInstance();
      service = ScreenSecurityServiceImpl(prefs: prefs);

      final isEnabled = await service.isScreenSecurityEnabled();
      expect(isEnabled, isFalse);
    });

    test(
      'deve persistir e invocar canal nativo ao alternar para true',
      () async {
        final prefs = await SharedPreferences.getInstance();
        service = ScreenSecurityServiceImpl(prefs: prefs);

        await service.setScreenSecurityEnabled(true);

        expect(await service.isScreenSecurityEnabled(), isTrue);
        expect(prefs.getBool('screen_security_enabled'), isTrue);
      },
    );

    test('deve persistir e desabilitar ao alternar para false', () async {
      SharedPreferences.setMockInitialValues({'screen_security_enabled': true});
      final prefs = await SharedPreferences.getInstance();
      service = ScreenSecurityServiceImpl(prefs: prefs);

      expect(await service.isScreenSecurityEnabled(), isTrue);

      await service.setScreenSecurityEnabled(false);

      expect(await service.isScreenSecurityEnabled(), isFalse);
      expect(prefs.getBool('screen_security_enabled'), isFalse);
    });

    test('applyPersistedScreenSecurity deve aplicar valor salvo', () async {
      SharedPreferences.setMockInitialValues({'screen_security_enabled': true});
      final prefs = await SharedPreferences.getInstance();
      service = ScreenSecurityServiceImpl(prefs: prefs);

      await service.applyPersistedScreenSecurity();

      expect(await service.isScreenSecurityEnabled(), isTrue);
    });
  });
}
