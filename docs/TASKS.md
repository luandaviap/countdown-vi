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
| T-028 | Guia de assinatura no README: a extensão precisa de perfil próprio (perfil curinga ou Sideloadly), com a ressalva de que a confirmação em aparelho está pendente (D-017) | devops (Trilho) | cancelada (a hipótese de assinatura foi rebaixada: o build 10 funciona no mesmo GBox; ver D-017) |
| T-029 | Migrar o `build-ios.yml` para `macos-15` fixando o Xcode 16.x (runner `macos-14` aposentado em 2026-11-02) | devops (Trilho) | doing |

## Fase 1: App (MVP)
| ID | Tarefa | Agente | Status |
|---|---|---|---|
| T-010 | `ReleaseConfig` (data única) + tela de contagem em tempo real | frontend | done |
| T-011 | Live Activity (Lock Screen + Dynamic Island) com `Text(timerInterval:)` | frontend | done (aparece no aparelho, segundo o usuário) |
| T-012 | Notificações locais nos marcos (30d, 7d, 1d, 1h, lançamento) | frontend | done (aparelho pendente) |
| T-013 | Polimento visual, acessibilidade, ícone, banner em primeiro plano, atalho para Ajustes | frontend | done |
| T-014 | Build a cada push na `main` como verificação (sem PR, D-007) | devops | done |
| T-016 | Widget comum (Home Screen + Lock Screen) que não expira, com entradas por dia e `Text(timerInterval:)` (D-013) | frontend (Prisma) | done (`0e8ee9c`; li o código e conferi o IPA do build 13; aparelho pendente) |
| T-017 | Design v2 a partir da referência do usuário (`docs/design/reference-sunset-countdown.png`): tokens, cena em vetor, mockups rotulados de home, Lock Screen, Dynamic Island e widget (D-012) | arte (Matiz) | done (v2.1 em `8a1296e`; direção aprovada pelo usuário, D-015) |
| T-025 | Mockups v2.2: copy "Esperando por Leonida", botões fora do sol/palmeiras (contraste), Lock Screen e Dynamic Island com o fundo do pôr do sol, Live Activity com "N dias" e estado vencido, e glifo de palmeira em `assets/design/palm-glyph.svg` | arte (Matiz) | done (commit `0d2d35b`, local; revisada por mim: copy de Leonida, botões sobre a água com scrim, contraste 5,76:1 e 18,5:1, Lock Screen e ilha com o pôr do sol, Live Activity com "N dias" e estado vencido) |
| T-018 | Implementar o design v2 na tela principal: fundo `bg-sunset-portrait.png`, tokens, blocos de vidro, barra de 30 dias, botão "Ativar Live Activity", copy "Esperando por Leonida" (D-012, D-015) | frontend (Prisma) | done (`9426dd9`, CI verde; li o código e conferi o IPA; aparelho pendente) |
| T-023 | Live Activity: rótulo "N dias" com `staleDate` e experimento `.relative` (D-016) | frontend (Prisma) | done (`5474347`, CI verde, no IPA do build 15; li o código; aparelho pendente, inclusive o experimento `.relative`) |
| T-026 | Mover a regra de dias da D-010 para `ios/Shared` (hoje duplicada em `DayCountdown` do widget e em `ContentState.init(releaseDate:now:)`) e fazer app, widget e Live Activity usarem uma só | frontend (Prisma) | todo (agrupar com a decisão A/B do botão para poupar runs) |
| T-024 | Restilizar a Live Activity (glifo de palmeira) e o widget no design v2 | frontend | todo (depois da T-018, T-023 e da T-025) |
| T-019 | README: trocar "Screenshots coming soon" por mockups rotulados (hero + telas) (D-011) | devops | todo (depois da T-017) |

## Fase 2: Servidor (decisão do usuário: "logo mais")
| ID | Tarefa | Agente | Status |
|---|---|---|---|
| T-020 | Worker Cloudflare servindo a data/hora de lançamento, com resposta por região/fuso da pessoa (D-004, D-002) | backend (Forja) | todo (aguardando o usuário: fonte oficial da data, conta Cloudflare, regra por região) |
| T-021 | App busca a data do Worker com fallback local (`ReleaseConfig`) | frontend | todo |
| T-022 | Deploy do Worker via Actions | devops | todo |

