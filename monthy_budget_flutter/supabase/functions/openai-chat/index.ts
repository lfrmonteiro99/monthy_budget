import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
      'authorization, x-client-info, apikey, content-type',
};

type ChatMessage = {
  role: string;
  content: string;
};

type CoachMode = 'eco' | 'plus' | 'pro';

type CoachMemoryRequest = {
  mode?: CoachMode;
  requested_mode?: CoachMode;
  used_fallback?: boolean;
  fallback_reason?: string;
  client_audit_id?: string;
  debited_credits?: number;
  client_credit_before?: number;
  client_credit_after?: number;
  thread_id?: string;
  context_window?: number;
  user_message?: string;
  household_id?: string;
};

type CoachContextResult = {
  threadId: string | null;
  prependMessages: ChatMessage[];
  modeUsed: CoachMode;
  userId: string | null;
  householdId: string | null;
};

function toCoachMode(value: unknown): CoachMode {
  if (value === 'plus' || value === 'pro') return value;
  return 'eco';
}

function toContextWindow(mode: CoachMode, value: unknown): number {
  const defaults: Record<CoachMode, number> = {
    eco: 6,
    plus: 20,
    pro: 40,
  };
  const fallback = defaults[mode];
  if (typeof value !== 'number' || !Number.isFinite(value)) return fallback;
  const rounded = Math.round(value);
  return Math.min(Math.max(rounded, 4), 60);
}

async function getEmbedding(
  openAiApiKey: string,
  text: string,
): Promise<number[] | null> {
  try {
    const response = await fetch('https://api.openai.com/v1/embeddings', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${openAiApiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'text-embedding-3-small',
        input: text,
      }),
    });
    if (!response.ok) return null;
    const data = await response.json();
    const vector = data?.data?.[0]?.embedding;
    return Array.isArray(vector) ? vector : null;
  } catch (_) {
    return null;
  }
}

async function ensureCoachThread(
  supabase: ReturnType<typeof createClient>,
  threadId: string | undefined,
  householdId: string | null,
  userId: string | null,
): Promise<string | null> {
  if (!householdId || !userId) return null;
  if (threadId && threadId.trim().length > 0) return threadId;

  const { data, error } = await supabase
      .from('coach_threads')
      .insert({
        household_id: householdId,
        user_id: userId,
      })
      .select('id')
      .single();
  if (error || !data?.id) return null;
  return data.id as string;
}

async function loadCoachContext(
  supabase: ReturnType<typeof createClient>,
  openAiApiKey: string,
  memoryReq: CoachMemoryRequest | null,
): Promise<CoachContextResult> {
  if (!memoryReq) {
    return {
      threadId: null,
      prependMessages: [],
      modeUsed: 'eco',
      userId: null,
      householdId: null,
    };
  }

  const mode = toCoachMode(memoryReq.mode);
  const contextWindow = toContextWindow(mode, memoryReq.context_window);

  const { data: userData } = await supabase.auth.getUser();
  const userId = userData?.user?.id ?? null;
  const householdId = memoryReq.household_id?.trim() || null;
  const threadId = await ensureCoachThread(
    supabase,
    memoryReq.thread_id,
    householdId,
    userId,
  );
  if (!threadId) {
    return {
      threadId: null,
      prependMessages: [],
      modeUsed: mode,
      userId,
      householdId,
    };
  }

  const prependMessages: ChatMessage[] = [];

  const { data: latestSummary } = await supabase
      .from('coach_memory_summaries')
      .select('summary')
      .eq('thread_id', threadId)
      .order('created_at', { ascending: false })
      .limit(1)
      .maybeSingle();

  if (latestSummary?.summary) {
    prependMessages.push({
      role: 'system',
      content: `Resumo da conversa anterior:\n${latestSummary.summary}`,
    });
  }

  if (mode !== 'eco' && userId && householdId && memoryReq.user_message) {
    const embedding = await getEmbedding(openAiApiKey, memoryReq.user_message);
    if (embedding) {
      const { data: matched } = await supabase.rpc('match_coach_memories', {
        p_household_id: householdId,
        p_user_id: userId,
        p_query_embedding: embedding,
        p_limit: mode === 'pro' ? 6 : 3,
      });
      if (Array.isArray(matched) && matched.length > 0) {
        const lines = matched
            .map((m) => `- ${m.content}`)
            .join('\n');
        prependMessages.push({
          role: 'system',
          content: `Memorias relevantes do utilizador:\n${lines}`,
        });
      }
    }
  }

  const { data: recentMessages } = await supabase
      .from('coach_messages')
      .select('role, content')
      .eq('thread_id', threadId)
      .order('created_at', { ascending: false })
      .limit(contextWindow);

  if (Array.isArray(recentMessages) && recentMessages.length > 0) {
    const ordered = [...recentMessages].reverse();
    for (const msg of ordered) {
      if (typeof msg?.role === 'string' && typeof msg?.content === 'string') {
        prependMessages.push({
          role: msg.role,
          content: msg.content,
        });
      }
    }
  }

  return {
    threadId,
    prependMessages,
    modeUsed: mode,
    userId,
    householdId,
  };
}

