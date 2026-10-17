# ADR 0037 — Robustecimento e Conformidade dos Recursos Firebase na Versão Web

**Data:** 07 de Outubro de 2026  
**Status:** 🟢 Aceito  
**Autores:** Arquiteto de Software Principal & Engenheiro Sênior  

---

## 1. Contexto

A versão Web do **pwE** compartilha a base de código única com os aplicativos móveis e conecta-se ao mesmo projeto no Firebase (`<REDACTED_GCP_PROJECT_ID>`).
Durante auditoria técnica e revisão de governança de nuvem (FinOps), foram identificadas oportunidades de robustecimento nos serviços periféricos do Firebase no ambiente Web:

1. **App Check Desprovido de Provedor Web:** O `AppCheckServiceImpl` configurava apenas `providerAndroid` e `providerApple`. Na Web, a ausência de `providerWeb` deixava as requisições ao Cloud Firestore desprovidas de atestação de integridade, expondo o projeto a bloqueios caso a imposição (*enforcement*) seja ativada no console.
2. **Firebase Performance Ocioso:** A dependência `firebase_performance` estava registrada no contêiner de injeção (`GetIt`), mas nenhum trace ou métrica customizada era enviado, deixando o console de Performance sem dados sobre a latência real das chamadas aos modelos Gemini.
3. **Push Notifications (FCM) sem Infraestrutura Web:** O `PushNotificationServiceImpl` tentava registrar listeners de primeiro plano e buscar tokens no browser sem um Service Worker (`firebase-messaging-sw.js`) nem credencial VAPID, gerando potenciais falhas silenciosas no navegador.
4. **Crashlytics Incompatível com Web:** O pacote oficial `firebase_crashlytics` não suporta Flutter Web. Era necessário garantir um fallback anônimo para registrar exceções não tratadas no navegador sem violar o princípio de privacidade *Zero-Knowledge* (ADR 0010).

---

## 2. Decisão

1. **App Check com Provedor Web Dinâmico:**
   - Adicionado `providerWeb` no `AppCheckServiceImpl.initialize()`.
   - Em desenvolvimento/debug local, utiliza `WebDebugProvider()`.
   - Em produção (`kReleaseMode`), utiliza `ReCaptchaV3Provider` configurado via `EnvConfig.get('RECAPTCHA_V3_SITE_KEY')`. Se a chave não for informada, faz fallback gracioso para debug token seguro.
2. **Instrumentação Ativa de Performance (LLM Traces):**
   - Integrado `FirebasePerformance` ao `LlmExecutionMetrics`.
   - Toda execução de LLM (exegese, meditação, oração e salvaguardas) emite um Custom Trace estruturado (`llm_<stage>`), gravando:
     - Métricas: `duration_ms`, `input_chars`, `output_chars`, `estimated_tokens` e `ttft_ms` (Time To First Token).
     - Atributos: `model_name`, `backend`, `is_success` e `error`.
   - Opera transparentemente na Web via `firebase_performance_web` e no mobile nativo.
3. **Isolamento Defensivo de Push Notifications na Web:**
   - O `PushNotificationServiceImpl` passa a receber `isWeb` (com default `kIsWeb`).
   - Na Web, `initialize()` é uma operação segura imediata (*no-op*), e `requestNotificationPermission()`, `isPermissionGranted()` e `getToken()` retornam `false` / `null` sem disparar chamadas com falha no console.
4. **Telemetria de Erros Web via Google Analytics 4:**
   - Em `lib/main.dart`, configurado manipulador de `FlutterError.onError` e `PlatformDispatcher.instance.onError` para `kIsWeb`, reportando eventos anônimos (`web_flutter_error`, `web_platform_error`) via `AnalyticsService`.
   - No `AnalyticsServiceImpl.logError`, quando `_crashlytics` for nulo (Web), despacha o evento estruturado `app_error` no GA4, respeitando estritamente a política Zero-Knowledge (ADR 0010).

---

## 3. Consequências

- **Positivas:**
  - Plena conformidade e blindagem da versão Web para atestação de integridade com Firebase App Check.
  - Observabilidade de ponta a ponta sobre latência e tempo de geração de tokens dos modelos de IA no painel do Firebase Console.
  - Eliminação de logs de advertência no console do browser relacionados a Service Workers ausentes.
  - Telemetria de erros ativa no navegador sem depender de bibliotecas proprietárias adicionais.
- **Rastreabilidade e Testes:**
  - Suíte de testes unitários atualizada e expandida em `app_check_service_test.dart`, `llm_performance_tracker_test.dart`, `push_notification_service_test.dart` e `analytics_service_test.dart`, mantendo 100% dos testes aprovados e 0 *analyzer issues*.
