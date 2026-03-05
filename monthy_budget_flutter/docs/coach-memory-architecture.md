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
- Integrated mode selection and fallback UX in `CoachScreen`:
  - mode chips (`Eco/Plus/Pro`)
  - credit balance visibility
  - fallback notice + `Restaurar memoria` CTA
  - mode-based token budget (`AiCoachService.analyze(maxTokens: ...)`)

## Next implementation steps

1. Add embedding + memory extraction pipeline in Edge Function.
2. Add periodic summary generation to bound context growth.
3. Connect retrieval RPC (`match_coach_memories`) to Coach prompt assembly.
