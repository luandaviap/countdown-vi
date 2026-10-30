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

## D-006: Live Activity expira em ~8h; limitação aceita (2026-10-30)
**Contexto:** o iOS encerra uma Live Activity após cerca de 8h ativa (ela pode ficar até ~4h a mais na Lock Screen), e `Activity.request` só funciona com o app em primeiro plano. Sem push remoto (D-001), nada reinicia a activity em segundo plano.
**Decisão:** o app inicia a activity ao ficar ativo (`LiveActivityController.sync()`, idempotente) e ela volta quando o usuário reabre o app. Não tentamos contornar o limite. As notificações locais (T-012) cobrem os marcos.
**Porquê:** contornar exigiria push (APNs) ou capabilities que a assinatura de terceiros não carrega, o que quebra a D-001.
**Consequência:** a Live Activity não conta por semanas sozinha. Para exibição contínua, existe a proposta do widget comum (ver "Propostas" em `docs/TASKS.md`), que depende do usuário.
