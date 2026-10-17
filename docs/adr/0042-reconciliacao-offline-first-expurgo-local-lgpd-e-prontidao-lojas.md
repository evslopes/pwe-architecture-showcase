# ADR 0042: Reconciliação Bidirecional Offline-First, Expurgo Local LGPD/GDPR, Inversão de Dependências Core e Prontidão Nativa para Lojas

- **Status:** Implementado
- **Data:** 13 de Outubro de 2026
- **Autores:** Arquiteto de Software Principal & Equipe de Engenharia pwE
- **Contexto:** Auditoria integral de Engenharia de Software, Clean Architecture, Segurança/LGPD, Camada de Dados e Prontidão para Apple App Store e Google Play Store

---

## 1. Contexto e Diagnóstico

Durante a auditoria técnica pré-produção do aplicativo **pwE (Pray With Me)** para publicação nas lojas oficiais (**Google Play Store** e **Apple App Store**), foram identificados pontos de melhoria distribuídos em quatro eixos fundamentais:

1. **Engenharia de Dados & Reconciliação Offline-First:**
   - O método `LectioRepositoryImpl.getArchivedSessions()` priorizava a nuvem em detrimento do armazenamento local: quando o usuário estava autenticado e online, retornava apenas os documentos do Cloud Firestore sem hidratar a caixa criptografada local (`CACHED_SESSIONS_BOX_V2`) e sem enviar para a nuvem as sessões do **Caderno Espiritual** salvas durante períodos offline.
   - O `ProfileRepositoryImpl` consultava exclusivamente o Cloud Firestore, exibindo falhas ou estado vazio na tela de Perfil e Constância Orante quando o dispositivo estava sem conexão.

2. **Segurança da Informação & Conformidade LGPD/GDPR em Dispositivos Compartilhados:**
   - Os fluxos `AuthRepositoryImpl.signOut()` e `AuthRepositoryImpl.deleteAccount()` encerravam a sessão no Firebase Auth e apagavam dados remotos na nuvem, mas mantinham intactos no dispositivo local a caixa Hive criptografada (`CACHED_SESSIONS_BOX_V2`), o cache de perfil em `SharedPreferences` e a chave mestra `pwe_data_encryption_key_v1` no `FlutterSecureStorage`.
   - O `EncryptedHiveBoxOpener` excluía imediatamente a caixa criptografada ao primeiro erro de abertura, sem tentativa de recuperação (*retry*) para falhas transitórias de I/O ou lock do sistema operacional.

3. **Pureza Arquitetural (Clean Architecture & DDD):**
   - A camada `lib/core/` continha três acoplamentos ascendentes para `lib/features/`:
     - `core/theme/sacred_typography.dart` importava `ReadingPreferences` e `SacredFontFamily` de `features/preferences`.
     - `core/widgets/language_selection_dialog.dart` importava `PreferencesBloc`, `DailyLiturgyBloc` e `LectioSessionBloc`.
     - `core/l10n/l10n_extensions.dart` importava `SoulState`, `SpiritualFruit`, `GotaCategory` e `UserProfile`.
   - Três UseCases de diagnóstico em `features/subscription/domain/usecases/` importavam `package:flutter/foundation.dart` (`kDebugMode`).
   - O arquivo legado `lib/features/lectio_divina/presentation/bloc/lectio_state.dart` permanecia em `lib/` apenas por causa do enum `ImmersiveStep` e de fixtures de teste.

4. **Prontidão Nativa para Apple App Store & Google Play Store:**
   - **iOS (`Info.plist` & `Podfile`):** Presença de `<string>processing</string>` em `UIBackgroundModes` sem registro de `BGTaskSchedulerPermittedIdentifiers` (causa de rejeição imediata pela Apple Guideline 2.5.4), ausência de `CFBundleURLTypes` para callback OAuth do Google Sign-In, ausência de `CFBundleLocalizations` para os 18 idiomas suportados e ausência de `ios/Podfile` versionado com target mínimo `iOS 15.0`.
   - **Exclusão de Conta com Apple Sign-In (Guideline 5.1.1(v)):** Em `AuthRemoteDataSourceImpl.deleteAccount()`, a captura de `requires-recent-login` tratava apenas `google.com`, sem fluxo de reautenticação interativa para `apple.com` (`AppleAuthProvider`).
   - **Android (`AndroidManifest.xml`):** Uso da permissão restrita `SCHEDULE_EXACT_ALARM` para lembretes diários de oração, sujeita a bloqueio pela política da Google Play para aplicativos cuja função primária não é relógio/despertador.
   - **Google Play Data Safety:** Necessidade de página pública web (`landing/delete-account.html`) para solicitação de exclusão de conta fora do aplicativo.

---

## 2. Decisão Arquitetural

### 2.1. Reconciliação Bidirecional Offline-First e Cache Local de Perfil
- **Reconciliação do Caderno Espiritual (`LectioRepositoryImpl`):**
  - `getArchivedSessions()` carrega primeiramente todas as sessões locais da caixa Hive criptografada (`localDataSource.getArchivedSessions()`).
  - Quando o usuário está autenticado, busca as sessões remotas no Cloud Firestore e executa a união determinística por `id`:
    1. Sessões presentes apenas no Firestore são persistidas em lote no Hive (`cacheSessionsBatch(remoteOnly)`).
    2. Sessões presentes apenas localmente (criadas offline) são enviadas de forma assíncrona (*fire-and-forget* resiliente) para o Firestore.
    3. A lista unificada é ordenada de forma decrescente por `timestamp` e retornada imediatamente ao usuário.
