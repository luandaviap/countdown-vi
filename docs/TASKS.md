# Tarefas

Dono: orquestrador. Status: `todo` | `doing` | `review` | `done`.

## Fase 0: Setup
| ID | Tarefa | Agente | Status |
|---|---|---|---|
| T-001 | Criar repositório GitHub, `main` protegida, templates de PR | devops | doing (repo local + templates + commit `e57407d` prontos; falta remote GitHub e proteção da `main`) |
| T-002 | Criar projeto Xcode em `ios/` (app + Widget Extension, iOS 17+) | frontend | review (aguarda build no CI, T-003) |
| T-003 | Workflow `build-ios.yml` gerando IPA sem assinatura como artifact | devops | todo |
| T-004 | Documentar fluxo: baixar IPA do Actions, assinar no GBox/ESign | devops | todo |
| T-005 | `.gitignore`: ignorar os `Info.plist` gerados pelo xcodegen (D-005; `*.xcodeproj` já está) | devops | todo |
| T-006 | `.gitattributes` com `*.swift`, `*.yml`, `*.md` em `eol=lf` (aviso de CRLF no Windows) | devops | todo |

## Fase 1: App (MVP)
| ID | Tarefa | Agente | Status |
|---|---|---|---|
| T-010 | `ReleaseConfig` (data única) + tela de contagem em tempo real | frontend | review (bug da virada corrigido; aguarda build no CI) |
| T-011 | Live Activity (Lock Screen + Dynamic Island) com `Text(timerInterval:)` | frontend | review (UI + `LiveActivityController` prontos; aguarda build no CI; ver D-006) |
| T-012 | Notificações locais nos marcos (30d, 7d, 1d, 1h, lançamento) | frontend | todo |
| T-013 | Polimento visual, acessibilidade, ícone | frontend | todo |
| T-014 | Workflow de verificação em PR (build) | devops | todo |

## Fase 2: Opcional
| ID | Tarefa | Agente | Status |
|---|---|---|---|
| T-020 | Worker Cloudflare servindo a data oficial (JSON) | backend | todo |
| T-021 | App busca a data do Worker com fallback local | frontend | todo |
| T-022 | Deploy do Worker via Actions | devops | todo |

## Propostas (aguardam decisão do usuário)
- Widget comum (Home Screen / Lock Screen) com `Text(timerInterval:)`: não expira como a Live Activity (D-006), não precisa de App Group nem push (a data vem do `ReleaseConfig`, compilado nos dois targets). Fora do escopo atual do AGENTS.md; só entra se o usuário aprovar.

## Pendências com o usuário
- [ ] Confirmar a data oficial de lançamento e o fuso/horário de referência (hoje: 2026-11-19 00:00 EST, NÃO verificado; `ReleaseConfig.isDateVerified = false`). Ver D-004.

## Notas de revisão
- Handoff T-002/T-010/T-011 (Prisma): formato completo; D-001 respeitada (sem entitlements, App Groups, push; data só em `ReleaseConfig`). Não compilado (sem Xcode no Windows): só vale com o build do CI.
- T-010 (`CountdownView`), bug da virada de dia: corrigido (handoff do Prisma, revisado). Dias = `max(0, ceil(restante/86400) - 1)`; no tick exato da virada os dias já decrementam e o timer começa em 24:00:00. Aritmética exata (a data tem segundos inteiros), sem margem mágica. Só vale após o build do CI.
- T-011 (handoff do Prisma, revisado): ActivityKit 100% local, `pushType: nil`, sem entitlements/App Groups; `sync()` idempotente (reusa, encerra duplicatas, encerra após a data, tolera Live Activities desligadas). Git: branch `feature/ios-countdown-live-activity`, commits `c40b69c` e `467a6de`, sem push. Limite de ~8h do iOS aceito em D-006. Plano B da `compactTrailing`: data estática no compact se truncar no aparelho.
- Atenção: os agentes dividem a mesma pasta de trabalho, então trocar de branch afeta todos. Quem precisar de outra branch usa `git worktree`; `git add` só com caminhos explícitos da própria pasta.
- Cosmético para a T-013: no instante da virada aparece "24:00:00" por 1 segundo (coerente, mas pode ser suavizado deslocando a virada em 1s).
- Nomes estáveis para o CI (T-003): projeto `ios/CountdownVI.xcodeproj` (gerado por `cd ios && xcodegen generate`), scheme `CountdownVI`, targets `CountdownVI` e `CountdownVIWidget`, bundle IDs `com.countdownvi.app` e `com.countdownvi.app.widget`.
- Escopo: a entrega foi além da T-002 (cobre T-010 e a UI da T-011). Aceito desta vez; próximas vezes, entregar por tarefa.
- Repo git local existe (T-001, commit `e57407d` em `main`), mas sem remote GitHub e sem proteção da `main`. O handoff da T-001 veio incompleto (sem Arquivos, Como verificar e Pendências): complemento pedido ao Trilho. O `.gitignore` ainda não cobre os `Info.plist` gerados (T-005 / D-005). O código de `ios/` ainda não foi commitado: o frontend deve usar branch `feature/ios-*`.

## Validar no aparelho
Itens que só se confirmam em iPhone real com o IPA assinado:
- [ ] Live Activity inicia e continua contando com o app fechado
- [ ] Dynamic Island (compacto/expandido) em modelo compatível
- [ ] Notificações locais disparam nos horários
- [ ] A Widget Extension é assinada e carregada pelo GBox/ESign
- [ ] O app abre e funciona sem App Groups e sem push remoto
- [ ] A Live Activity aparece na Lock Screen/Dynamic Island com o app assinado sem team próprio
- [ ] Dynamic Island compacta: o tempo com horas totais (ex.: `480:12:03`) cabe sem cortar
- [ ] A activity inicia ao abrir o app assinado pelo GBox/ESign (ActivityKit sem team próprio)
- [ ] Reabrir o app várias vezes não cria activity duplicada
- [ ] A `compactTrailing` (56pt) não trunca "NNN:MM:SS" na Dynamic Island
- [ ] Após ~8h a activity some e volta ao reabrir o app (D-006)
- [ ] Com Live Activities desligadas em Ajustes, o app não falha
- [ ] A tela de contagem decrementa o número de dias na virada, sem ficar 24h em 00:00:00
