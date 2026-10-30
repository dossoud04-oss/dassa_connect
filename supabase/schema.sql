-- =====================================================================
-- DASSA CONNECT : schéma unifié (à exécuter une fois sur un projet Supabase vide)
-- Les numéros sont stockés en chiffres seulement : 22997000000
-- =====================================================================

create type categorie_prestataire as enum ('menuisier', 'soudeur', 'hotel', 'restauration', 'autre');
create type statut_prestataire as enum ('pending', 'approved', 'rejected');
create type statut_commande as enum ('nouvelle', 'ecoutee', 'livree');

create table prestataires (
  id uuid primary key default gen_random_uuid(),
  nom text not null,
  categorie categorie_prestataire not null default 'autre',
  quartier text not null,
  description text not null default '',
  prix_base integer not null default 0 check (prix_base >= 0),
  photos_url text[] not null default '{}',
  tarifs text[] not null default '{}',
  telephone text not null unique,
  statut statut_prestataire not null default 'pending',
  vues integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table commandes (
  id uuid primary key default gen_random_uuid(),
  client_telephone text not null,
  prestataire_id uuid not null references prestataires(id) on delete cascade,
  message_texte text,
  audio_url text,
  audio_duration integer not null default 0 check (audio_duration between 0 and 60),
  montant integer not null default 0,
  statut statut_commande not null default 'nouvelle',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_commandes_prestataire on commandes (prestataire_id, updated_at);
create index idx_prestataires_maj on prestataires (updated_at);

create table voice_searches (
  id uuid primary key default gen_random_uuid(),
  client_telephone text not null default '',
  audio_url text,
  transcription text,
  created_at timestamptz not null default now()
);

-- Administrateurs : numéros autorisés à valider les prestataires
create table admins (
  telephone text primary key
);

-- ---------------------------------------------------------------------
-- Dates de mise à jour : indispensables à la synchronisation incrémentale
-- ---------------------------------------------------------------------

create or replace function set_updated_at() returns trigger
language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger trg_prestataires_maj before update on prestataires
  for each row execute function set_updated_at();

create trigger trg_commandes_maj before update on commandes
  for each row execute function set_updated_at();

-- ---------------------------------------------------------------------
-- Fonctions utilisées par la sécurité
-- ---------------------------------------------------------------------

-- Numéro de l’utilisateur connecté, en chiffres seulement (vide si personne n’est connecté)
create or replace function telephone_connecte() returns text
language sql stable as $$
  select regexp_replace(coalesce(auth.jwt() ->> 'phone', ''), '[^0-9]', '', 'g');
$$;

create or replace function est_admin() returns boolean
language sql stable as $$
  select exists (select 1 from admins a where a.telephone = telephone_connecte());
$$;

-- Seul un administrateur peut changer le statut d’une fiche.
-- L’éditeur SQL du tableau de bord (rôle postgres) reste autorisé pour la gestion manuelle.
create or replace function proteger_statut() returns trigger
language plpgsql as $$
begin
  if new.statut is distinct from old.statut
     and current_user not in ('postgres', 'supabase_admin')
     and not est_admin() then
    raise exception 'Seul un administrateur peut changer le statut d’une fiche';
  end if;
  return new;
end;
$$;

create trigger trg_proteger_statut before update on prestataires
  for each row execute function proteger_statut();

-- ---------------------------------------------------------------------
-- Sécurité (Row Level Security)
-- ---------------------------------------------------------------------

alter table prestataires enable row level security;
alter table commandes enable row level security;
alter table voice_searches enable row level security;
alter table admins enable row level security;

-- Fiches : les approuvées sont visibles de tous ; sa propre fiche et l’administrateur voient tout
create policy prestataires_lecture on prestataires for select to anon, authenticated
  using (statut = 'approved' or telephone = telephone_connecte() or est_admin());

create policy prestataires_inscription on prestataires for insert to authenticated
  with check (telephone = telephone_connecte() and statut = 'pending');

create policy prestataires_maj on prestataires for update to authenticated
  using (telephone = telephone_connecte() or est_admin())
  with check (telephone = telephone_connecte() or est_admin());

-- Commandes : un client sans compte peut en créer une ; le prestataire concerné les lit et les traite
create policy commandes_creation on commandes for insert to anon, authenticated
  with check (statut = 'nouvelle');

create policy commandes_lecture on commandes for select to authenticated
  using (est_admin() or exists (
    select 1 from prestataires p where p.id = prestataire_id and p.telephone = telephone_connecte()
  ));

create policy commandes_maj on commandes for update to authenticated
  using (est_admin() or exists (
    select 1 from prestataires p where p.id = prestataire_id and p.telephone = telephone_connecte()
  ))
  with check (true);

-- Recherches vocales : création libre, lecture par l’administrateur
create policy voice_searches_creation on voice_searches for insert to anon, authenticated
  with check (true);

create policy voice_searches_lecture on voice_searches for select to authenticated
  using (est_admin());

create policy admins_lecture on admins for select to authenticated
  using (est_admin());

-- ---------------------------------------------------------------------
-- Stockage : buckets publics (APK, photos des prestataires, notes vocales)
-- ---------------------------------------------------------------------

insert into storage.buckets (id, name, public)
values ('apks', 'apks', true),
       ('prestataire_photos', 'prestataire_photos', true),
       ('voice_notes', 'voice_notes', true)
on conflict (id) do nothing;

create policy apks_lecture on storage.objects for select to anon, authenticated
  using (bucket_id = 'apks');

create policy photos_lecture on storage.objects for select to anon, authenticated
  using (bucket_id = 'prestataire_photos');

create policy photos_ecriture on storage.objects for insert to authenticated
  with check (bucket_id = 'prestataire_photos');

create policy voix_lecture on storage.objects for select to anon, authenticated
  using (bucket_id = 'voice_notes');

create policy voix_ecriture on storage.objects for insert to anon, authenticated
  with check (bucket_id = 'voice_notes');

-- ---------------------------------------------------------------------
-- Données de démonstration, tirées des maquettes (à remplacer par de vraies fiches)
-- ---------------------------------------------------------------------

insert into prestataires (nom, categorie, quartier, description, prix_base, tarifs, telephone, statut)
values
  ('Atelier Pierre Dassa', 'menuisier', 'Sokponta', 'Meubles et portes en bois sur mesure.', 25000,
   array['Étagère bois|25000', 'Porte|45000', 'Réparation|8000'], '22997000001', 'approved'),
  ('Koffi Mensah', 'soudeur', 'Sokponta', 'Portails, grilles et soudure.', 5000,
   array['Soudure simple|5000'], '22997000002', 'approved'),
  ('Awa Bagnon', 'restauration', 'Sokponta', 'Cuisine locale et service traiteur.', 8000,
   array['Plat du jour|8000'], '22997000003', 'approved'),
  ('Amadou Diallo', 'autre', 'Centre', 'Plomberie domestique.', 3000,
   array['Dépannage|3000'], '22997000004', 'pending'),
  ('Leïla Benmoussa', 'autre', 'Centre', 'Installations électriques.', 4000,
   array['Dépannage|4000'], '22997000005', 'pending'),
  ('Youssef Karim', 'autre', 'Centre', 'Nettoyage de locaux.', 6000,
   array['Nettoyage|6000'], '22997000006', 'pending')
on conflict (telephone) do nothing;

-- Administrateur : remplacer par votre numéro, chiffres seulement
insert into admins (telephone) values ('22997000000') on conflict do nothing;
