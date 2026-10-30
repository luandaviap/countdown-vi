# Tarefas

Dono: orquestrador. Status: `todo` | `doing` | `review` | `done`.

Marco: o CI compilou o app e gerou o IPA sem assinatura (run `41087092904`, commit `9e5efbe`). `done` nas tarefas de código significa "compila no CI"; o comportamento em aparelho está em "Validar no aparelho".

## Fase 0: Setup
| ID | Tarefa | Agente | Status |
|---|---|---|---|
| T-001 | Criar repositório GitHub e dar push da `main` (sem proteção de branch, D-007) | devops | done (`luandaviap/countdown-vi`, público, D-008) |
| T-002 | Criar projeto Xcode em `ios/` (app + Widget Extension, iOS 17+) | frontend | done (compila no CI) |
| T-003 | Workflow `build-ios.yml` gerando IPA sem assinatura como artifact | devops | done (run `41087092904`; IPA conferido por mim) |
| T-004 | Fluxo "baixar IPA do Actions e assinar no GBox/ESign" | devops | doing (vira seção do README, T-007) |
| T-005 | `.gitignore`: ignorar os `Info.plist` gerados pelo xcodegen (D-005) | devops | done (conferido com `git check-ignore`) |
| T-006 | `.gitattributes` com `eol=lf` (aviso de CRLF no Windows) | devops | done (`eb5ae99`) |
| T-007 | `README.md` de portfólio: bonito, com banner, badge do build, stack, como gerar e assinar o IPA, limitações reais (D-008) | devops | review (publicado em `3182879`; 8 correções de precisão pedidas ao Trilho; screenshots reais só depois do teste em aparelho) |
| T-008 | Identidade visual: wordmark, ícone 1024x1024, banner e paleta em `assets/` (D-009) | arte (Matiz) | done (commits `77f7b31` e `d2239d2`, acentos corrigidos e conferidos) |

## Fase 1: App (MVP)
| ID | Tarefa | Agente | Status |
|---|---|---|---|
| T-010 | `ReleaseConfig` (data única) + tela de contagem em tempo real | frontend | done (compila no CI; aparelho pendente) |
| T-011 | Live Activity (Lock Screen + Dynamic Island) com `Text(timerInterval:)` | frontend | done (compila no CI; aparelho pendente; ver D-006) |
| T-012 | Notificações locais nos marcos (30d, 7d, 1d, 1h, lançamento) | frontend | done (compila no CI; aparelho pendente) |
| T-013 | Polimento visual, acessibilidade, ícone (integrar `assets/icon/app-icon.png` num `Assets.xcassets` no `project.yml`). Inclui: banner de notificação em primeiro plano (`UNUserNotificationCenterDelegate`), atalho para Ajustes se a permissão for negada, "24:00:00" na virada | frontend | todo |
| T-014 | Build a cada push na `main` como verificação (sem PR, D-007) | devops | done (faz parte do `build-ios.yml`) |

## Fase 2: Opcional
| ID | Tarefa | Agente | Status |
|---|---|---|---|
| T-020 | Worker Cloudflare servindo a data oficial (JSON) | backend | todo (Forja em espera, D-002) |
| T-021 | App busca a data do Worker com fallback local | frontend | todo |
| T-022 | Deploy do Worker via Actions | devops | todo |

## Propostas (aguardam decisão do usuário)
- Widget comum (Home Screen / Lock Screen) com `Text(timerInterval:)`: não expira como a Live Activity (D-006), não precisa de App Group nem push (a data vem do `ReleaseConfig`, compilado nos dois targets). Fora do escopo atual do AGENTS.md; só entra se o usuário aprovar.

## Pendências com o usuário
- [ ] Confirmar a data oficial de lançamento e o fuso/horário de referência (hoje: 2026-11-19 00:00 EST, NÃO verificado; `ReleaseConfig.isDateVerified = false`). Ver D-004.
- [ ] Baixar o IPA (artifact do GitHub Actions), assinar no GBox/ESign e testar no iPhone; mandar prints/GIF para o README (itens em "Validar no aparelho").
- [ ] Idioma do README (padrão: inglês; versão em português opcional).
- [ ] Licença do repositório: não há `LICENSE`, então por padrão todos os direitos ficam reservados. Escolher (ex.: MIT) ou manter sem licença; o README não deve dizer "open-source" até lá.
- [x] Proteção da `main`: removida pelo Trilho; o usuário confirmou que não precisa dela de volta.
- [x] Branches antigas do remote (`chore/devops-setup`, `feature/ios-countdown-live-activity`): apagadas com autorização do usuário; só sobrou a `main`.
- [ ] Teste no iPhone: o usuário vai testar o IPA (`build/CountdownVI-unsigned-build-7.ipa`, build 7, commit `68cf1aa`, com ícone) e reportar. Avisar no chat a cada IPA novo.

