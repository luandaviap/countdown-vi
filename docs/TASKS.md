# Tarefas

Dono: orquestrador. Status: `todo` | `doing` | `review` | `done`.

## Fase 0: Setup
| ID | Tarefa | Agente | Status |
|---|---|---|---|
| T-001 | Criar repositório GitHub, `main` protegida, templates de PR | devops | todo |
| T-002 | Criar projeto Xcode em `ios/` (app + Widget Extension, iOS 17+) | frontend | todo |
| T-003 | Workflow `build-ios.yml` gerando IPA sem assinatura como artifact | devops | todo |
| T-004 | Documentar fluxo: baixar IPA do Actions, assinar no GBox/ESign | devops | todo |

## Fase 1: App (MVP)
| ID | Tarefa | Agente | Status |
|---|---|---|---|
| T-010 | `ReleaseConfig` (data única) + tela de contagem em tempo real | frontend | doing (entregue; correção do bug de virada de dia pedida) |
| T-011 | Live Activity (Lock Screen + Dynamic Island) com `Text(timerInterval:)` | frontend | doing (UI do widget pronta; falta `Activity.request` local) |
| T-012 | Notificações locais nos marcos (30d, 7d, 1d, 1h, lançamento) | frontend | todo |
| T-013 | Polimento visual, acessibilidade, ícone | frontend | todo |
| T-014 | Workflow de verificação em PR (build) | devops | todo |

## Fase 2: Opcional
| ID | Tarefa | Agente | Status |
|---|---|---|---|
| T-020 | Worker Cloudflare servindo a data oficial (JSON) | backend | todo |
| T-021 | App busca a data do Worker com fallback local | frontend | todo |
| T-022 | Deploy do Worker via Actions | devops | todo |

## Pendências com o usuário
- [ ] Confirmar a data oficial de lançamento e o fuso/horário de referência (hoje: 2026-11-19 00:00 EST, NÃO verificado; `ReleaseConfig.isDateVerified = false`). Ver D-004.

## Notas de revisão
- Handoff T-002/T-010/T-011 (Prisma): formato completo; D-001 respeitada (sem entitlements, App Groups, push; data só em `ReleaseConfig`). Não compilado (sem Xcode no Windows): só vale com o build do CI.
- Bug a corrigir em T-010 (`CountdownView`): no tick exato da virada de dia, `context.date == releaseDate - N*86400`, então `Int(remaining/86400)` ainda dá N, o intervalo do timer fica vazio e a tela mostra 00:00:00 com o número de dias sem decrementar até a virada seguinte. Sugestão: contar `ceil(remaining/86400) - 1` (mínimo 0) ou deslocar os ticks alguns segundos.
- Nomes estáveis para o CI (T-003): projeto `ios/CountdownVI.xcodeproj` (gerado por `cd ios && xcodegen generate`), scheme `CountdownVI`, targets `CountdownVI` e `CountdownVIWidget`, bundle IDs `com.countdownvi.app` e `com.countdownvi.app.widget`.
- Escopo: a entrega foi além da T-002 (cobre T-010 e a UI da T-011). Aceito desta vez; próximas vezes, entregar por tarefa.
- Ainda não existe repo git (T-001): sem branch/PR até o DevOps criar.

## Validar no aparelho
Itens que só se confirmam em iPhone real com o IPA assinado:
- [ ] Live Activity inicia e continua contando com o app fechado
- [ ] Dynamic Island (compacto/expandido) em modelo compatível
- [ ] Notificações locais disparam nos horários
- [ ] A Widget Extension é assinada e carregada pelo GBox/ESign
- [ ] O app abre e funciona sem App Groups e sem push remoto
- [ ] A Live Activity aparece na Lock Screen/Dynamic Island com o app assinado sem team próprio
- [ ] Dynamic Island compacta: o tempo com horas totais (ex.: `480:12:03`) cabe sem cortar
- [ ] A tela de contagem decrementa o número de dias na virada, sem ficar 24h em 00:00:00
