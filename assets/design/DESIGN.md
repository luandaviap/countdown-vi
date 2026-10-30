# Design v2: pôr do sol e vidro

Documento de proposta visual. Nenhuma tela aqui comprova implementação. A data permanece provisória.

## Paleta e materiais

| Token | Valor | Uso |
|---|---|---|
| Sky / deep | `#24104C` | topo do céu |
| Sky / magenta | `#ED286B` | horizonte intermediário |
| Sky / orange | `#FF8A4C` | horizonte quente |
| Neon pink | `#FF4B9E` | destaque e progresso |
| Orange | `#FF814A` | final do degradê do botão |
| Sun | `#FFE176` | sol e reflexos |
| Night | `#100A28` | silhuetas e contraste |
| Text primary | `#FFFFFF` | títulos e números |
| Text secondary | `#E8BFD7` | rótulos e data provisória |
| Glass fill | `#FFFFFF` a 12% | fundo dos cartões |
| Glass border | `#FFFFFF` a 30% | contorno de 1 pt |
| Glass blur | 20 pt aproximados | material translúcido, validar em aparelho |
| Progress track | `#80566D` | trilho |
| Progress fill | `#FF4B9E` a `#FF814A` | preenchimento |
| Button | `#FF3797` a `#FF814A` | botão principal |

## Tipografia e geometria

Somente fonte de sistema iOS: `.system` com `.rounded` ou largura `.condensed` quando disponível; não embutir fontes. Título 34 pt heavy; números 36 pt bold com `monospacedDigit`; rótulos 10 pt semibold em caixa alta com tracking 1 pt; data 15 pt semibold; observação 12 pt; botão 17 pt semibold. Adaptar com Dynamic Type e contraste. Cartões: raio 16 pt, espaço 8 pt; margem lateral 24 pt; seções 24 a 32 pt; botão com raio igual à metade da altura, mínimo 44 pt.

## Mapeamento SwiftUI

Use `LinearGradient(stops:)` vertical com paradas 0 `#24104C`, 0.55 `#ED286B`, 1 `#FF8A4C`; botão com gradiente horizontal rosa/laranja. `Material.ultraThin` em `RoundedRectangle` com camada de cor e borda translúcida aproxima o vidro; material não garante um raio de blur fixo e depende do contexto. Respeitar Reduce Transparency, Dynamic Type e áreas seguras; medir legibilidade no aparelho. Usar o fundo retrato recomendado preservando proporção; usar a cena vetorial como fallback.

## Anatomia

- **Home:** título GTA VI, Countdown VI, quatro blocos (dias, horas, minutos, segundos), data e Data provisória, botões e cena inferior. **PROPOSTA:** barra limitada aos últimos 30 dias; fração `clamp(1 - segundosRestantes / (30 * 86400), 0, 1)`. **PROPOSTA:** botão Ativar Live Activity quando não houver activity ativa.
- **Live Activity na Lock Screen:** título e data; timer automaticamente atualizado, com data provisória, sobre fundo escuro. Layout sujeito ao sistema.
- **Dynamic Island compacta:** símbolo de palmeira abstrato e **PROPOSTA** `19d` estático, calculado ao criar/atualizar activity; não é timer automático e pode ficar defasado.
- **Expandida:** título, data abreviada, timer e indicação provisória quando houver espaço. **Mínima:** glifo de palmeira proposto. O sistema determina dimensões e composição.
- **Widget comum:** small com título, dias e data provisória; medium acrescenta relógio; acessório retangular da Lock Screen usa título, dias e relógio monocromáticos. Widget e renderização efetiva dependem do iOS.

## Cena

Recomenda-se `bg-sunset-portrait.png` como fundo de tela inteira do app: imagem gerada por IA, composta com degradê das paradas acima e otimizada para 1179 × 2556. `scene-sunset.svg` e `scene-sunset.png` são fallback vetorial original simplificado e sua renderização. `concept-sunset-study.png` é o estudo anterior gerado por IA. Veja `PROVENANCE.md`; nenhum recurso é screenshot.
