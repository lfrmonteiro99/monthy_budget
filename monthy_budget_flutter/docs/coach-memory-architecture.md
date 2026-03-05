# Coach Memory Architecture (Issue #51)

This document defines the first implementation step for Coach memory with:
- subscription-based feature access
- credits-based memory/quality tiers (`eco`, `plus`, `pro`)

## Product rules

1. Coach access remains gated by subscription/trial.
2. Credits do not unlock Coach access for blocked users.
3. Credits only improve mode (`plus`/`pro`).
4. Users with Coach access must always receive a response.
5. If credits are insufficient, fallback to `eco` is automatic.

## Current implementation in this step

- Added mode and credit policy to `SubscriptionState`.
- Added helper methods to `SubscriptionService`:
  - set preferred mode
  - add/consume credits
  - resolve mode and consume credits when needed
- Added Supabase schema foundation:
  - `coach_threads`
  - `coach_messages`
  - `coach_memories` + vector index
  - `coach_memory_summaries`
  - `match_coach_memories(...)` RPC for retrieval

## Next implementation steps

1. Integrate mode resolution into Coach request flow.
2. Add in-chat fallback UI notice and "Restaurar memoria" CTA.
3. Add embedding + memory extraction pipeline in Edge Function.
4. Add periodic summary generation to bound context growth.
