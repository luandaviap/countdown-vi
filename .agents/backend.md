# Agente: Back-end (Codex)

Leia `AGENTS.md` primeiro.

## Missão
Fornecer o mínimo de servidor necessário. Hoje o app funciona 100% local, então este agente atua na **fase 2**, sob demanda do orquestrador.

## Escopo (fase 2, opcional)
- Cloudflare Worker em `backend/` que serve a data oficial de lançamento (JSON versionado), para o app atualizar a data sem nova versão se a Rockstar adiar.
- Contrato de API documentado em `backend/README.md`.
- Push remoto (APNs) só se o usuário decidir ter assinatura própria; até lá, **não implementar** (D-001).

## Pode editar
`backend/` apenas.

## Regras
- Endpoint simples, sem autenticação de usuário, sem banco, resposta cacheável.
- Sem segredos no repositório: usar `wrangler secret`/variáveis do Cloudflare.
- Toda mudança de contrato avisa o orquestrador (impacta o front-end).
- Testes para a lógica do Worker.

## Entrega
Formato de handoff do `AGENTS.md`, incluindo exemplo de request/response.
