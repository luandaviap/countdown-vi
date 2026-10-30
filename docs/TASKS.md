# Tarefas

Dono: orquestrador. Status: `todo` | `doing` | `review` | `done`.

Marco: o CI compila o app e gera o IPA sem assinatura. O usuário instalou o IPA do build 10 e confirmou que a Live Activity aparece. `done` nas tarefas de código significa "compila no CI"; o comportamento detalhado em aparelho está em "Validar no aparelho".

## Fase 0: Setup
| ID | Tarefa | Agente | Status |
|---|---|---|---|
| T-001 | Criar repositório GitHub e dar push da `main` (sem proteção de branch, D-007) | devops | done (`luandaviap/countdown-vi`, público, D-008) |
| T-002 | Criar projeto Xcode em `ios/` (app + Widget Extension, iOS 17+) | frontend | done |
| T-003 | Workflow `build-ios.yml` gerando IPA sem assinatura como artifact | devops | done |
| T-004 | Fluxo "baixar IPA do Actions e assinar no GBox/ESign" | devops | done (seção do README) |
| T-005 | `.gitignore`: ignorar os `Info.plist` gerados pelo xcodegen (D-005) | devops | done |
| T-006 | `.gitattributes` com `eol=lf` | devops | done |
| T-007 | `README.md` de portfólio (D-008) | devops | review (publicado; falta a correção da T-015 e as imagens da T-019) |
| T-008 | Identidade visual: wordmark, ícone 1024x1024, banner e paleta em `assets/` (D-009) | arte (Matiz) | done |
| T-009 | Mockup fiel do app como estava (v1, preto e branco) em `assets/mockups/` | arte (Matiz) | done (commit `ffcea7d`, local) |
| T-015 | README: corrigir o texto do timer (linha 38) e checar actions em Node 24 (`checkout@v4`, `upload-artifact@v4`) | devops (Trilho, Sonnet 5.5) | done (`6bd0b4b`; conferi: as 3 actions na última versão e em Node 24, README correto, run `41091728283` verde; o passo de release só roda em tag e nunca foi exercitado) |

## Fase 1: App (MVP)
| ID | Tarefa | Agente | Status |
|---|---|---|---|
| T-010 | `ReleaseConfig` (data única) + tela de contagem em tempo real | frontend | done |
| T-011 | Live Activity (Lock Screen + Dynamic Island) com `Text(timerInterval:)` | frontend | done (aparece no aparelho, segundo o usuário) |
| T-012 | Notificações locais nos marcos (30d, 7d, 1d, 1h, lançamento) | frontend | done (aparelho pendente) |
| T-013 | Polimento visual, acessibilidade, ícone, banner em primeiro plano, atalho para Ajustes | frontend | done |
| T-014 | Build a cada push na `main` como verificação (sem PR, D-007) | devops | done |
| T-016 | Widget comum (Home Screen + Lock Screen) que não expira, com entradas por dia e `Text(timerInterval:)` (D-013) | frontend (Prisma) | done (`0e8ee9c`; li o código e conferi o IPA do build 13; aparelho pendente) |
| T-017 | Design v2 a partir da referência do usuário (`docs/design/reference-sunset-countdown.png`): tokens, cena em vetor, mockups rotulados de home, Lock Screen, Dynamic Island e widget (D-012) | arte (Matiz) | review (v2.1 em `8a1296e`, local, revisada por mim; aguarda a aprovação do usuário para liberar a T-018) |
| T-018 | Implementar o design v2 no app, Live Activity e widget | frontend | todo (só depois de o usuário aprovar os mockups da T-017) |
| T-019 | README: trocar "Screenshots coming soon" por mockups rotulados (hero + telas) (D-011) | devops | todo (depois da T-017) |