async function persistCoachMessages(
  supabase: ReturnType<typeof createClient>,
  context: CoachContextResult,
  userMessage: string | null,
  assistantMessage: string,
): Promise<void> {
  if (!context.threadId || !context.userId || !context.householdId) return;

  if (userMessage && userMessage.trim().length > 0) {
    await supabase.from('coach_messages').insert({
      thread_id: context.threadId,
      household_id: context.householdId,
      user_id: context.userId,
      role: 'user',
      content: userMessage.trim(),
      mode_used: context.modeUsed,
    });
  }

  await supabase.from('coach_messages').insert({
    thread_id: context.threadId,
    household_id: context.householdId,
    user_id: context.userId,
    role: 'assistant',
    content: assistantMessage,
    mode_used: context.modeUsed,
  });
}

async function maybeCreateSummary(
  supabase: ReturnType<typeof createClient>,
  openAiApiKey: string,
  context: CoachContextResult,
): Promise<void> {
  if (!context.threadId || !context.userId || !context.householdId) return;
  if (context.modeUsed === 'eco') return;

  const { count } = await supabase
      .from('coach_messages')
      .select('id', { count: 'exact', head: true })
      .eq('thread_id', context.threadId);

  if (!count || count < 20 || count % 10 !== 0) return;

  const { data: rows } = await supabase
      .from('coach_messages')
      .select('role, content, created_at')
      .eq('thread_id', context.threadId)
      .order('created_at', { ascending: false })
      .limit(20);

  if (!Array.isArray(rows) || rows.length === 0) return;
  const ordered = [...rows].reverse();
  const summaryInput = ordered
      .map((m) => `${m.role}: ${m.content}`)
      .join('\n');

  const upstream = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${openAiApiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: 'gpt-4o-mini',
      max_tokens: 220,
      temperature: 0.2,
      messages: [
        {
          role: 'system',
          content:
              'Resume esta conversa em portugues europeu para memoria de assistente financeiro. '
              + 'Foca objetivos, habitos, decisoes e contexto financeiro acionavel.',
        },
        { role: 'user', content: summaryInput },
      ],
    }),
  });
  if (!upstream.ok) return;
  const json = await upstream.json();
  const summary = json?.choices?.[0]?.message?.content?.toString()?.trim() ?? '';
  if (summary.length === 0) return;

  const start = ordered[0]?.created_at;
  const end = ordered[ordered.length - 1]?.created_at;
  if (!start || !end) return;

  await supabase.from('coach_memory_summaries').insert({
    thread_id: context.threadId,
    household_id: context.householdId,
    user_id: context.userId,
    summary,
    window_start: start,
    window_end: end,
  });
}

