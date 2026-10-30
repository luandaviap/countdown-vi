# Decisões

## D-001: IPA sem assinatura gerado no CI; assinatura feita pelo usuário (2026-10-30)
**Contexto:** desenvolvimento no Windows, sem Mac. O usuário assina o IPA com GBox/ESign.
**Decisão:** o GitHub Actions (runner macOS) gera um IPA sem assinatura. O app não depende de push remoto, App Groups ou outras capabilities que exijam provisioning próprio. Live Activity e notificações são locais.
**Porquê:** assinatura de terceiros normalmente não carrega os entitlements necessários para esses recursos. Manter tudo local reduz o risco de o app não funcionar no aparelho.
**Risco/validar:** a Widget Extension precisa ser assinada junto com o app; confirmar em aparelho real (ver "Validar no aparelho" em `docs/TASKS.md`). Se o fluxo de assinatura não suportar extensões, reavaliar.

## D-002: Back-end é opcional e fica para a fase 2 (2026-10-30)
**Decisão:** a contagem e as notificações rodam 100% no aparelho. O Worker só serve a data oficial (JSON) para permitir atualizá-la sem nova versão.
**Porquê:** menos peças, menos pontos de falha; ainda assim dá um diferencial para o portfólio.

## D-003: AGENTS.md é a fonte única de verdade (2026-10-30)
**Decisão:** `AGENTS.md` concentra escopo e regras; `CLAUDE.md` o importa. Regras específicas ficam em `.agents/<agente>.md`.
**Porquê:** Claude, Codex e Antigravity leem `AGENTS.md`, então todos partem das mesmas regras.

## D-004: Data de lançamento é um instante único e provisório (2026-10-30)
**Decisão:** `ReleaseConfig` guarda um único instante ISO 8601 (`2026-11-19T00:00:00-05:00`) com `isDateVerified = false`. A UI mostra "Data provisória" enquanto a flag for `false`.
**Porquê:** não inventar fatos (AGENTS.md). A data e a suposição de 00:00 EST ainda não foram confirmadas. Um instante único é a forma mais simples; lançamentos costumam ser à meia-noite local de cada região, então isso é uma aproximação.
**Pendente:** o usuário confirmar data e fuso. Só então virar `isDateVerified = true` e preparar um release.

## D-005: Arquivos gerados pelo xcodegen não são versionados (2026-10-30)
**Decisão:** `ios/project.yml` é a fonte; `ios/*.xcodeproj` e os `Info.plist` gerados (`ios/CountdownVI/Info.plist`, `ios/CountdownVIWidget/Info.plist`) vão para o `.gitignore`. O CI roda `xcodegen generate` antes do `xcodebuild`.
**Porquê:** evita diffs ruidosos e conflitos em arquivos gerados; sem Mac local, o CI é quem sempre gera o projeto.
**Risco:** sem Xcode no Windows, erros do `project.yml` só aparecem no CI. Reavaliar se isso atrapalhar.

## D-007: Trabalho direto na `main`, sem branches, worktrees nem PRs (2026-10-30)
**Contexto:** o fluxo com branches `feature/*`, PRs e `main` protegida foi adotado no início. Com 3 agentes dividindo uma pasta, gerou worktrees extras, rebases e commits cruzados.
**Decisão:** por pedido do usuário, todos commitam e dão push direto na `main`. Sem branch de feature, sem worktree, sem PR, sem proteção de branch.
**Porquê:** é um projeto de portfólio pequeno; o custo do fluxo com PR supera o benefício.
**Guarda-corpos:** `git add` só com caminhos explícitos da própria pasta; sem reescrever histórico; só o orquestrador commita `docs/`, `AGENTS.md`, `CLAUDE.md` e `.agents/`; o CI (build do IPA) passa a ser a verificação de que a `main` compila.
**Risco:** a `main` pode quebrar; mitigado pelo build do CI a cada push. Substitui a regra anterior de "nada direto na `main`".