## Fase 2: Servidor (decisão do usuário: "logo mais")
| ID | Tarefa | Agente | Status |
|---|---|---|---|
| T-020 | Worker Cloudflare servindo a data/hora de lançamento, com resposta por região/fuso da pessoa (D-004, D-002) | backend (Forja) | todo (aguardando o usuário: fonte oficial da data, conta Cloudflare, regra por região) |
| T-021 | App busca a data do Worker com fallback local (`ReleaseConfig`) | frontend | todo |
| T-022 | Deploy do Worker via Actions | devops | todo |

## Pendências com o usuário
- [ ] Data oficial e fuso: seguem provisórios (2026-11-19 00:00 EST, NÃO verificado; `isDateVerified = false`; a tela mostra "Data provisória"). O usuário decidiu deixar assim por enquanto, e depois quer um servidor que entregue a data/hora conforme a região da pessoa (T-020/T-021). Só mudar com confirmação explícita.
- [ ] Aprovar a direção e os mockups da T-017 antes de a T-018 começar.
- [ ] Perguntas de design em aberto: (a) nome na tela: a referência usa "LEONIDA COUNTDOWN", mas Leonida é o estado fictício do jogo (marca da Rockstar); proposta: "GTA VI" e "Countdown VI" como no app; (b) a barra de progresso precisa de um período: proposta, últimos 30 dias até o lançamento (sem depender de data de anúncio); (c) botão "Ativar Live Activity": proposta, mostrar quando não há activity ativa (ajuda após o limite de ~8h, D-006).
- [ ] Live Activity com dias (pergunta do usuário): `Text(timerInterval:)` só mostra horas totais (ex.: 468:33:19). Proposta: manter o timer de horas totais (sempre correto) e acrescentar um rótulo estático "N dias" calculado ao criar/atualizar a activity, com `staleDate` na próxima virada de dia; quando `context.isStale`, esconder o rótulo e mostrar só as horas (nunca exibe dia errado). Experimento opcional: `Text(releaseDate, style: .relative)`, que se atualiza sozinho e pode mostrar dias, mas o formato exato não dá para conferir sem aparelho. Entra na T-018 (design v2) salvo o usuário pedir antes.
- [x] Licença: MIT em nome de "Luan" mantida (decisão do usuário).
- [x] Widget comum que não expira: aprovado (D-013).
- [x] Troca do Trilho para o Sonnet 5.5: feita.
- [x] Proteção da `main` removida e branches antigas apagadas.
- [x] Teste no iPhone (build 10): o usuário confirmou que a Live Activity aparece. Detalhes dos demais itens ainda não reportados.
- [ ] Testar o widget: IPA do build 13 (`build/CountdownVI-unsigned-build-13.ipa`, run `41091728283`, com ícone e widget).
- [ ] Push dos commits locais (mockups v1 e docs): sem objeção; sobem junto com o próximo push do Trilho.

