# ADR 0036 — Landing Page Estática e Vitrine Institucional para SEO e Lojas

**Data:** 06 de Outubro de 2026  
**Status:** 🟢 Aceito  
**Autores:** Arquiteto de Software Principal, FinOps & Engenheiro de Software Sênior  

---

## 1. Contexto

A auditoria de transformação do aplicativo pwE em produto identificou que o domínio público web apontava diretamente para o bundle do Flutter Web (`build/web`), que por sua vez exibia uma tela de restrição de degustação (`WebAccessRestrictedPage`) para usuários externos.

Isso gerava três impedimentos fundamentais:
1. **Ineficiência de SEO e Motores de Busca:** O Flutter Web renderiza elementos gráficos via CanvasKit/WASM, tornando o rastreamento e indexação de palavras-chave ("Lectio Divina", "Liturgia Diária Católica", "Caderno Espiritual") pelo Googlebot e Bing praticamente inviável.
2. **Tempo de Carregamento e Fricção Mobile:** Usuários que clicam em links no WhatsApp, Instagram ou paróquias em redes 3G/4G tinham de aguardar o download de 3MB a 5MB de binários JavaScript/WASM antes de ver qualquer conteúdo institucional.
3. **Pré-requisito das Lojas (Apple e Google):** Ambas as lojas exigem URLs públicas acessíveis via navegador padrão para os Termos de Uso (EULA) e Política de Privacidade na ficha de publicação, bem como metatags OpenGraph limpas para compartilhamento social.

---

## 2. Decisão

### 2.1 Arquitetura Desacoplada: Portal Estático Dedicado (`landing/`)
1. **Páginas 100% Estáticas:** Construção de uma vitrine pública em HTML5 semântico, CSS3 sacro e Vanilla JS, com peso total inferior a **150 KB** e tempo de resposta inferior a **300ms**.
2. **Tokens Visuais Sagrados:**
   - Paleta em Pergaminho Nobre (`#FAF7F0` / `#12100E`), Ouro Litúrgico (`#C5A059`) e Carmesim Sacro.
   - Tipografia solene com as fontes Google **Cinzel** (títulos clássicos), **Lora** (citações patrísticas e bíblicas) e **Inter** (leitura contemporânea).
   - Mockup com moldura nobre apresentando o ícone bizantino de Cristo Pantocrator.
3. **Seções de Comunicação e Conversão:**
   - *Hero Section:* Promessa de valor clara com botões de download (Google Play, App Store e acesso à Versão Web).
   - *Citação Patrística:* Exortação de Bento XVI (*Verbum Domini*).
   - *Os 4 Degraus da Lectio Divina:* Explicação pedagógica de Lectio, Meditatio, Oratio e Contemplatio.
   - *Pilares Sacros:* Cânon Católico CNBB (73 livros), Criptografia AES-256 e Zero Anúncios.
   - *Círculo de Benfeitores:* Comunhão de bens e garantia da gratuidade perpétua da Liturgia.
   - *Perguntas Frequentes (FAQ):* Respostas a objeções comuns em formato sanfona suave.
4. **Páginas Legais Públicas:**
   - `terms.html`: Termos de Uso e EULA com tolerância zero a abusos (Apple Guideline 1.2).
   - `privacy.html`: Política de Privacidade detalhando criptografia do Caderno Espiritual e exclusão de dados (LGPD/GDPR/Google Play).
5. **SEO & Indexabilidade:**
   - Inclusão de `robots.txt`, `sitemap.xml`, OpenGraph completo para WhatsApp e marcação Schema.org (`SoftwareApplication` em JSON-LD).

---

## 3. Consequências

- **Impacto em Aquisição e SEO:** Carregamento instantâneo, pontuação 100 no Google PageSpeed Insights e indexação de alta relevância orgânica para buscas católicas.
- **Prontidão de Lojas:** Disponibilização imediata das URLs canônicas (`https://praywithme.app/terms.html` e `https://praywithme.app/privacy.html`) exigidas no App Store Connect e Google Play Console.
- **FinOps e Custo Zero:** Hospedagem em CDN global estática no Firebase Hosting com consumo irrelevante dentro da cota gratuita perpétua (*Spark Plan*).
