# ADR 0044: Privacidade de Tela Configurável (Controle do Fiel) e Partilha Visual Evangelizadora de Cards Sacros

- **Status:** Aceito
- **Data:** 2026-10-16
- **Autores:** Arquitetura pwE

## Contexto e Problema

O aplicativo pwE implementava uma proteção de janela estrita no Android via `WindowManager.LayoutParams.FLAG_SECURE` (`MainActivity.kt`), formalizada na regra de negócio `RN-SEC-092` e na mitigação de segurança `VULN-07` (Red Team Audit). O objetivo original era a blindagem do foro íntimo do orante (exames de consciência, orações espontâneas da *Oratio* e anotações privadas do *Caderno Espiritual*).

Contudo, a aplicação incondicional dessa flag em toda a Activity nativa gerou problemas críticos de produto, usabilidade e crescimento orgânico:

1. **Inibição Total da Viralidade e Divulgação Pastoral:** O fiel católico é naturalmente motivado a partilhar o Evangelho do dia, reflexões meditativas e a arte sacra litúrgica (Ícones Veni Creator) com familiares, grupos paroquiais e nas redes sociais (WhatsApp, Instagram Stories). O bloqueio de tela impedia qualquer captura, gerando frustração severa e quebrando o ciclo virtuoso de evangelização.
2. **Inconsistência entre Plataformas (Assimetria iOS vs Android):** No iOS, a proteção implementada consistia apenas em uma cortina visual de *blur* no ciclo de vida (`applicationWillResignActive` no `AppDelegate.swift`) para o alternador de tarefas (*App Switcher*), permitindo prints normais em uso ativo. No Android, o `FLAG_SECURE` bloqueava o sistema operacional por completo, criando uma experiência punitiva exclusiva para usuários de Android.
3. **Ausência de Exigência Regulatória pelas Lojas:** Nem a Google Play Store nem a Apple App Store exigem bloqueio de tela para aplicativos de oração ou diários espirituais.
4. **Falta de um Recurso Nativo e Elegante de Partilha:** Na ausência de um botão nativo de compartilhamento formatado, os fiéis dependiam exclusivamente de capturas de tela manuais com cortes irregulares.

## Decisão

Adotou-se uma estratégia equilibrada em três pilares convergentes:

1. **Remoção do `FLAG_SECURE` Incondicional no Android (`MainActivity.kt`):**
   - Removida a imposição estática de `FLAG_SECURE` no `onCreate` da janela nativa.
   - Implementado o canal nativo `br.com.jhhsolutions.praywithme/security` com o método `setSecureScreen(enabled: Boolean)`, permitindo ligar e desligar a flag de segurança dinamicamente em tempo de execução.
   - Mantida a proteção cross-platform do `PrivacyScreenWrapper`, que ofusca a interface sempre que o aplicativo é minimizado ou entra em segundo plano, resguardando o histórico no alternador de tarefas.

2. **Modo de Máxima Privacidade Configurável pelo Fiel (`ScreenSecurityService` & `ProfilePage`):**
   - Criado o serviço `ScreenSecurityService` com persistência em `SharedPreferences` (`screen_security_enabled`), inicializado no bootstrap do aplicativo (`main.dart`).
   - Disponibilizado um seletor visual (*SwitchListTile*) nas configurações do perfil (`ProfilePage`): *"Modo de Máxima Privacidade"*, desativado por padrão.
   - Quando ativado voluntariamente pelo fiel, o app aciona o `FLAG_SECURE` no Android para os usuários que exigem confidencialidade irrestrita contra qualquer captura de tela.

3. **Recurso Nativo de "Compartilhar Card Sacro" (`SacredShareService`, `SacredShareCard` & `SacredShareBottomSheet`):**
   - Integrado o pacote `share_plus` (v13.x via `SharePlus.instance.share`).
   - Criado o componente de renderização gráfica `SacredShareCard`: um card litúrgico digno e de alta definição com cruz dourada, data litúrgica, ornatos clássicos, versículo central do Evangelho em tipografia `Lora` e assinatura institucional do apostolado.
   - Criado o modal `SacredShareBottomSheet`, permitindo exportar o card como imagem PNG em alta resolução (renderizada localmente via `RenderRepaintBoundary` com `pixelRatio: 3.0` a custo zero) para postagem no WhatsApp e Instagram Stories, ou compartilhar o texto litúrgico formatado com um toque.
   - Adicionados botões de partilha acessíveis na barra superior do `DailyDashboardPage` e no diálogo imersivo `SacredIconContemplationDialog`.
   - Adicionadas as 8 novas chaves de localização simultaneamente aos **18 catálogos ARB** do projeto, com 100% de paridade validada pelo teste de integridade.

## Consequências

- **Aceleração do Crescimento Orgânico e Evangelização:** O fiel pode partilhar livremente a Palavra de Deus e os Ícones Sagrados no WhatsApp e Instagram Stories com estética nobre e marca d'água oficial do pwE.
- **Soberania do Usuário:** Quem deseja máxima privacidade pode ativar o bloqueio no perfil a qualquer momento, sem prejudicar a experiência da maioria.
- **Isonomia entre Plataformas:** Android e iOS passam a oferecer a mesma liberdade em uso ativo, mantendo ambos a blindagem de tela no alternador de tarefas.
- **Custo Zero (FinOps):** A renderização gráfica é realizada integralmente no cliente via `RepaintBoundary`, sem consumo de serviços de nuvem ou APIs pagas.