## Bloqueio atual (2026-10-30)
- **Regressão no aparelho:** o usuário relatou que, no build 15, nem o widget nem a Live Activity funcionaram (no build 10 a Live Activity aparecia). Comparei os IPAs 10, 13 e 15: arquivos, Info.plist do app e da extensão, arquitetura (arm64) e iOS mínimo são idênticos; a extensão cresceu de 95 KB (10) para 170 KB (13) e 171 KB (15). Causa desconhecida.
- Plano: (1) bisseção pelo usuário com `build/CountdownVI-unsigned-build-10.ipa`, `-13.ipa` e `-15.ipa` (instalar apagando o app antes); (2) T-027 com o Prisma: revisão estática e uma linha de diagnóstico temporária na home com o erro exato da Live Activity; (3) perguntas ao usuário: se o app abre, se o botão "Ativar Live Activity" aparece, se o assinador mostrou erro e se instalou por cima ou limpo.

- Relato do usuário: "só aparece o botão Avisar nos marcos" (build não informado). O botão "Ativar Live Activity" só existe no build 15; se o relato for do 15, indica Live Activities desligadas ou activity criada mas não renderizada. Feedback de design: o texto "Avisar nos marcos" é fraco; opções propostas: "Ativar lembretes", "Me lembrar nos marcos", "Receber lembretes da contagem" (aguardando escolha; trocar em `AppCopy.swift`).

- Relato do usuário (build 15, instalação limpa): só aparece "Avisar nos marcos"; "Atividades ao vivo" está ligada em Ajustes. Conclusão: o app provavelmente cria a activity (o botão "Ativar" some) mas a extensão não renderiza, o que também explica o widget não aparecer. Causa ainda desconhecida; o Prisma subiu o diagnóstico (`7f8a8c1`) e uma correção de decodificação (`9ff2007`), com o CI na fila (run `41098428837`). Bisseção pedida: instalar o build 13 (e o 10) e relatar.

- T-027 (Prisma, handoff recebido): build 16 (run `41098428837`, `9ff2007`, verde) com linha de diagnóstico temporária na home (`DiagnosticsInfo.swift`, `TODO(remover-diagnostico)`) e correção `9ff2007` (`ContentState.days` agora opcional). Hipóteses do Prisma: H1 (média) activity de build antigo ilegível pela extensão nova, não explica o widget; H2 (baixa-média) a extensão inteira não carrega no aparelho (assinatura/perfil da extensão no assinador, bundle ID da extensão não acompanhando o do app, ou iOS sem reindexar widgets). Nenhum defeito estático encontrado que derrube a extensão. Próximo passo: print da linha do build 16 e o teste do build 10 pelo usuário. Remover a linha de diagnóstico depois.

- **REVISÃO: a causa NÃO é (só) a assinatura.** O usuário provou, com prints, que o **build 10 funciona** no mesmo GBox e certificado (Live Activity na tela bloqueada e na ilha). É uma regressão de código/binário entre os builds 10 e 16. Diferença achada: a extensão passou a ligar `libswift_Concurrency` a partir do build 13; pacote e permissões idênticos. Bisseção: builds 13, 14 e 15 em `build/` (13 = + widget, 14 = + home v2, 15 = + dias). T-028 cancelada até haver evidência. O texto abaixo (hipótese de assinatura) fica só como histórico.
- (histórico, hipótese rebaixada) **Causa identificada (print do build 16, D-017):** a extensão está assinada mas sem perfil de provisionamento (`perfil não`); o app tem perfil e criou a activity (`1 active`, sem erro). Sem perfil, o iOS não carrega a extensão, então não há widget nem desenho da Live Activity. Não é bug de código. Caminhos: certificado/perfil curinga no GBox/ESign, ou Sideloadly com Apple ID no Windows. Aguardando o usuário dizer qual assinador/certificado usa e se o build 10 foi assinado de outro jeito. A linha de diagnóstico sai depois da confirmação.
- Primeiro print real do app no aparelho (build 16): a home do design v2 renderiza como no mockup (fundo, blocos de vidro, barra, textos). O print tem a linha de diagnóstico; pedir outro sem ela para o README.

