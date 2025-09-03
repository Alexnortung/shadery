create table lobby_game (
    lobby_id uuid
        references lobbies(id) on delete cascade
        not null
        unique,
    -- a player id can only be used once in this table
    game_id bigint
        references games(id) on delete cascade
        not null
        unique,
    created_at timestamp with time zone default now() not null
);
alter table "lobby_game" enable row level security;
alter publication supabase_realtime
    add table lobby_game;
alter table lobby_game
    add constraint lobby_game_pkey primary key (lobby_id, game_id);
