-- =====================================================================
-- Dassa Connect : alignement du schéma Supabase sur l’application Flutter
-- DÉJÀ APPLIQUÉE sur le projet dassa_connect (nom : alignement_schema_dassa_connect_v2).
-- Idempotente : peut être relancée sans casser les données.
-- =====================================================================

-- 1. Colonnes manquantes : prestataires
alter table public.prestataires
  add column if not exists quartier    text        not null default '',
  add column if not exists description text        not null default '',
  add column if not exists prix_base   integer     not null default 0,
  add column if not exists photos_url  jsonb       not null default '[]'::jsonb,
  add column if not exists tarifs      jsonb       not null default '[]'::jsonb,
  add column if not exists statut      text        not null default 'pending',
  add column if not exists vues        integer     not null default 0,
  add column if not exists updated_at  timestamptz not null default now();

do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'prestataires_statut_check') then
    alter table public.prestataires
      add constraint prestataires_statut_check check (statut in ('pending', 'approved', 'rejected'));
  end if;
end $$;

-- 2. Colonnes manquantes : commandes
alter table public.commandes
  add column if not exists audio_url   text,
  add column if not exists audio_duree integer     not null default 0,
  add column if not exists montant     integer     not null default 0,
  add column if not exists updated_at  timestamptz not null default now();

alter table public.commandes alter column statut set default 'nouvelle';

-- 3. Colonnes manquantes : recherches
alter table public.recherches
  add column if not exists audio_url  text,
  add column if not exists updated_at timestamptz not null default now();

-- 4. Un seul profil par numéro de téléphone
create unique index if not exists prestataires_telephone_key on public.prestataires (telephone);

-- 5. updated_at mis à jour automatiquement à chaque modification (remontée des validations vers les clients)
create or replace function public.touch_updated_at() returns trigger
language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists prestataires_touch_updated_at on public.prestataires;
create trigger prestataires_touch_updated_at before update on public.prestataires
  for each row execute function public.touch_updated_at();

drop trigger if exists commandes_touch_updated_at on public.commandes;
create trigger commandes_touch_updated_at before update on public.commandes
  for each row execute function public.touch_updated_at();

drop trigger if exists recherches_touch_updated_at on public.recherches;
create trigger recherches_touch_updated_at before update on public.recherches
  for each row execute function public.touch_updated_at();

-- 6. Seul un administrateur peut changer le statut d'une fiche
create or replace function public.proteger_statut() returns trigger
language plpgsql security definer set search_path = public
as $$
begin
  if new.statut is distinct from old.statut and not public.is_admin() then
    raise exception 'Seul un administrateur peut changer le statut d''une fiche';
  end if;
  return new;
end;
$$;

drop trigger if exists prestataires_proteger_statut on public.prestataires;
create trigger prestataires_proteger_statut before update on public.prestataires
  for each row execute function public.proteger_statut();

-- 7. Lecture restreinte : le public ne voit que les fiches validées, chacun voit les siennes, l'admin voit tout
drop policy if exists "Tout le monde peut voir les prestataires" on public.prestataires;
drop policy if exists "Lecture des fiches validees, de ses fiches et admin" on public.prestataires;
create policy "Lecture des fiches validees, de ses fiches et admin" on public.prestataires
  for select to public
  using (statut = 'approved' or user_id = auth.uid() or public.is_admin());

-- 8. Inscription : un prestataire (session anonyme) crée sa propre fiche
drop policy if exists "Un prestataire cree sa fiche" on public.prestataires;
create policy "Un prestataire cree sa fiche" on public.prestataires
  for insert to public
  with check (auth.uid() = user_id);

-- 9. Buckets de stockage (photos des prestataires, messages vocaux)
insert into storage.buckets (id, name, public)
values ('prestataire_photos', 'prestataire_photos', true),
       ('voice_notes', 'voice_notes', true)
on conflict (id) do nothing;

drop policy if exists "Envoi fichiers Dassa Connect" on storage.objects;
create policy "Envoi fichiers Dassa Connect" on storage.objects
  for insert to public
  with check (bucket_id in ('prestataire_photos', 'voice_notes'));

-- 10. Suppression d'un prestataire : ses commandes sont supprimées en cascade (clé étrangère existante, conservée)
