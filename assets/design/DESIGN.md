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

## Layout de referência: 393 × 852 pt

Origem no canto superior esquerdo da tela; dimensões aproximadas, ajustar safe areas e Dynamic Type. Título centrado em y=99 pt; subtítulo y=128 pt; cartões de x=22 a 371 pt, y=158 a 259 pt, com quatro colunas e espaço de 8 pt. Barra em y=276 pt; data y=309 pt; linha provisória y=331 pt. Área de arte livre no meio. Scrim escuro em x=20 a 373 pt e y=684 a 819 pt; botão principal x=62 a 331 pt, y=701 a 747 pt; secundário x=62 a 331 pt, y=760 a 804 pt. O scrim é preto arroxeado a 86%; os botões ficam sobre a água e fora do sol e das palmeiras. Texto do botão principal `#100A1C` sobre o gradiente claro; texto do secundário `#FFFFFF` sobre `#181021`. Contrastes calculados no gradiente do botão, sem antialiasing: mínimo superior a 4,5:1; confirmar com o material e cores finais no aparelho.

`palm-glyph.svg` tem viewBox 24 × 24 e um caminho preenchido com `currentColor`; converter para um recurso vetorial compatível com o Xcode. A ilustração na Dynamic Island é uma representação aproximada do glifo.

## Anatomia

- **Home:** título Esperando por Leonida, subtítulo Dias para viajar para Leonida, quatro blocos (dias, horas, minutos, segundos), data e Data provisória, botões e cena inferior. **PROPOSTA:** barra limitada aos últimos 30 dias; fração `clamp(1 - segundosRestantes / (30 * 86400), 0, 1)`. **PROPOSTA:** botão Ativar Live Activity quando não houver activity ativa.
- **Live Activity na Lock Screen:** título e data; rótulo fixo N dias e timer automaticamente atualizado, com data provisória, sobre fundo escuro. Ao ficar stale, ocultar o rótulo de dias e manter o timer. D-016 também prevê um experimento temporário com `Text(releaseDate, style: .relative)`, cuja apresentação depende de validação em aparelho; ele não está ilustrado aqui. Layout sujeito ao sistema.
- **Dynamic Island compacta:** símbolo de palmeira abstrato e **PROPOSTA** `19d` estático, calculado ao criar/atualizar activity; não é timer automático e desaparece quando a activity fica stale.
- **Expandida:** título, data abreviada, rótulo fixo de dias, timer e indicação provisória quando houver espaço. **Mínima:** glifo de palmeira proposto. O sistema determina dimensões e composição.
- **Widget comum:** small com título, dias e data provisória; medium acrescenta relógio; acessório retangular da Lock Screen usa título, dias e relógio monocromáticos. Widget e renderização efetiva dependem do iOS.

## Cena

Recomenda-se `bg-sunset-portrait.png` como fundo de tela inteira do app: imagem gerada por IA, composta com degradê das paradas acima e otimizada para 1179 × 2556. `scene-sunset.svg` e `scene-sunset.png` são fallback vetorial original simplificado e sua renderização. `concept-sunset-study.png` é o estudo anterior gerado por IA. Veja `PROVENANCE.md`; nenhum recurso é screenshot.