- **Cache Offline de Perfil (`ProfileLocalDataSource`):**
  - Criado `ProfileLocalDataSource` em `lib/features/profile/data/datasources/profile_local_datasource.dart` persistindo `UserProfileModel` em JSON no `SharedPreferences` (`CACHED_USER_PROFILE_{uid}`).
  - `ProfileRepositoryImpl.getUserProfile()` hidrata o cache local a cada leitura bem-sucedida da nuvem e retorna o perfil em cache quando offline, preservando também o cálculo local de ofensiva/constância (`recordActivity`).

### 2.2. Higienização Local Pós-Logout e Pós-Exclusão (LGPD/GDPR)
- **Serviço `ILocalUserDataCleaner` (`lib/core/services/local_user_data_cleaner.dart`):**
  - Contrato desacoplado injetado em `AuthRepositoryImpl`.
  - No `signOut()` (`purgeKey: false`): limpa todos os registros de `CACHED_SESSIONS_BOX_V2` e remove os caches `CACHED_USER_PROFILE_*`, impedindo exposição de anotações espirituais em dispositivos compartilhados.
  - No `deleteAccount()` (`purgeKey: true`): além de limpar as caixas e preferências, destrói e rotaciona a chave criptográfica AES-256 (`pwe_data_encryption_key_v1`) no Keychain/Keystore (`FlutterSecureStorage`), garantindo eliminação criptográfica irreversível (*crypto-shredding*).
- **Resiliência do `EncryptedHiveBoxOpener`:**
  - Adicionado *retry* com atraso (`250ms`) antes de considerar uma caixa Hive irrecuperável, protegendo contra falhas transitórias de lock de arquivo do sistema operacional.

### 2.3. Inversão de Dependências em `lib/core/` e Domínio Puro
- **Tipografia Sacra (`SacredTypographyConfig` & `SacredFontFamily`):**
  - Movido `SacredFontFamily` para `lib/core/theme/sacred_font_family.dart` e criada a interface `SacredTypographyConfig` em `core/theme/sacred_typography.dart`, implementada por `ReadingPreferences`.
- **Diálogo Litúrgico de Idiomas:**
  - `core/widgets/language_selection_dialog.dart` tornou-se um widget puro baseado em callback (`onLocaleSelected`), enquanto o wrapper reativo acoplado aos BLoCs foi movido para `lib/features/lectio_divina/presentation/widgets/liturgical_language_dialog.dart`.
- **Enums Compartilhados em `core/domain/`:**
  - `SoulState`, `SpiritualFruit` e `GotaCategory` foram promovidos para `lib/core/domain/` (com re-export retrocompatível em `features/lectio_divina/domain/`), eliminando todos os imports de `features/` em `core/l10n/l10n_extensions.dart`.
- **Extração de `ImmersiveStep` e Remoção de `lectio_state.dart`:**
  - `ImmersiveStep` foi extraído para `lib/features/lectio_divina/domain/enums/immersive_step.dart`, as classes legadas de estado foram movidas para o helper de teste `test/features/lectio_divina/helpers/legacy_lectio_state_fixture.dart`, e `lib/features/lectio_divina/presentation/bloc/lectio_state.dart` foi removido de `lib/`.
- **UseCases de Assinatura 100% Dart Puro:**
  - Substituído `kDebugMode` (`package:flutter/foundation.dart`) pela constante nativa `bool.fromEnvironment('dart.vm.product')` nos UseCases de simulação de debug.

### 2.4. Conformidade com Apple App Store & Google Play Store
- **iOS (`Info.plist`, `Podfile` & Reautenticação Apple):**
  - Removido `<string>processing</string>` de `UIBackgroundModes`, configurado `CFBundleURLTypes` para Google Sign-In, declaradas as 18 localizações em `CFBundleLocalizations` e criado `ios/Podfile` (`platform :ios, '15.0'`).
  - Adicionada reautenticação interativa com `AppleAuthProvider` durante `deleteAccount()` no `AuthRemoteDataSourceImpl`.
- **Android (`AndroidManifest.xml` & `LocalNotificationService`):**
  - Removida a permissão `SCHEDULE_EXACT_ALARM` e adotado `AndroidScheduleMode.inexactAllowWhileIdle`, eliminando o risco de rejeição na Google Play Store.
- **Landing Page de Exclusão de Conta (`landing/delete-account.html`):**
  - Criada página pública dedicada contendo instruções de exclusão in-app e canal externo de atendimento ao titular de dados (LGPD/GDPR e Google Play Data Safety).

---

## 3. Consequências

### Positivas
- **Sincronização Offline-First Real:** Nenhuma meditação ou anotação do Caderno Espiritual criada offline é perdida ao reconectar ou alternar dispositivos.
- **Privacidade Zero-Trust e Conformidade LGPD/GDPR:** Exclusão de conta e logout limpam integralmente dados sensíveis locais e realizam *crypto-shredding* da chave AES-256.
- **Fronteiras Arquiteturais Limpas:** `lib/core/` não possui mais nenhuma dependência ascendente para `lib/features/`, e todos os `domain/` permanecem livres do SDK do Flutter.
- **Aprovação Desimpedida nas Lojas:** Eliminação dos bloqueadores técnicos das diretrizes Apple 2.5.4, 4.8 e 5.1.1(v) e da política de Alarmes Exatos e Data Safety do Google Play.