## D-008: Repositório GitHub público, com README de portfólio (2026-10-30)
**Contexto:** o Trilho criou `luandaviap/countdown-vi` como público por instrução minha, antes de eu ter perguntado ao usuário. O usuário então confirmou.
**Decisão:** o repositório fica **público** (nome `countdown-vi`), porque o projeto é peça de portfólio. O `README.md` é entregável de primeira classe: bonito, com screenshots e GIF do app.
**Porquê:** o valor do projeto é ser visto. Como o repo é público, nunca vão segredos, certificados nem IPAs assinados para ele (ver `.gitignore`).
**Regras do README:** não inventar fatos nem imagens. Screenshots só de execução real (simulador ou aparelho); até existirem, usar placeholders claramente marcados. Não afirmar que o build ou a Live Activity funcionam enquanto o CI e o aparelho não confirmarem. Mostrar a data como provisória enquanto `isDateVerified = false` (D-004).

## D-009: Agente de Arte (Matiz, Codex) cuida das imagens do README e da marca (2026-10-30)
**Contexto:** o usuário pediu um agente (modelo GPT Terra) para banner, logo, ícone e imagens do README.
**Decisão:** novo agente **Matiz** (papel `cvi-arte`, Codex, modelo `gpt-6.1-terra` medium só na sessão, YOLO mode). Dono da pasta `assets/`; regras em `.agents/art.md`. O texto do README continua com o DevOps (T-007); a integração do ícone no Xcode é do front-end (T-013).
**Porquê:** separa a produção visual do código; o repo é público e de portfólio (D-008).
**Regras:** imagem gerada nunca é passada como screenshot real (prefixos `concept-`/`mockup-`; screenshots reais só do usuário); sem logotipo, arte ou marca oficial da Rockstar/GTA (repo público, arte original); sem data de lançamento como fato em imagem (D-004).
**Nota:** o modelo foi escolhido no menu do Codex como "GPT-6.1 Terra", a opção mais próxima do "GPT 6 Terra" pedido; trocar com `/model` se o usuário preferir outro.

## D-010: A tela do app recalcula a cada segundo; só a Live Activity usa `Text(timerInterval:)` (2026-10-30)
**Decisão:** na tela principal, dias e relógio saem do mesmo total de segundos inteiros, atualizado por `TimelineView(.periodic(by: 1))` ancorado a segundos inteiros antes de `releaseDate`. A Live Activity continua com `Text(timerInterval:)`.
**Porquê:** garante que o relógio vá de 00:00:00 a 23:59:59 (nunca 24:00:00) e que dias e relógio nunca divirjam, sem depender de como `Text(timerInterval:)` arredonda (não dá para conferir sem aparelho). Na Live Activity, `Text(timerInterval:)` é obrigatório: é o que o sistema atualiza sem o app (D-001).
**Custo:** 1 render por segundo, só com o app em primeiro plano. Sem servidor, sem push. D-001 intacta.

## D-011: O README pode usar mockups gerados pelo Matiz, sempre rotulados como mockup (2026-10-30)
**Contexto:** o usuário não quer ter de enviar prints; pediu que o Matiz gere as imagens do README.
**Decisão:** imagens renderizadas pelo Matiz entram no README, **legendadas como mockup renderizado, nunca como screenshot**. Arquivos com prefixo `mockup-`. Isso altera a regra anterior da D-009 (screenshots só do usuário): prints reais continuam bem-vindos se o usuário quiser, mas não são mais pré-requisito.
**Porquê:** o repositório é de portfólio e precisa de imagens; a honestidade vem do rótulo, não de proibir o mockup.
**Guarda-corpos:** sem afirmar que a imagem é o app rodando; o mockup deve seguir o design implementado (ou marcar "proposta de design" se ainda não estiver no app).

