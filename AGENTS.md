# countdown-vi

App iPhone de portfólio: contagem regressiva em tempo real para o lançamento de GTA 6, com Live Activity e notificações.
Este arquivo é a fonte única de verdade. Todos os agentes (Claude, Codex, Antigravity) leem este arquivo antes de agir.

## Escopo
- Tela principal com contagem regressiva (dias, horas, minutos, segundos) em tempo real.
- Live Activity (Lock Screen + Dynamic Island) com a contagem.
- Notificações locais em marcos (ex.: 30, 7, 1 dia, 1 hora, lançamento).
- Simples e polido: é peça de portfólio, qualidade visual e código limpo valem mais que quantidade de features.
- Fora de escopo por enquanto: contas de usuário, banco de dados, anúncios, Android.

## Stack
- iOS 17+, Swift 5.9+, SwiftUI, ActivityKit, WidgetKit, UserNotifications.
- Projeto Xcode em `ios/` (app + Widget Extension da Live Activity).
- Back-end (opcional, fase 2): Cloudflare Worker em `backend/`.
- CI/CD: GitHub Actions em `.github/workflows/`.

## Restrição crítica de assinatura (decisão D-001)
O desenvolvimento é feito no Windows, sem Mac. O CI gera um **IPA sem assinatura**, e o usuário assina por conta própria (GBox, ESign etc.).
Consequências que todo agente deve respeitar:
- Não depender de APNs/push remoto, App Groups ou outras capabilities que exijam provisioning profile próprio. Esses recursos tendem a não funcionar com assinatura de terceiros.
- Live Activity é iniciada e atualizada **localmente** pelo app (sem push token). A contagem usa `Text(timerInterval:)`, que se atualiza sozinha sem servidor.
- Notificações são **locais** (`UNUserNotificationCenter`).
- A data de lançamento vem de uma única constante/config (`ReleaseConfig`), nunca espalhada pelo código.
- Todo item que só dá pra validar em aparelho real vai para a lista "Validar no aparelho" em `docs/TASKS.md`.

## Estrutura de pastas
```
countdown-vi/
├── AGENTS.md            # este arquivo (fonte única de verdade)
├── CLAUDE.md            # importa AGENTS.md + regras do orquestrador
├── .agents/             # regras por agente
│   ├── orchestrator.md
│   ├── frontend.md
│   ├── backend.md
│   └── devops.md
├── ios/                 # app + widget (dono: frontend)
├── backend/             # Worker opcional (dono: backend)
├── .github/workflows/   # CI/CD (dono: devops)
├── scripts/             # scripts de build (dono: devops)
└── docs/
    ├── TASKS.md         # quadro de tarefas (dono: orquestrador)
    └── DECISIONS.md     # decisões e porquês (dono: orquestrador)
```

## Agentes e donos de pasta
| Agente | Ferramenta | Pode editar | Não edita |
|---|---|---|---|
| Orquestrador | Claude | `docs/`, `AGENTS.md`, `CLAUDE.md`, `.agents/` | código de produto |
| Front-end | Claude (2º terminal) | `ios/` | `backend/`, `.github/` |
| Back-end | Codex | `backend/` | `ios/`, `.github/` |
| DevOps | Antigravity | `.github/`, `scripts/`, configs de repo | código de produto |

Regra: cada agente só edita a própria pasta. Se precisar de mudança fora dela, pede ao orquestrador em vez de editar.

## Fluxo de trabalho
1. O usuário fala com o orquestrador. Ele registra a tarefa em `docs/TASKS.md` e delega ao agente dono.
2. O agente trabalha direto na `main` (decisão D-007: projeto simples, sem branches nem PRs).
3. Ao terminar, commita só os próprios arquivos e entrega no formato de handoff abaixo.
4. O orquestrador revisa, atualiza `docs/TASKS.md` e `docs/DECISIONS.md`.

### Formato de handoff (obrigatório ao entregar)
- **Feito:** o que mudou, em poucas linhas.
- **Arquivos:** lista dos arquivos tocados.
- **Como verificar:** comandos/passos.
- **Pendências/riscos:** o que ficou de fora ou precisa de aparelho real.

## Git
- Commit e push direto na `main` (D-007). Sem branches de feature, sem worktrees, sem PR e sem proteção de branch.
- Todos dividem a mesma pasta de trabalho: commitar com `git add` de caminhos explícitos da própria pasta (nunca `git add .` nem `git add -A`), e não reescrever histórico (sem `rebase`, `reset --hard` nem `push --force`).
- Commits no padrão Conventional Commits: `feat:`, `fix:`, `chore:`, `ci:`, `docs:`, `refactor:`. Um assunto por commit.
- Só o orquestrador commita `docs/`, `AGENTS.md`, `CLAUDE.md` e `.agents/`.

## Regras gerais
- Nunca commitar segredos, certificados (`.p12`, `.mobileprovision`) ou chaves.
- Não inventar fatos: a data oficial de lançamento deve ser confirmada pelo usuário antes de ir para release. Valor provisório em `ReleaseConfig`: 2026-11-19 (NÃO verificado).
- Responder ao usuário em português (pt-BR). Código, nomes e commits em inglês.
- Em dúvida de escopo, perguntar ao orquestrador, não assumir.
