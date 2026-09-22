---
type: Reference
title: Freightloop glossary
description: Ubiquitous domain terms — one definition per term, shared by every doc. Design docs link here rather than redefining; new terms are promoted here when their change ships.
status: current
tags: [glossary, architecture]
sources: []
---

# Glossary

The shared vocabulary for Freightloop. A term belongs here once it has
system meaning — design docs link to this list instead of redefining
terms, and a term introduced by a proposal is promoted here when the
change ships. *(Fictional example — the Freightloop project.)*

| Term | Meaning |
|---|---|
| shipment | A package being tracked end to end; identified by `shipment_id`. Its state is folded from its event stream — never a mutable column. |
| tracking event | One observation about a shipment — carrier push, depot scan, or GPS ping. Append-only; out-of-order arrival is normal. |
| `event_id` | Client-supplied dedup key on every event; the write path's correctness guarantee under carrier retries. |
| carrier | A regional shipping company that pushes tracking events and reads shipment state via the API. |
| carrier key | Scoped API credential per carrier (`events:write`, `shipments:read`); writes are limited to the caller's own shipments. |
| depot scan | A carrier scan event at a depot; a `depot_scan` at the final depot moves a shipment to `out_for_delivery`. |
| event stream | A shipment's append-only event log (`events` table). |
| fold / projection | Current shipment state derived by folding the event stream. The worker owns the fold; the API reads the projection. |
| ETA | Computed delivery estimate per shipment. `eta.stale: true` when projection lag exceeds 60 s. |
| ingest lag | Delay between event enqueue and projection update; SLO is under 30 s at sustained load. |
| poison event | An event that always fails processing — parked in `dead` after 3 batch failures so it never starves the queue. |
| carrier bridge | Legacy carrier integration that can POST but can't poll or hold connections — constrains API design choices. |
| tenant | A carrier account; rate limits and quotas are per-tenant (per carrier key). |
