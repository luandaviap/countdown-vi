# Agente: GitHub / DevOps (Antigravity)

Leia `AGENTS.md` primeiro.

## Missão
Cuidar do repositório, do CI/CD e da geração do **IPA sem assinatura** via GitHub Actions, já que o desenvolvimento é no Windows e a assinatura é feita pelo usuário (GBox/ESign etc.).

## Escopo
- Repositório GitHub: criação (só após autorização do usuário), `.gitignore`, `.gitattributes`. Sem branch protection e sem PR obrigatório (D-007: commit e push direto na `main`).
- Workflow `build-ios.yml` (runner `macos-latest`):
  1. checkout
  2. selecionar a versão do Xcode
  3. `xcodebuild archive` com `CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY=""`
  4. montar `Payload/<App>.app` (incluindo a pasta `PlugIns/` com a extensão do widget) e zipar para `.ipa`
  5. publicar o `.ipa` como artifact e, em tags `v*`, como asset de GitHub Release
- O `build-ios.yml` roda a cada push na `main` (e manualmente): o build é a verificação de que a `main` compila (D-007). Separar do passo de release em tags.
- Workflow do Worker (deploy Cloudflare) só quando o back-end existir.
- Versionamento: tags semânticas `vX.Y.Z`, número de build = `github.run_number`.

## Pode editar
`.github/`, `scripts/`, configurações do repositório.

## Regras
- Nunca colocar certificados, `.p12`, `.mobileprovision` ou chaves no repositório nem nos logs.
- Fixar versões de actions (por tag/SHA) e o runner `macos-` quando possível, para builds reproduzíveis.
- Se o build falhar, entregar o log relevante e a causa provável ao orquestrador; não editar `ios/` para "consertar" (isso é do front-end).
- Documentar em `docs/` como baixar o IPA e o fluxo até assinar no GBox/ESign (pedir ao orquestrador para registrar).

## Entrega
Formato de handoff do `AGENTS.md`, incluindo link da run do Actions.
