import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

const GROQ_API_KEY = Deno.env.get("GROQ_API_KEY");

serve(async (req) => {
  // 1. Gestion du CORS
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: cors() });
  }

  try {
    const body = await req.json().catch(() => null);
    const userMessage = body?.message?.trim();

    if (!userMessage) {
      return json({ reply: "Tu n'as rien écrit !" }, 400);
    }

    if (!GROQ_API_KEY) {
      console.error("ERREUR: GROQ_API_KEY manquante.");
      return json({ reply: "Erreur de configuration serveur." }, 500);
    }

    console.log(`Utilisateur: ${userMessage}`);

    // 2. Appel à l'API Groq (Compatible format OpenAI)
    const response = await fetch("https://api.groq.com/openai/v1/chat/completions", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${GROQ_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: "llama-3.3-70b-versatile",
        messages: [
          { role: "system", content: "Tu es un assistant utile, poli et concis." },
          { role: "user", content: userMessage }
        ],
        temperature: 0.7,
        max_tokens: 500
      }),
    });

    const data = await response.json();

    if (!response.ok) {
      console.error("Erreur Groq:", data);
      return json({ reply: `Désolé, l'IA est fatiguée (${response.status}).` }, response.status);
    }

    // 3. Extraction de la réponse
    const aiReply = data.choices?.[0]?.message?.content || "L'IA n'a pas trouvé de réponse.";
    
    console.log(`IA: ${aiReply}`);
    return json({ reply: aiReply });

  } catch (err) {
    console.error(`Erreur Interne: ${err.message}`);
    return json({ reply: "Erreur technique." }, 500);
  }
});

function cors() {
  return {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "authorization, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
  };
}

function json(data: any, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...cors(), "Content-Type": "application/json" },
  });
}