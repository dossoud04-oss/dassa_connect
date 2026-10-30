// Fonction Edge optionnelle (V1) : transcrit une recherche vocale avec l’API Whisper
// et remplit la colonne « transcription » de la table voice_searches.
// Nécessite les secrets OPENAI_API_KEY (et SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY fournis par Supabase).
// Coût : facturé à l’usage par OpenAI. Vérifier le modèle et le tarif actuels avant déploiement.
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

Deno.serve(async (req) => {
  const { voice_search_id, audio_url } = await req.json();

  const audio = await fetch(audio_url);
  const formulaire = new FormData();
  formulaire.append('file', await audio.blob(), 'recherche.m4a');
  formulaire.append('model', 'whisper-1');
  formulaire.append('language', 'fr');

  const reponse = await fetch('https://api.openai.com/v1/audio/transcriptions', {
    method: 'POST',
    headers: { Authorization: `Bearer ${Deno.env.get('OPENAI_API_KEY')}` },
    body: formulaire,
  });
  const resultat = await reponse.json();

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  );
  await supabase.from('voice_searches').update({ transcription: resultat.text }).eq('id', voice_search_id);

  return new Response(JSON.stringify({ ok: true }), {
    headers: { 'Content-Type': 'application/json' },
  });
});
