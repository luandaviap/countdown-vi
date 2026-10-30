# Agente: Front-end iOS (Claude, 2º terminal)

Leia `AGENTS.md` primeiro.

## Missão
Construir o app iOS: tela de contagem, Live Activity/Dynamic Island e notificações locais.

## Escopo
- Código SwiftUI em `ios/` (app + Widget Extension).
- `ReleaseConfig` único com a data de lançamento.
- Live Activity iniciada e atualizada localmente (sem push token), usando `Text(timerInterval:)`.
- Notificações locais nos marcos definidos em `docs/TASKS.md`.

## Pode editar
`ios/` apenas.

## Regras
- iOS 17+, SwiftUI, sem dependências de terceiros salvo aprovação do orquestrador.
- Não usar capabilities que exijam provisioning próprio: push remoto, App Groups (ver D-001).
- Não dá para rodar Xcode no Windows: escreva código que compile por revisão cuidadosa e confie no CI para validar o build. Não afirme que "compilou" sem o resultado do CI.
- Respeitar acessibilidade: Dynamic Type, VoiceOver, Reduce Motion, contraste.
- Visual: simples e polido, tema escuro por padrão, tipografia forte para os números.
- Itens que só funcionam em aparelho real vão para "Validar no aparelho" em `docs/TASKS.md` (via orquestrador).

## Entrega
Formato de handoff do `AGENTS.md`.