## D-012: Direção de design v2, "pôr do sol neon com vidro" (2026-10-30)
**Contexto:** o usuário trouxe uma referência gerada com GPT (`docs/design/reference-sunset-countdown.png`): fundo em gradiente roxo, magenta e laranja, quatro blocos de vidro (dias, horas, minutos, segundos), barra de progresso, botão em gradiente, cena de pôr do sol com palmeiras e skyline, e ícone de palmeira com "19d" na Dynamic Island.
**Decisão:** adotar essa direção para a tela, a Live Activity e o widget. O Matiz entrega tokens, uma cena em vetor original e mockups; só depois de o usuário aprovar o Prisma implementa (T-018).
**Pontos abertos (propostas):** nome na tela sem "Leonida" (estado fictício, marca da Rockstar), mantendo "GTA VI"/"Countdown VI"; barra de progresso sobre os últimos 30 dias até o lançamento; botão "Ativar Live Activity" visível quando não há activity ativa.
**Restrições:** arte original (sem logotipo nem arte oficial da Rockstar/GTA); sem fonte sem licença embutida (usar fontes do sistema, ex.: largura condensada); a data segue provisória na UI (D-004); D-001 intacta. Na Dynamic Island, "19d" é um instantâneo estático (o texto que se atualiza sozinho é o de timer); aceitável dada a vida de ~8h da activity, a validar.
**Porquê:** o app hoje é preto e branco e não conversa com o ícone e o banner; a referência dá identidade sem exigir nenhum recurso novo de assinatura.

## D-013: Widget comum aprovado (resolve a consequência da D-006) (2026-10-30)
**Decisão:** o usuário aprovou um widget comum (Home Screen e Lock Screen) na mesma Widget Extension. Usa `TimelineProvider` com entradas pré-calculadas a cada virada de dia até o lançamento e `Text(timerInterval:)` para o relógio; a data vem do `ReleaseConfig` compilado nos dois alvos.
**Porquê:** diferente da Live Activity, o widget não expira em ~8h e não precisa de push, App Groups nem entitlements (D-001 intacta).
**Risco:** a extensão é a mesma já carregada pelo assinador (a Live Activity apareceu no aparelho), mas o widget em si ainda precisa ser validado no aparelho.

## D-014: Servidor de data por região fica para depois; Forja em espera (2026-10-30)
**Contexto:** o usuário quer, "logo mais", um servidor que entregue a data e a hora conforme a região da pessoa. Isso antecipa a fase 2 da D-002 (T-020 e T-021).
**Decisão:** por enquanto a data segue provisória e local (D-004). Antes de a Forja começar, preciso do usuário: fonte oficial da data, conta Cloudflare para o deploy e a regra por região (um instante único ou horário local de cada região).
**Porquê:** sem a data oficial o servidor só serviria o mesmo valor não verificado. A D-001 não impede: buscar JSON por HTTP não exige entitlement.

## D-015: Texto da tela com tema "Leonida", por decisão do usuário (2026-10-30)
**Contexto:** a referência de design usava "LEONIDA COUNTDOWN". Avisei que Leonida é o estado fictício do jogo, ligado à marca da Rockstar. O usuário decidiu usar o tema mesmo assim, com frases como "Esperando por Leonida" e "Dias para viajar para Leonida". O usuário também aprovou (por leitura minha de "Decisão aprovada") a direção de design v2, o fundo gerado por IA e as 3 propostas (barra de 30 dias, botão "Ativar Live Activity", "19d" fixo na ilha compacta).
**Decisão:** título da tela "Esperando por Leonida" e linha secundária "Dias para viajar para Leonida"; Live Activity e widgets seguem com "GTA VI" nas superfícies curtas. Todo o texto de interface fica concentrado em um único lugar no código, para trocar fácil.
**Guarda-corpos:** só referência em texto; nenhum logotipo, arte, personagem ou material oficial da Rockstar/GTA; o aviso de projeto de fã sem afiliação continua no README; arte original (D-009). O risco de marca é do usuário; o repositório é público (D-008).