async function maybeStoreMemoryFacts(
  supabase: ReturnType<typeof createClient>,
  openAiApiKey: string,
  context: CoachContextResult,
  userMessage: string | null,
): Promise<void> {
  if (!context.threadId || !context.userId || !context.householdId) return;
  if (context.modeUsed === 'eco' || !userMessage) return;
  const text = userMessage.trim();
  if (text.length < 12) return;

  const extractionUpstream = await fetch(
    'https://api.openai.com/v1/chat/completions',
    {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${openAiApiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-4o-mini',
        temperature: 0.1,
        max_tokens: 240,
        response_format: { type: 'json_object' },
        messages: [
          {
            role: 'system',
            content:
              'Extrai apenas memorias de alto sinal para um coach financeiro. '
              + 'Responde APENAS JSON com formato {"memories":[{"type":"goal|habit|fact|preference|event|insight","content":"...","importance":1-5}]}. '
              + 'Se nao houver memorias, usa {"memories":[]}.',
          },
          {
            role: 'user',
            content: text,
          },
        ],
      }),
    },
  );
  if (!extractionUpstream.ok) return;
  const extractionJson = await extractionUpstream.json();
  const extractionContent = extractionJson?.choices?.[0]?.message?.content
    ?.toString()
    ?.trim() ?? '';
  if (extractionContent.length === 0) return;

  let parsed: unknown = null;
  try {
    parsed = JSON.parse(extractionContent);
  } catch (_) {
    return;
  }
  const memories = (parsed as { memories?: unknown })?.memories;
  if (!Array.isArray(memories) || memories.length === 0) return;

  const allowedTypes = new Set(['goal', 'habit', 'fact', 'preference', 'event', 'insight']);
  const seenInBatch = new Set<string>();
  const rows: Array<Record<string, unknown>> = [];

  for (const rawMemory of memories.slice(0, context.modeUsed === 'pro' ? 4 : 2)) {
    if (!rawMemory || typeof rawMemory !== 'object') continue;
    const item = rawMemory as {
      type?: unknown;
      content?: unknown;
      importance?: unknown;
    };
    const type = typeof item.type === 'string' ? item.type : '';
    const content = typeof item.content === 'string' ? item.content.trim() : '';
    if (!allowedTypes.has(type) || content.length < 8) continue;
    const dedupKey = `${type}:${content.toLowerCase()}`;
    if (seenInBatch.has(dedupKey)) continue;
    seenInBatch.add(dedupKey);

    const embedding = await getEmbedding(openAiApiKey, content);
    if (!embedding) continue;

    const { data: matched } = await supabase.rpc('match_coach_memories', {
      p_household_id: context.householdId,
      p_user_id: context.userId,
      p_query_embedding: embedding,
      p_limit: 1,
    });
    const topScore = Array.isArray(matched) && matched.length > 0
      ? Number(matched[0]?.score ?? 0)
      : 0;
    if (Number.isFinite(topScore) && topScore >= 0.93) {
      continue;
    }

    const rawImportance = typeof item.importance === 'number'
      ? Math.round(item.importance)
      : (context.modeUsed === 'pro' ? 4 : 3);
    const importance = Math.max(1, Math.min(rawImportance, 5));
    const expiresAt = computeMemoryExpiry(context.modeUsed, type);

    rows.push({
      household_id: context.householdId,
      user_id: context.userId,
      type,
      content,
      importance,
      embedding,
      expires_at: expiresAt,
    });
  }

  if (rows.length > 0) {
    await supabase.from('coach_memories').insert(rows);
  }
}

function computeMemoryExpiry(mode: CoachMode, type: string): string | null {
  const now = new Date();
  const days = (() => {
    if (mode === 'plus') return 30;
    if (mode === 'pro') {
      if (type === 'goal' || type === 'preference') return 365;
      return 180;
    }
    return 14;
  })();
  now.setUTCDate(now.getUTCDate() + days);
  return now.toISOString();
}