## Notas de revisão
- IPA (build 10): app + `PlugIns/CountdownVIWidget.appex`, `NSSupportsLiveActivities = true`, iOS 17.0, ícone, sem entitlements nem `_CodeSignature` (D-001 preservada).
- T-010/T-013: dias e relógio saem do mesmo total de segundos; nunca 24:00:00 (D-010).
- T-011/T-012: ActivityKit e UserNotifications 100% locais; limite de ~8h da Live Activity aceito (D-006).
- Marcos de notificação: constantes em `ReleaseConfig.Milestone` (não configuráveis).
- README: a imprecisão da linha 38 (timer) ainda não foi corrigida (T-015). Regra: o README só afirma o que foi verificado.
- Processo: D-007 (commit direto na `main`, `git add` só de caminhos próprios, sem reescrever histórico); só o orquestrador commita `docs/`, `AGENTS.md`, `CLAUDE.md` e `.agents/`. Decisões sobre licença, nome, visibilidade e marca passam pelo usuário.
- O Trilho esgotou a cota no Antigravity (Gemini); o agente foi trocado no mesmo terminal para o Claude Sonnet 5.5 (preset `Claude Sonnet 5.5`, auto mode). Papel `cvi-devops` atualizado para a D-007.
- T-016 (widget, revisão): `CountdownTimelineProvider` pré-calcula entradas por virada de dia (teto de 60, `.atEnd`; depois do lançamento `[agora]` e `.never`), dias pela regra da D-010, relógio com `Text(timerInterval:)` de intervalo sempre válido; sem App Group, push nem entitlements. Risco conhecido: pode mostrar 24:00:00 por ~1s na virada.
- README: o texto "and the future widget" deve virar "and the widget" (o widget já está na `main`); ajustar na T-019.
- Mockups v2.1 (revisão): corrigidos o fundo (degradê em tela cheia com `bg-sunset-portrait.png`, 1179x2556, ~503 KB), os cantos, o glifo de palmeira, os blocos translúcidos e a capa (1600x1000). `PROVENANCE.md` diz que as imagens vieram da ferramenta de imagem da OpenAI (modelo não informado) e que a arte é original. Pontos que sobram: na home, o texto "Data provisória" e os botões ficam sobre palmeiras e sol, então contraste e posição precisam de ajuste (os botões ficariam melhor acima da cena ou sobre a água); os mockups da Lock Screen e da Dynamic Island seguem em azul chapado, destoando da home; contraste e materiais só se validam no aparelho.
- (histórico) Mockups v2, primeira versão: estrutura e rótulos honestos, mas a home usa fundo azul chapado em vez do degradê do próprio DESIGN.md, a cena fica colada em um retângulo com cantos pretos vazando da moldura, e a Dynamic Island tem quadrados vazios no lugar do glifo. O Matiz gera imagens com IA (`concept-sunset-study.png`), que ficou bem mais próxima da referência do que o vetor; decisão pendente do usuário sobre qual cena o app usa.
- Referência de design do usuário: `docs/design/reference-sunset-countdown.png` (imagem conceito gerada com GPT; não é o app).

## Validar no aparelho
Itens que só se confirmam em iPhone real com o IPA assinado:
- [x] O app abre e a Live Activity aparece (relato do usuário, build 10; a extensão foi assinada e carregada pelo assinador)
- [ ] O app funciona sem App Groups e sem push remoto (confirmar o uso geral)
- [ ] Live Activity continua contando com o app fechado
- [ ] Dynamic Island (compacto/expandido) em modelo compatível
- [ ] A `compactTrailing` (56pt) não trunca "NNN:MM:SS" (ex.: `480:12:03`)
- [ ] Reabrir o app várias vezes não cria activity duplicada
- [ ] Após ~8h a activity some e volta ao reabrir o app (D-006)
- [ ] Com Live Activities desligadas em Ajustes, o app não falha
- [ ] O prompt de permissão aparece ao tocar "Avisar nos marcos"
- [ ] As notificações locais disparam nos marcos (testável com a data temporariamente próxima)
- [ ] Reabrir o app não gera notificações duplicadas
- [ ] Negando a permissão, o app segue normal e aparece o link para os Ajustes; ao ativar e voltar, o link some
- [ ] A virada de dia mostra N dias 00:00:00 e depois N-1 dias 23:59:59 (nunca 24:00:00)
- [ ] O ícone aparece na Home
- [ ] O banner aparece com o app aberto quando um marco dispara
- [ ] Dynamic Type no maior tamanho de acessibilidade: tela rolável, número em 1 linha; VoiceOver lê dias, horas e minutos
- [ ] Com Reduce Motion ativado, os dígitos trocam sem animação
- [ ] Widget (T-016): aparece na galeria (Home: pequeno e médio; Lock Screen: retangular e circular) no IPA assinado
- [ ] Widget: continua contando com o app fechado por mais de 1 dia (a virada decrementa os dias sozinha)
- [ ] Widget: na virada o relógio não mostra 24:00:00 (ou só por ~1s); se mostrar, ancorar o timer em virada menos 1s
- [ ] Widget: "Data provisória" aparece no pequeno e no médio; o VoiceOver lê "Faltam N dias para GTA VI. Data provisória"