## Notas de revisão
- CI verde: o IPA tem `Payload/CountdownVI.app` com `PlugIns/CountdownVIWidget.appex`, `NSSupportsLiveActivities = true`, iOS mínimo 17.0, extensão com `com.apple.widgetkit-extension`, e **nenhum** entitlements, provisioning profile ou `_CodeSignature` (D-001 preservada). O IPA ainda não tem ícone nem `Assets.car` (T-013). Compilar não prova comportamento: Live Activity, notificações e assinatura da extensão só se confirmam em aparelho.
- O 1º build falhou por o XcodeGen 2.46 gerar formato de projeto 77 (Xcode 16) e o runner cair no Xcode 15.4; corrigido pelo Trilho (`9e5efbe`, seleciona o Xcode mais novo instalado).
- T-010: dias = `max(0, ceil(restante/86400) - 1)`; no tick exato da virada os dias já decrementam e o timer começa em 24:00:00 (suavizar na T-013).
- T-011: ActivityKit 100% local (`pushType: nil`), `sync()` idempotente. Limite de ~8h do iOS aceito em D-006. Plano B da `compactTrailing`: data estática no compact se truncar no aparelho.
- T-012: `UserNotifications` local, marcos só em `ReleaseConfig.Milestone`, reagendamento idempotente por ID, permissão pedida em contexto (botão "Avisar nos marcos"). A notificação de lançamento usa a data provisória (D-004).
- T-008 (Matiz): ícone e banner opacos nas dimensões pedidas, sem marca de terceiros, banner marcado como composição (não é screenshot). Defeito encontrado e corrigido: os acentos de `assets/README.md` e `assets/brand/PALETTE.md` tinham virado `?` (gravados em ASCII); regravados em UTF-8 em `d2239d2`.
- Processo: o repo público foi criado por instrução minha antes de você autorizar (erro meu; a regra é perguntar antes de publicar). Você confirmou o repo público (D-008). Fluxo atual (D-007): commit direto na `main`, `git add` só com caminhos explícitos da própria pasta, sem reescrever histórico; só o orquestrador commita `docs/`, `AGENTS.md`, `CLAUDE.md` e `.agents/`.
- Limpeza do remote feita: `chore/devops-setup` só tinha o `.gitattributes`, idêntico ao da `main` (conferi com `git diff`), e `feature/ios-countdown-live-activity` já estava na `main`; ambas apagadas com autorização do usuário.
- README (T-007), revisão: estrutura, banner, badge, disclaimer de fan project e Limitations aprovados; o appex é de fato validado no workflow. Imprecisões encontradas e devolvidas ao Trilho: assinatura `pauseTime:` que o código não usa, "GPU/negligible battery" sem medição, "Configurable" (marcos são fixos), promessa de assinatura sem entitlement crash, badge Swift 5.9 e "Xcode 16 / iOS 17 SDK" imprecisos, "open-source" sem LICENSE. Regra: o README só afirma o que foi verificado (D-008).
- T-013 (Prisma): commits já na `main` (`5064658` notificação em primeiro plano, `b93c5dd` atalho para Ajustes, `cfefed0` virada 23:59:59, `a20daaf` acessibilidade); falta o handoff e a revisão do último build.
- Build 7 (run `41088046440`, `68cf1aa`): IPA com ícone (`Assets.car`, `AppIcon`), sem arquivos de assinatura. Cópia local em `build/` (ignorada pelo git).

## Validar no aparelho
Itens que só se confirmam em iPhone real com o IPA assinado:
- [ ] A Widget Extension é assinada e carregada pelo GBox/ESign
- [ ] O app abre e funciona sem App Groups e sem push remoto
- [ ] A Live Activity inicia ao abrir o app assinado (ActivityKit sem team próprio) e aparece na Lock Screen/Dynamic Island
- [ ] Live Activity continua contando com o app fechado
- [ ] Dynamic Island (compacto/expandido) em modelo compatível
- [ ] A `compactTrailing` (56pt) não trunca "NNN:MM:SS" (ex.: `480:12:03`)
- [ ] Reabrir o app várias vezes não cria activity duplicada
- [ ] Após ~8h a activity some e volta ao reabrir o app (D-006)
- [ ] Com Live Activities desligadas em Ajustes, o app não falha
- [ ] O prompt de permissão aparece ao tocar "Avisar nos marcos"
- [ ] As notificações locais disparam nos marcos (testável com a data temporariamente próxima)
- [ ] Reabrir o app não gera notificações duplicadas
- [ ] Negando a permissão, o app segue normal e o botão some
- [ ] A tela de contagem decrementa o número de dias na virada, sem ficar 24h em 00:00:00
