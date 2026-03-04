# Supabase OpenAI Edge Function

This app now uses a Supabase Edge Function for all OpenAI calls used by:
- AI Coach
- Meal Planner AI enrichments

## 1) Set OpenAI secret in Supabase

```bash
supabase secrets set OPENAI_API_KEY=sk-... --project-ref YOUR_PROJECT_REF
```

## 2) Deploy function

```bash
supabase functions deploy openai-chat --project-ref YOUR_PROJECT_REF
```

## 3) (Optional) Local serve

```bash
supabase functions serve openai-chat --env-file .env.local
```

With `.env.local`:

```env
OPENAI_API_KEY=sk-...
```

## Notes

- The mobile app no longer needs to store/use OpenAI API keys for these features.
- Function name expected by the app: `openai-chat`.
