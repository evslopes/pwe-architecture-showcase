# 0040. Lembretes Locais Agendados e Notificações Push FCM

**Status:** Aprovado  
**Data:** 09 de Outubro de 2026  
**Autor:** Antigravity / Engenheiro de Software Sênior & Arquiteto Principal  

---

## 1. Contexto e Problema

A prática perseverante da Lectio Divina (Leitura Orante) exige fidelidade e constância diária no ritmo de oração do fiel. Identificamos duas necessidades complementares de comunicação e dois gargalos na experiência existente:

1. **Notificações Push Remotas (FCM - Free Tier):** Capacidade de enviar comunicados gerais e convites matinais para a Liturgia Diária a toda a base de usuários (incluindo usuários de versões anteriores) com custo zero permanente (FinOps Clearance).
2. **Lembretes Locais Agendados (*On-Device*):** Necessidade de um despertador/lembrete pessoal no horário de preferência do usuário (ex: Laudes às 07:00 ou Completas às 21:00), funcionando offline e sem dependência de infraestrutura em nuvem.
3. **Diagnóstico do Diálogo Pós-Oração (`DailyReminderInviteDialog`):** O diálogo apresentado ao término da primeira oração e o interruptor na tela de `ProfilePage` apenas solicitavam a permissão do sistema (`requestNotificationPermission()`) e persistiam uma flag booleana `notifications_enabled`, sem efetivamente agendar nenhum alarme no sistema operacional nem permitir a escolha do horário desejado.
4. **Navegação Contextual:** Garantir que o toque na notificação direcione o usuário diretamente para o Dashboard da Liturgia Diária (`/`) e não para telas secundárias como a Passagem Livre (`/lectio`).

---

## 2. Decisão Arquitetural

Adotamos uma arquitetura híbrida e desacoplada em estrita conformidade com a Clean Architecture e DDD:

### 2.1. Serviço de Notificações Locais (`LocalNotificationService`)
- Adicionadas as dependências `flutter_local_notifications` e `timezone`.
- Criado o contrato `LocalNotificationService` e a implementação `LocalNotificationServiceImpl` em `lib/core/services/`, registrado como lazy singleton no contêiner de injeção global (`injection_container.dart`).
- Configurado o canal litúrgico `daily_prayer_channel` com alta prioridade e som.
- Agendamento diário com `matchDateTimeComponents: DateTimeComponents.time` e fuso horário local (`tz.local`), com suporte a fallback resiliente para `AndroidScheduleMode.inexactAllowWhileIdle` caso a permissão de alarme exato não seja concedida.
- Configuração de permissões no `AndroidManifest.xml`: `RECEIVE_BOOT_COMPLETED`, `VIBRATE` e `SCHEDULE_EXACT_ALARM`.

### 2.2. Aprimoramento de Push Remoto (`PushNotificationService`)
- Adição de métodos de subscrição e cancelamento em tópicos FCM (`subscribeToTopic('daily_liturgy')` e `unsubscribeFromTopic('daily_liturgy')`).
- Captura de clique na notificação em background (`FirebaseMessaging.onMessageOpenedApp`) e cold-start (`_messaging.getInitialMessage()`), despachando a navegação reativa via `GoRouter` com fallback padrão seguro para o Dashboard Litúrgico (`/`).

### 2.3. Seletor de Horário Litúrgico na UI
- **`DailyReminderInviteDialog`:** Convertido para `StatefulWidget`, renderizando um seletor visual de horário com estilo sacro (padrão `07:00`) e botão *"Alterar"* acionando o `showTimePicker`. Ao aceitar, solicita permissões, agenda o alarme local no horário escolhido, subscreve ao tópico `daily_liturgy` e persiste as preferências (`reminder_hour`, `reminder_minute`).
- **`ProfilePage`:** Quando o switch de lembretes está ativo, exibe o cartão informativo interativo com o horário configurado, permitindo alterá-lo com reagendamento automático imediato. Ao desativar, cancela os alarmes locais e revoga a inscrição no tópico FCM.

### 2.4. Internacionalização Plena em 18 Idiomas
- Registro simultâneo de 6 novas chaves nos **18 catálogos ARB** (`app_pt.arb`, `app_en.arb`, `app_es.arb`, `app_it.arb`, `app_fr.arb`, `app_de.arb`, `app_la.arb`, `app_pl.arb`, `app_nl.arb`, `app_ar.arb`, `app_hi.arb`, `app_ja.arb`, `app_ko.arb`, `app_sw.arb`, `app_tl.arb`, `app_uk.arb`, `app_vi.arb`, `app_zh.arb`) com `@metadados` estritos validados por teste automatizado (`arb_integrity_test.dart`).

---

## 3. Consequências e Benefícios

- **FinOps Clearance:** Custo operacional de **\$0.00** permanente. Notificações locais rodam 100% no hardware do cliente; FCM não cobra por volume de mensagens nem tópicos.
- **Confiabilidade:** O fiel que ativar o lembrete receberá o chamado à oração com pontualidade diária mesmo em modo avião ou sem rede.
- **Compatibilidade Retroativa:** Campanhas enviadas pelo Firebase Console segmentadas por "Aplicativo" alcançam todas as versões instaladas; futuras campanhas automatizadas podem atingir instantaneamente o tópico `daily_liturgy`.
- **Qualidade de Código:** 100% dos testes unitários e de widget aprovados e 0 advertências no `flutter analyze`.