- **CI bloqueado (2026-10-30):** o runner `macos-14` será aposentado em 2 de novembro de 2026 e o GitHub derruba as runs em segundos (brownout, issue `actions/runner-images#13518`); as runs de `55a3482` e `52b60de` foram canceladas. T-029 (Trilho): migrar para `macos-15` e **fixar** o Xcode (16.2, ou a 16.x mais nova, nunca 26.x) para o SDK não mudar para o do iOS 26 durante a investigação.
- T-027b (Prisma, handoff): a extensão do build 13 em diante liga `libswift_Concurrency` por causa do `#Preview(as: .systemSmall)` do widget (macro gera closure async; certeza alta de que é a origem do import). Mas o app do build 10 (que funciona) já liga as mesmas 3 dylibs como obrigatórias, então a linkagem provavelmente não é a causa (~90%). Hipótese restante, certeza baixa: o segundo widget (`CountdownWidget`) ou metadados de preview fazem a extensão falhar ao carregar no iOS 26. O Prisma removeu o `#Preview` (`55a3482`, ainda sem build). Se o build sem `#Preview` também falhar, o próximo passo é um build com o `WidgetBundle` só com a `CountdownLiveActivity`. A bisseção do usuário (13, 14, 15) decide.
- Incidente de processo: um comando encadeado do Prisma teve o commit vazio (o gate barrou a edição) e o `git push` seguiu, publicando meus 5 commits de docs que estavam só locais (`9ff2007..52b60de`). Sem reescrita de histórico; só o push foi antecipado. Os docs são públicos no repositório de qualquer forma (D-008).

