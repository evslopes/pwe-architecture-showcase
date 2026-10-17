# ADR 0020: Redesign da Inicialização Nativa (Android 12+ SplashScreen API Adaptativa) e Ícone Pergaminho Nobre

**Status:** Aprovado  
**Data:** 01 de Outubro de 2026  
**Contexto:** Evolução da Identidade Visual e Experiência de Inicialização do pwE (Pray With Me)  

---

## 1. Contexto e Problema
Ao iniciar o aplicativo no Android 12+, o usuário visualizava uma tela branca com o ícone do app confinado em um quadrado no centro. Esse comportamento decorria de:
1. **SplashScreen API do Android 12+ não configurada:** A ausência de temas específicos em `values-v31` fazia o sistema operacional adotar o fundo branco estático de `launch_background.xml` e estampar o `@mipmap/ic_launcher` legado.
2. **Ícone sem Camadas Adaptativas:** O arquivo `app_logo.png` possuía cantos arredondados e fundo azul-ardósia desenhados diretamente na imagem, gerando o efeito de "ícone engessado em moldura" na tela inicial e nas buscas do sistema. Além disso, o visual com degradê e lens flare digital estava desalinhado com o Design Sacro e os tokens do pwE.
3. **Latência de Cold Start no `main.dart`:** Inicializações bloqueantes de serviços periféricos (`AppCheckService`, `RemoteConfigService`, `PushNotificationService`, `IModelDownloadService`) com timeouts de até 3s estendiam desnecessariamente a duração da tela nativa de splash antes de chamar `runApp()`.

## 2. Decisão Arquitetural
1. **Ícone Mestre no Conceito Sacro Minimalista (A Cruz da Chaga Gloriosa):**
   - Adoção definitiva da iconografia sacra inspirada no "básico bem feito" e no carisma da Comunidade Shalom: Cruz esguia em Bronze Litúrgico (`#8B6914`), aro nímbico circular fino de ouro e a **chaga gloriosa do Ressuscitado (mandorla de ouro incandescente `#C5A059`)** em seu centro, emanando a Paz (*Shalom*).
   - Superfície de fundo em Pergaminho Nobre marfim (`#FBF7EF`), criando um ponto de silêncio e sacralidade no smartphone.
   - Configuração de ícones adaptativos com `adaptive_icon_background: "#FBF7EF"`, `remove_alpha_ios: true` e geração de todos os mipmaps para Android e catálogo completo do iOS (`AppIcon.appiconset`).
   - Suporte a **Themed Icons do Android 13+ (Material You)** via camada monocromática `@drawable/ic_launcher_monochrome`, permitindo que sistemas com tematização dinâmica adaptem o ícone automaticamente ao tema do launcher.
2. **Splash Screen Dinâmica e Adaptativa ao Tema (Light & Dark):**
   - **Modo Claro (Pergaminho Nobre):**
     - Em `values-v31/styles.xml`: `android:windowSplashScreenBackground` = `@color/splash_background_light` (`#FBF7EF`) e `android:windowSplashScreenAnimatedIcon` = `@drawable/ic_launcher_foreground`.
     - Em `drawable/launch_background.xml`: Fundo `#FBF7EF` com glifo em bronze centralizado.
   - **Modo Escuro (Noite Contemplativa):**
     - Em `values-night-v31/styles.xml`: `android:windowSplashScreenBackground` = `@color/splash_background_dark` (`#161616`) e `android:windowSplashScreenAnimatedIcon` = `@drawable/splash_icon_dark`.
     - Em `drawable-night/launch_background.xml`: Fundo `#161616` com glifo em ouro champanhe centralizado.
     - `@drawable/splash_icon_dark` harmonizado com a exata geometria do Pergaminho Nobre em traços dourados e brilho âmbar, sem qualquer corte circular ou máscara artificial.
3. **Desacoplamento Assíncrono do Cold Start:**
   - No `lib/main.dart`, os serviços periféricos passaram a ser disparados em segundo plano via `unawaited(Future.wait([...]))`, permitindo que `runApp(const PweApp())` renderize o primeiro frame quase instantaneamente (< 400ms).
4. **Harmonização Sacra da Tela de Privacidade (App Switcher):**
   - No `PrivacyScreenWrapper` (`lib/core/widgets/privacy_screen_wrapper.dart`), o ícone genérico `Icons.auto_stories_rounded` ciano foi substituído pelo emblema oficial do pwE (`assets/images/app_logo.png`) envolto em um `GoldenHalo` com elevação e cantos arredondados de 22dp.
   - Tipografia sacra unificada com `GoogleFonts.lora`, acento litúrgico dourado (`context.sacred.goldAccent`) e divisor cruciforme central (`CrossOrnamentalDivider`).
   - Fundo dinâmico adaptado aos tokens `sacred.parchment` (claro) e `sacred.contemplativeSurface` (escuro).

## 3. Consequências
- **Positivas:**
  - Inicialização fluida, nobre e sem cortes visuais ou telas brancas abrasivas.
  - Abertura inteligente que respeita o ambiente: luminosidade serena no modo claro e proteção visual acolhedora para oração noturna no modo escuro.
  - Ocultamento de multitarefa sacralizado e perfeitamente integrado à identidade visual da aplicação.
  - Ícone adaptativo nativo que se conforma harmonicamente a qualquer launcher em todas as versões do Android e iOS, com suporte a Material You no Android 13+.
  - Redução drástica da latência percebida no lançamento a frio (*cold start*).
  - 100% dos testes unitários, de BLoC e de widgets aprovados, com 0 lints.
