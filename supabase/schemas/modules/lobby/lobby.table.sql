create table "lobbies" (
    "id" uuid primary key default gen_random_uuid(),
    "created_at" timestamp with time zone not null default now(),
    "ended_at" timestamp with time zone
);

create table "lobby_players" (
    "id" bigserial primary key,
    "lobby_id" uuid references lobbies(id) on delete cascade,
    "player_number" int not null,
    constraint "uq_lobby_players_number" unique ("lobby_id", "player_number")
);

alter publication supabase_realtime
    add table lobby_players;

ALTER TABLE lobby_players REPLICA IDENTITY FULL;
