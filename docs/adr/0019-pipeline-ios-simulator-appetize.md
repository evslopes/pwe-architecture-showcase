# ADR 0019 — Pipeline de Homologação Visual iOS no Appetize.io via Simulator Build

**Data:** 01 de Outubro de 2026  
**Status:** 🟢 Aceito e Homologado  
**Autores:** Arquiteto de Software Principal, Especialista `devops`, Especialista `engineer`, Especialista `flutter-ui`, Especialista `qa`  
**Branch Relacionada:** `deploy_ios_simulator_appetize`  

---

## 1. Contexto & Problema

O **pwE (Pray With Me)** é um aplicativo católico multiplataforma (Android e iOS). Durante as rotinas de garantia de qualidade (QA) e revisão de design sacro, a validação de interfaces de usuário (UI) e a experiência imersiva na plataforma iOS apresentavam barreiras operacionais e financeiras:

1. **Dependência de Hardware Apple Físico:** Desenvolvedores e testadores que utilizam estações de trabalho Linux ou Windows enfrentam dificuldades para executar simulações interativas locais de iOS.
2. **Ausência de Apple Developer Program Pago ($99/ano):** Contas de desenvolvedor individuais sem adesão ao programa pago da Apple não possuem acesso a certificados de distribuição para dispositivos físicos nem ao Apple TestFlight.
3. **Validação Rápida em Pull Requests:** A equipe de produto e design necessita validar alterações de UI em iOS diretamente no navegador antes de mesclar branches de funcionalidade em `develop`.

---

## 2. Decisão Arquitetural

Decidiu-se pela criação de uma pipeline automatizada no GitHub Actions (`.github/workflows/ios-simulator-appetize.yml`) voltada à compilação do aplicativo Flutter para a arquitetura de **Simulador iOS** e despacho do artefato para a nuvem do **Appetize.io**:

### A. Compilação para Simulador sem Assinatura Apple
- **Target Arquitetural:** O comando `flutter build ios --simulator --debug --no-codesign` compila o código Dart e dependências nativas para a arquitetura do simulador (x86_64 / arm64).
- **Isenção de Assinatura:** Sob as variáveis de ambiente `CODE_SIGNING_ALLOWED=NO` e `CODE_SIGNING_REQUIRED=NO`, o Xcode dispensa completamente certificados da Apple, perfis de provisionamento e IDs pagos no Apple Developer Program.

### B. Empacotamento Preservando Links Simbólicos
- O diretório `Runner.app` gerado em `build/ios/iphonesimulator/` é compactado no arquivo `Runner.zip` utilizando o utilitário `zip -r -y`, preservando obrigatoriamente os symlinks internos exigidos pelo ecossistema Apple e pela plataforma Appetize.io.
- O artefato `.zip` é arquivado temporariamente nos artefatos do GitHub Actions via `actions/upload-artifact@v4`.

### C. Integração e Publicação via API REST do Appetize.io
- O arquivo compactado é enviado via requisição HTTP POST multipart para o endpoint `https://api.appetize.io/v1/apps`.
- A autenticação é realizada de forma segura através do segredo `secrets.APPETIZE_API_TOKEN`, sem qualquer exposição de chaves no repositório.
- A resposta em JSON é processada com `jq` para extração da `publicKey` e da URL interativa de visualização (`appUrl`).

### D. Observabilidade e Feedback Direto no GitHub CI
- O link interativo do simulador web é injetado diretamente no **GitHub Step Summary** (`$GITHUB_STEP_SUMMARY`) com uma tabela de metadados da compilação.
- Em execuções originadas de **Pull Requests**, um bot publica automaticamente um comentário com o link direto para teste no PR.

---

## 3. Consequências & Benefícios

- **Custo Zero de Licenciamento Apple:** A equipe viabiliza homologações visuais e testes funcionais em iOS sem necessidade da anuidade do Apple Developer Program.
- **Independência de Hardware:** Desenvolvedores e designers podem interagir com a aplicação em um simulador iOS fiel diretamente no navegador web.
- **Segurança e DevSecOps:** Token de API protegido via GitHub Secrets e binário temporário retido conforme as políticas de ciclo de vida de artefatos.