## Pendências com o usuário
- [ ] Data oficial e fuso: seguem provisórios (2026-11-19 00:00 EST, NÃO verificado; `isDateVerified = false`; a tela mostra "Data provisória"). O usuário decidiu deixar assim por enquanto, e depois quer um servidor que entregue a data/hora conforme a região da pessoa (T-020/T-021). Só mudar com confirmação explícita.
- [x] Direção de design v2, fundo gerado por IA e as 3 propostas: aprovados (leitura minha de "Decisão aprovada"; o usuário pode corrigir). Ver D-015.
- [ ] Botão "Ativar Live Activity": hoje o app inicia a activity sozinho ao abrir (D-006), então o botão quase nunca aparece (só se a activity não existir e as Live Activities estiverem permitidas). Decidir: (A) só por botão (opt-in, como na referência; a activity não volta sozinha depois das ~8h, só quando o usuário tocar) ou (B) automático, como hoje, e o botão fica de reserva. Recomendação do orquestrador: A. Mudança de 1 linha (tirar o `sync()` automático).
- [x] React Native: o usuário decidiu seguir no nativo (Swift/SwiftUI). Para iterar o visual, proposta de protótipo HTML/CSS no portal de navegador (a usar quando o usuário quiser).
- (histórico) Decisão do usuário: trocar o app para React Native para ter mais controle da estética (glassmorphism) e iterar com um portal de dispositivo. Recomendação do orquestrador: não trocar agora. Motivos: a Live Activity e o widget continuam exigindo extensão nativa em Swift e o mesmo problema de assinatura; o SwiftUI já faz vidro nativo (o print real mostra o design funcionando); o portal de dispositivo dirige Android, não iPhone; Android está fora do escopo (AGENTS.md); RN descartaria o diferencial de portfólio (ActivityKit/WidgetKit nativos). Alternativa: protótipo HTML/CSS do design para iterar rápido no portal de navegador, depois portar para SwiftUI. Aguardando a resposta.
- [ ] Teste urgente do usuário: instalar o build 10 (GBox, mesmo certificado) e dizer se a Live Activity aparece, para separar "assinador" de "código novo".
- [ ] Testar o IPA do build 15 (`build/CountdownVI-unsigned-build-15.ipa`, run `41094539022`): home nova + Live Activity com dias + linha de experimento `.relative`.
- [x] Nome na tela: o usuário quer o tema Leonida ("Esperando por Leonida" / "Dias para viajar para Leonida"), apesar do aviso sobre a marca. Decisão dele (D-015).
- [x] Live Activity com dias: opções 1 e 2 aprovadas (D-016, T-023). Descrição original: `Text(timerInterval:)` só mostra horas totais (ex.: 468:33:19). Proposta: manter o timer de horas totais (sempre correto) e acrescentar um rótulo estático "N dias" calculado ao criar/atualizar a activity, com `staleDate` na próxima virada de dia; quando `context.isStale`, esconder o rótulo e mostrar só as horas (nunca exibe dia errado). Experimento opcional: `Text(releaseDate, style: .relative)`, que se atualiza sozinho e pode mostrar dias, mas o formato exato não dá para conferir sem aparelho. Entra na T-018 (design v2) salvo o usuário pedir antes.
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
- Aviso de infra (2026-10-30): o download do artifact do build 15 pelo `gh run download` falhou com "HTTP 503: Egress is over the account limit" (limite de saída de dados do GitHub/Actions). O IPA foi recuperado de uma cópia local minha. Se persistir, pedir ao Trilho para checar os limites de Actions/armazenamento e considerar publicar o IPA de outra forma (ex.: release em tag, com autorização do usuário). O usuário apagou o IPA local por engano e pediu para recriar.
- T-023 (revisão): `ContentState` ganhou `days` (regra da D-010) e `nextDayBoundary`; `sync()` cria o conteúdo com `staleDate` na próxima virada e atualiza a cada ativação do app; views escondem "N dias" quando `isStale`; compacta mostra "Nd" e, vencida, volta ao timer de 56pt; minimal e compacta usam `sun.horizon.fill` até a T-024 (palmeira); linha do experimento `.relative` marcada com `TODO(remover)`. Se a decisão do botão for A (só por botão), o `sync()` deve se dividir em "atualizar a existente" (automático, para os dias continuarem corretos) e "criar" (só no botão).
- T-018 (revisão): fundo `SunsetBackground` (Assets.car subiu de 167 para 706 KB), tokens em `ios/Shared/Theme.swift`, textos em `AppCopy.swift`, blocos de vidro, barra de 30 dias (`ReleaseConfig.progressWindow`), botões sobre a água. O Prisma usou texto escuro no botão em degradê (branco sobre laranja dá ~2,4:1, abaixo de 4,5:1). Reduce Transparency, Dynamic Type 2x2 e VoiceOver tratados. Os números de contraste são estimativas; validar no aparelho. D-001 intacta.
- Mockups v2.2 (revisão): layout corrigido, contraste calculado, Live Activity com dias e estado vencido, sem nova imagem de IA. Detalhe para a T-024: `palm-glyph.svg` usa `fill="currentColor"`; se o Xcode renderizar errado no catálogo de assets, trocar para uma cor sólida (ex.: preto) e marcar "Render as: Template".
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
- [ ] Home nova (T-018): fundo em tela cheia e alinhado embaixo, sem faixas; nenhum texto ou botão sobre o sol ou as palmeiras; botões legíveis sobre a água
- [ ] Home nova: vidro legível; com Reduce Transparency os blocos ficam sólidos; Dynamic Type no máximo vira blocos 2x2 e a tela rola
- [ ] Live Activity com dias (T-023): aparece "N dias" ao lado do timer; some ao vencer (`isStale`); a linha de experimento `.relative` mostra o quê (anotar o texto exato)
- [ ] Widget (T-016): aparece na galeria (Home: pequeno e médio; Lock Screen: retangular e circular) no IPA assinado
- [ ] Widget: continua contando com o app fechado por mais de 1 dia (a virada decrementa os dias sozinha)
- [ ] Widget: na virada o relógio não mostra 24:00:00 (ou só por ~1s); se mostrar, ancorar o timer em virada menos 1s
- [ ] Widget: "Data provisória" aparece no pequeno e no médio; o VoiceOver lê "Faltam N dias para GTA VI. Data provisória"
