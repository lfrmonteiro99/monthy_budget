const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
      'authorization, x-client-info, apikey, content-type',
};

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

    const body = await req.json();
    const model = body?.model ?? 'gpt-4o-mini';
    const messages = body?.messages;
    const maxTokens = body?.max_tokens ?? 600;
    const temperature = body?.temperature ?? 0.6;
    const responseFormat = body?.response_format;

    if (!Array.isArray(messages) || messages.length === 0) {
      return new Response(
        JSON.stringify({ error: 'messages must be a non-empty array' }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        },
      );
    }

    const payload: Record<string, unknown> = {
      model,
      messages,
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
      const apiError =
          (upstreamJson.error as Record<string, unknown>?)?.message?.toString() ??
          `OpenAI request failed with status ${upstream.status}`;
      return new Response(
        JSON.stringify({ error: apiError }),
        {
          status: upstream.status,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        },
      );
    }

    const choices = upstreamJson.choices as Array<Record<string, unknown>>?;
    const message = choices?.[0]?.message as Record<string, unknown>?;
    const content = message?.content?.toString() ?? '';

    return new Response(
      JSON.stringify({
        content,
        usage: upstreamJson.usage ?? null,
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
