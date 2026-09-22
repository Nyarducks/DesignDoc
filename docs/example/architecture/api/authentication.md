---
type: Architecture
title: Freightloop API — authentication
description: Caller identity and authorization — scoped carrier keys for integrations, SSO sessions for the dashboard, and the header conventions both share.
status: current
tags: [api, auth]
sources: [api/internal/middleware/auth.go]
adrs: []
issues: []
---

# Authentication

Two caller classes, two credential types, one enforcement point —
the auth middleware ahead of every handler.
*(Fictional example — the Freightloop project.)*

## Carrier keys (integrations)

- `Authorization: Bearer flk_...` — issued per carrier, scoped
  `events:write` and/or `shipments:read`.
- Scope is enforced against the resource in the path: a key can write
  events only to its own carrier's shipments.
- Keys are stored hashed; rotation uses an overlap window — old and new
  keys both valid for 24 h.

## Dashboard sessions (operators)

- SSO-backed session cookie; routes are role-gated (`viewer`,
  `dispatcher`). The quota editor requires `dispatcher`.
- Sessions never reach carrier surfaces — the middleware rejects them
  outside `/v1/` route groups that allow them.

## Decisions and alternatives

- **Scoped static keys** over OAuth bearer flows — several carrier
  bridges are FTP-to-HTTP schedulers that can't run a token-refresh
  dance; a key that works for years is the only auth they honor.
- **Scope check in middleware** over per-handler checks — one
  enforcement point, no route can forget it.

## Failure modes

| Failure | Caller sees |
|---|---|
| Key revoked or expired | `401` with `code: auth.key_invalid` |
| Valid key, wrong carrier's shipment | `403` with `code: auth.scope_denied` |
| Session expired mid-shift | `401`; dashboard re-auths via SSO silently |

## Security

Keys never appear in logs (the middleware logs the key's ID prefix
only); event payloads carry no PII beyond what the carrier supplies.
