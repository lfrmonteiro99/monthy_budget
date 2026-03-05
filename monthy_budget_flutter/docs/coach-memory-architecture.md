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
- Integrated Coach payload into `openai-chat` function:
  - optional `coach_memory` request block (`mode`, `thread_id`, `context_window`, `user_message`, `household_id`)
  - thread bootstrap in `coach_threads`
  - retrieval context from summaries + recent messages (+ memory match via RPC in `plus/pro`)
  - persistence of user/assistant turns in `coach_messages`
  - summary generation cadence for long threads
  - lightweight memory fact capture for high-signal user statements

## Next implementation steps

1. Harden memory extraction quality (structured extractor instead of keyword heuristic).
2. Add explicit usage/analytics events for fallback and credit consumption.
3. Add retention/privacy controls (expiry and user delete flows) for persisted memories.
