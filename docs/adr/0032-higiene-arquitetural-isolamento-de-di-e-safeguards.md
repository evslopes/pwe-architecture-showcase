# ADR 0032 — Higiene Arquitetural, Isolamento de Injeção de Dependências e Salvaguardas de Debug

**Data:** 04 de Outubro de 2026  
**Status:** 🟢 Aceito  
**Autores:** Arquiteto de Software Principal  

---

## 1. Contexto

A auditoria de maturidade arquitetural e de código identificou três oportunidades de refatoração para robustecer a Clean Architecture do projeto:

1. **Acoplamento em `security_vault`:** O `VaultSecurityBloc` dependia diretamente da interface de infraestrutura `IUserKeyVaultService` e estava registrado manualmente no container central `core/di/injection_container.dart`, violando o ADR 0004 ("Contêineres de DI isolados por feature; core cego às features").
2. **Duplicação de Contrato Vetorial:** Existia um arquivo órfão `lib/features/lectio_divina/domain/datasources/vector_search_datasource.dart` duplicando o contrato canônico `domain/services/vector_search_datasource.dart`.
3. **Simuladores de Debug Sem Guarda em Domínio:** Os use cases `SimulateTrialStatusUseCase`, `SimulateZeroOcrQuotaUseCase` e `ResetSubscriptionStatusUseCase` eram protegidos apenas na camada de apresentação (`if (kDebugMode)`), deixando o domínio desprotegido contra chamadas acidentais em produção.
4. **Pendências de Lojas Desacopladas:** As pendências de publicação nas lojas dependentes de contas Google e Apple necessitavam de formalização em backlog de Sprint dedicado.

---

## 2. Decisão

1. **Estruturação Clean Architecture em `security_vault`:**
   - Criada a entidade `VaultSecurityInfo` e a interface de repositório `IVaultSecurityRepository` em `domain/`.
   - Criados os use cases: `GetVaultSecurityInfoUseCase`, `SetVaultPassphraseUseCase`, `UnlockVaultPassphraseUseCase` e `RemoveVaultPassphraseUseCase`.
   - Implementado o repositório `VaultSecurityRepositoryImpl` em `data/repositories/`.
   - Refatorado o `VaultSecurityBloc` para orquestrar os use cases e emitir estados com base no padrão funcional `Either<Failure, T>`.
   - Criado o container dedicado `security_vault_injection_container.dart`. O container central `core/di/injection_container.dart` foi limpo e delega para `initSecurityVaultInjection()`.

2. **Purga de Código Duplicado:**
   - Removido o arquivo órfão `vector_search_datasource.dart` e o diretório `domain/datasources/`. O contrato canônico reside em `domain/services/vector_search_datasource.dart`.

3. **Salvaguarda de Segurança em Usecases de Simulação:**
   - Inserida verificação explícita `if (!kDebugMode)` nos três use cases de simulação da feature `subscription`, retornando `Left(PermissionFailure('Operação de simulação permitida exclusivamente em modo de desenvolvimento.'))`.

4. **Formalização da Sprint de Lojas:**
   - Criado o plano executivo `docs/sdlc/sprint_store_readiness.md`, integrado ao `docs/product/roadmap.md`, detalhando todas as tarefas que aguardam a aquisição das contas Google Play e Apple Developer.

---

## 3. Consequências

- **Positivas:** 100% das features agora possuem injeção de dependência encapsulada e isolada do core. O domínio da aplicação está blindado contra manipulação indevida de dados de assinatura fora de debug.
- **Rastreabilidade e Testes:** Criada suíte completa de testes unitários para a camada de domínio e dados de `security_vault`, elevando a cobertura da feature para 100%.
