---
type: Design Doc
title: <App> frontend design
description: The web module's design hub — app-level conventions plus the index of per-route docs.
status: current
last_modified: <YYYY-MM-DD>
tags: [frontend]
sources: [<web module paths>]
adrs: []
issues: []
---

# <App> frontend design

## Goal

<What the app is for — who uses it and what jobs it serves. One
paragraph.>

## Context

<Objective facts constraining the app — who uses it, on what hardware
and network, how fresh the data must be for the decisions it supports.>

## Conventions

<App-wide choices — data fetching layer, state model, routing scheme,
permission gating. Each convention is a decision: state it with the
constraint or rejected alternative that produced it, not just the
rule.>

## In this directory

| Doc | Route | Surface |
|---|---|---|
| [<route>](route.md) | `<path>` | <what the screen does> |

One doc per route — a screen's states and data dependencies. Visual
specs live in the components; these docs carry behavior and data
contracts.