async function logCoachUsageEvent(
  supabase: ReturnType<typeof createClient>,
  context: CoachContextResult,
  memoryReq: CoachMemoryRequest | null,
  responseLength: number,
): Promise<void> {
  if (!context.userId || !context.householdId) return;
  try {
    const requestedMode = toCoachMode(memoryReq?.requested_mode ?? memoryReq?.mode);
    const usedFallback = memoryReq?.used_fallback === true;
    const fallbackReason = memoryReq?.fallback_reason?.toString() ?? null;

    await supabase.from('coach_usage_events').insert({
      household_id: context.householdId,
      user_id: context.userId,
      thread_id: context.threadId,
      client_audit_id: memoryReq?.client_audit_id?.toString() ?? null,
      requested_mode: requestedMode,
      effective_mode: context.modeUsed,
      debited_credits: typeof memoryReq?.debited_credits === 'number'
        ? Math.max(0, Math.round(memoryReq.debited_credits))
        : 0,
      client_credit_before: typeof memoryReq?.client_credit_before === 'number'
        ? Math.max(0, Math.round(memoryReq.client_credit_before))
        : null,
      client_credit_after: typeof memoryReq?.client_credit_after === 'number'
        ? Math.max(0, Math.round(memoryReq.client_credit_after))
        : null,
      used_fallback: usedFallback,
      fallback_reason: fallbackReason,
      response_length_chars: responseLength,
    });
  } catch (_) {
    // Usage logging must not break chat responses.
  }
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const openAiApiKey = Deno.env.get('OPENAI_API_KEY') ?? '';
    if (openAiApiKey.length === 0) {
      return new Response(
        JSON.stringify({ error: 'Missing OPENAI_API_KEY secret' }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        },
      );
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY') ?? '';
    const authHeader = req.headers.get('Authorization') ?? '';
    const hasSupabaseContext = supabaseUrl.length > 0
      && supabaseAnonKey.length > 0
      && authHeader.length > 0;
    const supabase = hasSupabaseContext
      ? createClient(supabaseUrl, supabaseAnonKey, {
        global: {
          headers: {
            Authorization: authHeader,
          },
        },
      })
      : null;

    const body = await req.json();
    const model = body?.model ?? 'gpt-4o-mini';
    const messages = body?.messages as ChatMessage[] | undefined;
    const maxTokens = body?.max_tokens ?? 600;
    const temperature = body?.temperature ?? 0.6;
    const responseFormat = body?.response_format;
    const coachMemory = (body?.coach_memory as CoachMemoryRequest | undefined) ?? null;

    if (!Array.isArray(messages) || messages.length === 0) {
      return new Response(
        JSON.stringify({ error: 'messages must be a non-empty array' }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        },
      );
    }

    const coachContext = supabase
      ? await loadCoachContext(supabase, openAiApiKey, coachMemory)
      : {
        threadId: null,
        prependMessages: [],
        modeUsed: toCoachMode(coachMemory?.mode),
        userId: null,
        householdId: null,
      };
    const finalMessages: ChatMessage[] = [
      ...coachContext.prependMessages,
      ...messages,
    ];

    const payload: Record<string, unknown> = {
      model,
      messages: finalMessages,
      max_tokens: maxTokens,
      temperature,
    };
    if (responseFormat != null) {
      payload.response_format = responseFormat;
    }

    const upstream = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${openAiApiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(payload),
    });

    const upstreamText = await upstream.text();
    let upstreamJson: Record<string, unknown> = {};
    try {
      upstreamJson = JSON.parse(upstreamText) as Record<string, unknown>;
    } catch (_) {
      // Keep fallback text error below.
    }

    if (!upstream.ok) {
      const upstreamError = upstreamJson.error as Record<string, unknown> | undefined;
      const apiError =
          upstreamError?.message?.toString() ??
          `OpenAI request failed with status ${upstream.status}`;
      return new Response(
        JSON.stringify({ error: apiError }),
        {
          status: upstream.status,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        },
      );
    }

    const choices = upstreamJson.choices as Array<Record<string, unknown>> | undefined;
    const message = choices?.[0]?.message as Record<string, unknown> | undefined;
    const content = message?.content?.toString() ?? '';

    const userMessage = coachMemory?.user_message?.toString() ?? null;
    if (supabase) {
      try {
        await persistCoachMessages(supabase, coachContext, userMessage, content);
        await maybeStoreMemoryFacts(
          supabase,
          openAiApiKey,
          coachContext,
          userMessage,
        );
        await maybeCreateSummary(supabase, openAiApiKey, coachContext);
        await logCoachUsageEvent(supabase, coachContext, coachMemory, content.length);
      } catch (_) {
        // Memory pipeline must not break core chat completion delivery.
      }
    }

    return new Response(
      JSON.stringify({
        content,
        usage: upstreamJson.usage ?? null,
        thread_id: coachContext.threadId,
        coach_mode: coachContext.modeUsed,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      },
    );
  } catch (e) {
    return new Response(
      JSON.stringify({ error: (e as Error).message }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      },
    );
  }
});