## D-016: Live Activity mostra dias (opção 1) e testa texto relativo (opção 2) (2026-10-30)
**Contexto:** `Text(timerInterval:)` só mostra horas totais (ex.: 468:33:19). O usuário aprovou as opções 1 e 2.
**Decisão:** (1) manter o timer de horas totais e acrescentar um rótulo fixo "N dias", calculado ao criar/atualizar a activity, com `staleDate` na próxima virada de dia; quando `context.isStale`, o rótulo some e fica só o timer (nunca exibe dia errado); o app recria o rótulo ao abrir. Compacta da ilha: ícone de palmeira e "Nd" fixo, com a mesma regra. (2) Experimento: uma linha extra com `Text(releaseDate, style: .relative)`, marcada como temporária no código, para ver no aparelho se o iOS mostra dias sozinho.
**Porquê:** sem push (D-001), nada reescreve um valor fixo em segundo plano; `staleDate` garante que o fixo nunca fique errado. A vida da activity (~8h, D-006) limita o pior caso a uma virada.
**Risco:** o formato do texto relativo (idioma, unidades, arredondamento) só se vê no aparelho; se não servir, remover o experimento.

## D-017: A Widget Extension precisa de perfil de provisionamento próprio; causa da falha no build 16 (2026-10-30)
**Contexto:** no build 15/16, instalado limpo, nem a Live Activity nem o widget apareciam. A linha de diagnóstico (T-027) mostrou: app `assinatura sim, perfil sim`; extensão `com.countdownvi.app.widget [prefixo ok, assinatura sim, perfil não]`; `Live Activities permitidas: sim`, `1 active`, `último erro: nenhum`.
**Decisão:** tratar como problema de assinatura, não de código: o app cria a Live Activity, mas o iOS não carrega uma extensão sem `embedded.mobileprovision` próprio, então nada desenha a activity nem lista o widget. O assinador precisa assinar a extensão com um perfil que cubra `com.countdownvi.app.widget`: perfil curinga (App ID terminando em `*`) ou perfis separados (ex.: Sideloadly com Apple ID, que cria os dois).
**Porquê:** é o risco que a D-001 já registrava ("a Widget Extension precisa ser assinada junto com o app; se o fluxo de assinatura não suportar extensões, reavaliar"). O código e o empacotamento são idênticos aos do build 10 (arquivos, Info.plist, arquitetura), e o app não reporta erro.
**Atualização:** o usuário usa o GBox e diz que o certificado é o mesmo do build 10, que funcionou. Isso enfraquece a explicação "o perfil não cobre a extensão": ou o build 10 não tinha extensão válida de fato, ou algo no empacotamento dos builds novos faz o GBox assinar a extensão sem perfil. Certeza: média (antes dizia alta). **Pendente:** o usuário instalar o build 10 agora e dizer se a Live Activity aparece; se aparecer, comparar o que muda para o GBox (ex.: build com a linha de diagnóstico sobre o código do build 10). Só se confirma quando o widget aparecer. O README e o guia de instalação (T-004) devem dizer que o perfil precisa ser curinga. Sem extensão assinada, o app abre e conta normalmente, mas sem Live Activity nem widget. A linha de diagnóstico sai depois da confirmação.

## D-006: Live Activity expira em ~8h; limitação aceita (2026-10-30)
**Contexto:** o iOS encerra uma Live Activity após cerca de 8h ativa (ela pode ficar até ~4h a mais na Lock Screen), e `Activity.request` só funciona com o app em primeiro plano. Sem push remoto (D-001), nada reinicia a activity em segundo plano.
**Decisão:** o app inicia a activity ao ficar ativo (`LiveActivityController.sync()`, idempotente) e ela volta quando o usuário reabre o app. Não tentamos contornar o limite. As notificações locais (T-012) cobrem os marcos.
**Porquê:** contornar exigiria push (APNs) ou capabilities que a assinatura de terceiros não carrega, o que quebra a D-001.
**Consequência:** a Live Activity não conta por semanas sozinha. Para exibição contínua, existe a proposta do widget comum (ver "Propostas" em `docs/TASKS.md`), que depende do usuário.
